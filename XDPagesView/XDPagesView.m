//
//  XDPagesView.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/13.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesView.h"
#import "XDPagesTable.h"
#import "XDPagesCell.h"
#import "XDPagesTools.h"
#import "XDPagesValueLock.h"
#import "XDPagesTitleBar.h"

static NSString *const cellID = @"xdpagecell";
typedef NS_ENUM(NSInteger, XDPagesScrollStatus) {
    XDPages_None = 0,
    XDPages_Up = 1,
    XDPages_Down = 2
};
@interface XDPagesView () <UITableViewDelegate, UITableViewDataSource, XDPagesCellDelegate, XDPagesTitleBarDelegate>
@property (nonatomic, strong) XDPagesTable     *mainTable;
@property (nonatomic, strong) XDPagesCell      *mainCell;
@property (nonatomic, strong) UIView           *formHeader;
@property (nonatomic, strong) XDPagesValueLock *mainLock;
@property (nonatomic,   weak) UIScrollView     *pagesContainer;
@property (nonatomic, assign) BOOL              needLockOffset;
@property (nonatomic, strong) XDPagesTitleBar  *titleBar;
@property (nonatomic, strong) XDPagesConfig    *config;
@property (nonatomic, assign) XDPagesPullStyle  pagesPullStyle;
@property (nonatomic, assign) CGFloat           canChangeSpace;// 标题可变动高度

@property (nonatomic, assign) XDPagesScrollStatus s_status;
@property (nonatomic, assign) CGFloat   mainOffsetStatic;
@property (nonatomic, assign) BOOL isCurrentPageCanScroll;
@end

@implementation XDPagesView
- (void)dealloc {
    NSLog(@"\n_____XDPagesView_____已释放\n");
}

- (void)didMoveToSuperview {
    if (self.superview) {
        //添加到视图上
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createUI];
        });
    } else {
        //从视图上被移除
    }
}

- (instancetype)initWithFrame:(CGRect)frame config:(XDPagesConfig *)config style:(XDPagesPullStyle)style {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.mainLock = [XDPagesValueLock lock];
        self.config = config ? config : [XDPagesConfig config];
        _pagesPullStyle = style;
        _s_status = XDPages_None;
        _mainOffsetStatic = 0;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_mainTable beginUpdates];
    [_mainTable endUpdates];
}

- (UIViewController *)dequeueReusablePageForIndex:(NSInteger)index {
    return [self.mainCell dequeueReusablePageForIndex:index];
}

- (void)jumpToPage:(NSInteger)page {
    [self jumpToPage:page animate:self.config.animateForPageChange];
}

- (void)jumpToPage:(NSInteger)page animate:(BOOL)animate {
    [self.mainCell changeToPage:page animate:animate];
}

- (void)scrollToCeiling:(BOOL)animate {
    self.mainTable.gesturePublic = NO;
    self.mainTable.userInteractionEnabled = NO;
    [self.mainTable setContentOffset:CGPointMake(0, _canChangeSpace) animated:animate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.mainTable.userInteractionEnabled = YES;
        self.mainTable.gesturePublic = YES;
    });
}

- (void)reloadataToPage:(NSInteger)page {
    __weak typeof(self)weakSelf = self;
    [self.mainCell reloadToPage:page finish:^(NSArray<NSString *> *titles) {
        if (weakSelf.config.needTitleBar && !weakSelf.config.customTitleBar) {
            weakSelf.titleBar.refreshTitles(titles);
        }
    }];
}

- (void)reloadConfigs {
    [_mainTable beginUpdates];
    [self calculateChangeSpace];
    [_mainTable endUpdates];
    [self scrollViewDidScroll:_mainTable];
    [_mainCell reloadConfigs];
    [_titleBar reloadConfigs];
}

- (void)showBadgeNumber:(NSInteger)number index:(NSInteger)idx color:(UIColor *)color isNumber:(BOOL)isNumber {
    if (self.config.needTitleBar && !self.config.customTitleBar) {
        [self.titleBar showBadgeNumber:number index:idx color:color isNumber:isNumber];
    }
}

// 当竖直滚动时禁止横向滚动，由于此时仍需要手势共享，所以只能关闭横向滚动的scrollEnabled
- (void)pagesContainerScrollEnable:(BOOL)enabel {
    if (self.pagesContainer && self.pagesContainer.scrollEnabled != enabel && self.config.pagesSlideEnable) {
        self.pagesContainer.scrollEnabled = enabel;
    }
}

#pragma mark -- table_delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat margin = _config.titleBarMarginTop > CGRectGetHeight(self.formHeader.bounds) ? CGRectGetHeight(self.formHeader.bounds) : _config.titleBarMarginTop;
    return CGRectGetHeight(self.mainTable.bounds) - self.mainTable.sectionHeaderHeight - margin;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = _config.needTitleBar ? (self.config.customTitleBar ? self.config.customTitleBar : self.titleBar) : nil;
    header.layer.zPosition = self.formHeader.layer.zPosition + 1;
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _mainCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!_mainCell) {
        _mainCell = [[XDPagesCell alloc]initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID
                                    contentController:[XDPagesTools viewControllerForView:self]
                                             delegate:self
                                       pagesPullStyle:self.pagesPullStyle
                                               config:self.config];
        
        self.pagesContainer = [_mainCell exchangeChannelOfPagesContainerAndMainTable:self.mainTable];
    }
    
    return _mainCell;
}

#pragma mark -- scroll_delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView) {
        return;
    }
    
    // 如果滚动方向改变，先把主列表锁定，然后通过子view滚动去判断是否解锁，已达到主列表自由滚动响应延后的目的，过滤垂直滚动代理脏数据
    if (_isCurrentPageCanScroll) {
        if (_mainOffsetStatic < scrollView.contentOffset.y) {
            if (self.s_status != XDPages_Up) {
                self.s_status = XDPages_Up;
                _needLockOffset = YES;
            }
        } else if (_mainOffsetStatic > scrollView.contentOffset.y) {
            if (self.s_status != XDPages_Down) {
                self.s_status = XDPages_Down;
                _needLockOffset = YES;
            }
        }
    }
    
    if (scrollView.contentOffset.y > _canChangeSpace) {
        scrollView.contentOffset = CGPointMake(0, _canChangeSpace);
    }
    if (self.pagesPullStyle == XDPagesPullOnCenter) {
        if (scrollView.contentOffset.y < 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
        }
    }
    
    if (_needLockOffset && _mainTable.gesturePublic) {
        if (_mainOffsetStatic >= 0 && _mainOffsetStatic <= _canChangeSpace) {
            scrollView.contentOffset = CGPointMake(0, [_mainLock lockValue:_mainOffsetStatic]);
        } else {
            [_mainLock unlock];
        }
    } else {
        [_mainLock unlock];
    }

    _mainOffsetStatic = scrollView.contentOffset.y;
    if ([self.delegate respondsToSelector:@selector(xd_pagesViewVerticalScrollOffsetyChanged:isCeiling:)]) {
        [self.delegate xd_pagesViewVerticalScrollOffsetyChanged:_mainOffsetStatic isCeiling:floor(_mainOffsetStatic * 100) >= floor(_canChangeSpace * 100)];
    }
}

// 以下代理用于判断mainTable是否在滚动状态
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pagesContainerScrollEnable:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self pagesContainerScrollEnable:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self pagesContainerScrollEnable:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self pagesContainerScrollEnable:YES];
}

#pragma mark -- titleBar_delegate
- (void)xd_titleTapAtIndex:(NSInteger)index {
    [self.mainCell changeToPage:index animate:self.config.animateForPageChange];
}

- (CGFloat)xd_titleWidthForIndex:(NSInteger)index title:(NSString *)title {
    return [self.delegate respondsToSelector:@selector(xd_pagesViewTitleWidthForIndex:title:)] ? [self.delegate xd_pagesViewTitleWidthForIndex:index title:title] : -1;
}

#pragma mark -- cell_delegate
- (NSArray<NSString *> *)cell_pagesViewAllTitles {
    return [self.delegate xd_pagesViewPageTitles];
}

- (UIViewController *)cell_pagesViewChildControllerForIndex:(NSInteger)index title:(NSString *)title {
    return [self.delegate xd_pagesView:self controllerForIndex:index title:title];
}

- (CGFloat)cell_headerVerticalCanChangedSpace {
    return _canChangeSpace;
}

- (void)cell_pagesViewDidChangeToPageController:(UIViewController *const)pageController title:(NSString *)pageTitle pageIndex:(NSInteger)pageIndex {
    if (self.config.needTitleBar && !self.config.customTitleBar) {
        self.titleBar.currentFocusIndex(pageIndex);
    }
    
    if ([self.delegate respondsToSelector:@selector(xd_pagesViewDidChangeToController:index:title:)]) {
        [self.delegate xd_pagesViewDidChangeToController:pageController index:pageIndex title:pageTitle];
    }
}

- (void)cell_pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx currentPage:(NSInteger)page willShowPage:(NSInteger)willShowPage {
    if ([self.delegate respondsToSelector:@selector(xd_pagesViewHorizontalScrollOffsetxChanged:currentPage:willShowPage:)]) {
        [self.delegate xd_pagesViewHorizontalScrollOffsetxChanged:changedx currentPage:page willShowPage:willShowPage];
    }
}

- (void)cell_pagesViewSafeHorizontalScrollOffsetxChanged:(CGFloat)changedx currentPage:(NSInteger)page willShowPage:(NSInteger)willShowPage {
    if (self.config.needTitleBar && !self.config.customTitleBar) {
        [self.titleBar pagesViewHorizontalScrollOffsetxChanged:changedx
                                                   currentPage:page
                                                    willToPage:willShowPage
                                                         width:CGRectGetWidth(self.bounds)];
    }
}

- (void)cell_mainTableNeedLock:(BOOL)need offsety:(CGFloat)y {
    if (_needLockOffset != need) {
        _needLockOffset = need;
        if (need) {
            _mainOffsetStatic = y;
            _mainTable.contentOffset = CGPointMake(0, y);
            [self scrollViewDidScroll:_mainTable];
        }
    }
}

#pragma mark -- setter
- (void)setPagesHeader:(UIView *)pagesHeader {
    
    _pagesHeader = pagesHeader;
    
    if (_mainTable) {
        [_mainTable beginUpdates];
        _mainTable.tableHeaderView = [self formHeader:pagesHeader];
        [self calculateChangeSpace];
        [_mainTable endUpdates];
    }
}

- (void)setRefreshControl:(UIRefreshControl *)refreshControl {
    if (!refreshControl || _pagesPullStyle == XDPagesPullOnCenter) return;
    
    _refreshControl = refreshControl;
    
    if (_mainTable) {
        _mainTable.refreshControl = refreshControl;
    }
}

#pragma mark -- getter
- (XDPagesTable *)mainTable {
    if (!_mainTable) {
        _mainTable = [[XDPagesTable alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _mainTable.showsVerticalScrollIndicator = NO;
        _mainTable.showsHorizontalScrollIndicator = NO;
        _mainTable.backgroundColor = [UIColor clearColor];
        _mainTable.gesturePublic = YES;
        _mainTable.delegate = self;
        _mainTable.dataSource = self;
        _mainTable.scrollsToTop = NO;
        _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTable.sectionHeaderHeight = _config.titleBarHeight;
        _mainTable.tableHeaderView = [self formHeader:_pagesHeader];
        [self calculateChangeSpace];
        if (@available(iOS 15.0, *)) {
            _mainTable.sectionHeaderTopPadding = 0;
        }
        
        [XDPagesTools closeAdjustForScroll:_mainTable controller:[XDPagesTools viewControllerForView:self]];
        
        if (_refreshControl) {
            _mainTable.refreshControl = _refreshControl;
        }
    }
    
    return _mainTable;
}

- (XDPagesTitleBar *)titleBar {
    if (!self.config.needTitleBar || self.config.customTitleBar)return nil;
    
    if (!_titleBar) {
        _titleBar = [[XDPagesTitleBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), _config.titleBarHeight) config:self.config titles:[self.delegate xd_pagesViewPageTitles]];
        _titleBar.delegate = self;
    }
    
    return _titleBar;
}

#pragma mark -- UI
- (void)createUI {
    
    [self addSubview:self.mainTable];
    
    self.mainTable.translatesAutoresizingMaskIntoConstraints = NO;
    // 上
    NSLayoutConstraint *relat_top = [NSLayoutConstraint
                                     constraintWithItem:self.mainTable
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1
                                     constant:0];
    // 左
    NSLayoutConstraint *relat_led = [NSLayoutConstraint
                                     constraintWithItem:self.mainTable
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1
                                     constant:0];
    // 下
    NSLayoutConstraint *relat_btm = [NSLayoutConstraint
                                     constraintWithItem:self.mainTable
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                     constant:0];
    // 右
    NSLayoutConstraint *relat_tal = [NSLayoutConstraint
                                     constraintWithItem:self.mainTable
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                     constant:0];
    // 约束
    [NSLayoutConstraint activateConstraints:@[relat_top, relat_led, relat_btm, relat_tal]];
}

// 对header进行重新包装用于内部
- (UIView *)formHeader:(UIView *)header {
    UIView *f_header = nil;
    if (header) {
        CGFloat headerHeight = CGRectGetHeight(header.bounds) - (_config.titleBarFitHeader ? _config.titleBarHeight : 0);
        CGRect c_frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), headerHeight);
        f_header = [[UIView alloc]initWithFrame:c_frame];
        f_header.backgroundColor = [UIColor clearColor];
        [f_header addSubview:header];
        
        f_header.userInteractionEnabled = header.userInteractionEnabled;
        
        header.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (_config.titleBarFitHeader) {
            NSLayoutConstraint *relat_btm = [NSLayoutConstraint
                                             constraintWithItem:header
                                             attribute:NSLayoutAttributeBottom
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:f_header
                                             attribute:NSLayoutAttributeBottom
                                             multiplier:1
                                             constant:_config.titleBarHeight];
            [NSLayoutConstraint activateConstraints:@[relat_btm]];
        } else {
            NSLayoutConstraint *relat_btm = [NSLayoutConstraint
                                             constraintWithItem:header
                                             attribute:NSLayoutAttributeBottom
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:f_header
                                             attribute:NSLayoutAttributeBottom
                                             multiplier:1
                                             constant:0];
            [NSLayoutConstraint activateConstraints:@[relat_btm]];
        }
        
        NSLayoutConstraint *relat_top = [NSLayoutConstraint
                                         constraintWithItem:header
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:f_header
                                         attribute:NSLayoutAttributeTop
                                         multiplier:1
                                         constant:0];
        NSLayoutConstraint *relat_led = [NSLayoutConstraint
                                         constraintWithItem:header
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:f_header
                                         attribute:NSLayoutAttributeLeading
                                         multiplier:1
                                         constant:0];
        NSLayoutConstraint *relat_tal = [NSLayoutConstraint
                                         constraintWithItem:header
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:f_header
                                         attribute:NSLayoutAttributeTrailing
                                         multiplier:1
                                         constant:0];
        [NSLayoutConstraint activateConstraints:@[relat_top, relat_led, relat_tal]];
        [f_header layoutIfNeeded];
    }
    
    self.formHeader = f_header;
    
    return f_header;
}

//计算活动区间
- (void)calculateChangeSpace {
    CGFloat headerHeight = _mainTable.tableHeaderView ? CGRectGetHeight(_mainTable.tableHeaderView.frame) : 0;
    CGFloat cmargin = _config.titleBarMarginTop > headerHeight ? headerHeight : _config.titleBarMarginTop;
    CGFloat cheight = headerHeight-cmargin;
    _canChangeSpace = cheight > 0 ? cheight : 0;
}

#pragma mark -- sys_method
static NSTimeInterval lastEventTimeStamp = 0;
// 利用hittest在手势进入之前，判断手势不在container中时就关闭手势共享，目的：防止header中有滚动控件，造成共同滚动
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint relative_point = [self.pagesContainer convertPoint:point fromView:self];
    
    if ([self.pagesContainer.layer containsPoint:relative_point]) {
        if (!self.mainTable.gesturePublic) self.mainTable.gesturePublic = YES;
        
        //寻找这个点击事件的位置上有没有可以监听的滚动控件
        UIView *view = [super hitTest:point withEvent:event];
        if (lastEventTimeStamp != event.timestamp) {
            lastEventTimeStamp = event.timestamp;
            UIScrollView *kvoScroll;
            BOOL canfindScroll = NO;
            for (UIView *next = view; next; next = next.superview) {
                if (next == self.pagesContainer) {
                    break;
                }
                else if ([next isKindOfClass:[UIScrollView class]]) {
                    kvoScroll = (UIScrollView *)next;
                }
            }
            if (kvoScroll && kvoScroll.scrollEnabled && kvoScroll.tag != XD_IGNORETAG) {
                canfindScroll = YES;
            }
            self.isCurrentPageCanScroll = canfindScroll;
            if (!canfindScroll) {
                //当前触点空间不能滚动，则当做普通视图处理，解除maintable锁定，并解除之前的滚动观察
                self.needLockOffset = NO;
                self.mainCell.currentKVOChild = nil;
            }
            self.mainCell.mainOffsetStatic = self.mainTable.contentOffset.y;
        }
        return view;
    } else {
        if (self.mainTable.gesturePublic) self.mainTable.gesturePublic = NO;
    }
    
    return [super hitTest:point withEvent:event];
}

@end
