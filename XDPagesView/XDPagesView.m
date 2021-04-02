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
@property (nonatomic, strong) UIView           *customHeader;
@property (nonatomic, strong) XDPagesValueLock *mainLock;
@property (nonatomic,   weak) UIScrollView     *pagesContainer;
@property (nonatomic, assign) BOOL              needLockOffset;
@property (nonatomic, strong) XDPagesTitleBar  *titleBar;
@property (nonatomic, strong) XDPagesConfig    *config;
@property (nonatomic, assign) XDPagesPullStyle  pagesPullStyle;
@property (nonatomic, assign) CGFloat           adjustValue;    // 调整值
@property (nonatomic, assign) CGFloat           canChangeHeight;// 标题可变动高度

@property (nonatomic, assign) XDPagesScrollStatus s_status;
@property (nonatomic, assign) CGFloat   mainOffsetStatic;
@property (nonatomic, assign) BOOL isCurrentPageCanScroll;
@end

@implementation XDPagesView
- (void)dealloc {
    NSLog(@"\n_____XDPagesView_____已释放\n");
}

- (instancetype)initWithFrame:(CGRect)frame config:(XDPagesConfig *)config style:(XDPagesPullStyle)style {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.adjustValue = 1.0/[UIScreen mainScreen].scale;
        self.mainLock = [XDPagesValueLock lock];
        self.config = config ? config : [XDPagesConfig config];
        _pagesPullStyle = style;
        _s_status = XDPages_None;
        _mainOffsetStatic = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createUI];
        });
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

- (void)reloadataToPage:(NSInteger)page {
    __weak typeof(self)weakSelf = self;
    [self.mainCell reloadToPage:page finish:^(NSArray<NSString *> *titles) {
        if (weakSelf.config.needTitleBar && !weakSelf.config.customTitleBar) {
            weakSelf.titleBar.refreshTitles(titles);
            weakSelf.titleBar.currentFocusIndex(page);
        }
    }];
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

// 是否锁定主列表偏移
- (CGFloat)lockMainTableAtOffsety:(CGFloat)y needLock:(BOOL)need {
    
    CGFloat offsety = [_mainLock value:y lock:need];
    
    return offsety;
}

#pragma mark -- table_delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat margin = _config.titleBarMarginTop > CGRectGetHeight(self.customHeader.bounds) ? CGRectGetHeight(self.customHeader.bounds) : _config.titleBarMarginTop;
    return CGRectGetHeight(self.mainTable.bounds) - self.mainTable.sectionHeaderHeight - margin;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _config.needTitleBar ? (self.config.customTitleBar ? self.config.customTitleBar : self.titleBar) : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _mainCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!_mainCell) {
        _mainCell = [[XDPagesCell alloc]initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellID
                                    contentController:[XDPagesTools viewControllerForView:self]
                                             delegate:self
                                       pagesPullStyle:self.pagesPullStyle
                                               config:self.config
                                          adjustValue:self.adjustValue];
        
        self.pagesContainer = [_mainCell exchangeChannelOfPagesContainerAndMainTable:self.mainTable];
    }
    
    return _mainCell;
}

#pragma mark -- scroll_delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView) {
        return;
    }
    
    if (scrollView.contentOffset.y > _canChangeHeight) {
        scrollView.contentOffset = CGPointMake(0, _canChangeHeight);
    }
    if (self.pagesPullStyle == XDPagesPullOnCenter) {
        if (scrollView.contentOffset.y <= 0) {
            scrollView.contentOffset = CGPointMake(0, 0);
        }
    }
    
    // 如果滚动方向改变，先把主列表锁定，然后通过子view滚动去判断是否解锁，已达到主列表自由滚动响应延后的目的，取出垂直滚动代理脏数据
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
    
    if (_needLockOffset && _mainTable.gesturePublic) {
        
        CGFloat offsety = [self lockMainTableAtOffsety:_mainOffsetStatic needLock:YES];
        
        if (offsety >= 0) {
            scrollView.contentOffset = CGPointMake(0, offsety);
        } else {
            [self lockMainTableAtOffsety:scrollView.contentOffset.y needLock:NO];
        }

    } else {
        [self lockMainTableAtOffsety:scrollView.contentOffset.y needLock:NO];
    }

    _mainOffsetStatic = scrollView.contentOffset.y;
    if ([self.delegate respondsToSelector:@selector(xd_pagesViewVerticalScrollOffsetyChanged:isCeiling:)]) {
        [self.delegate xd_pagesViewVerticalScrollOffsetyChanged:_mainOffsetStatic isCeiling:floor(_mainOffsetStatic) >= floor(_canChangeHeight)];
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
- (NSArray<NSString *> *)cell_allTitles {
    return [self.delegate xd_pagesViewPageTitles];
}

- (UIViewController *)cell_pagesViewChildControllerForIndex:(NSInteger)index title:(NSString *)title {
    return [self.delegate xd_pagesViewChildControllerToPagesView:self forIndex:index title:title];
}

- (CGFloat)cell_headerVerticalCanChangedSpace {
    return _canChangeHeight;
}

- (void)cell_pagesViewDidChangeToPageController:(UIViewController *const)pageController title:(NSString *)pageTitle pageIndex:(NSInteger)pageIndex {
    if (self.config.needTitleBar && !self.config.customTitleBar) {
        self.titleBar.currentFocusIndex(pageIndex);
    }
    
    if ([self.delegate respondsToSelector:@selector(xd_pagesViewDidChangeToPageController:title:pageIndex:)]) {
        [self.delegate xd_pagesViewDidChangeToPageController:pageController title:pageTitle pageIndex:pageIndex];
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

- (void)cell_currentPageScollEnable:(BOOL)enable {
    _isCurrentPageCanScroll = enable;
}

#pragma mark -- setter
- (void)setPagesHeader:(UIView *)pagesHeader {
    
    _pagesHeader = pagesHeader;
    
    if (_mainTable) {
        [_mainTable beginUpdates];
        _mainTable.tableHeaderView = [self customHeader:pagesHeader];
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
        _mainTable.tableHeaderView = [self customHeader:_pagesHeader];
        _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTable.tableHeaderView.userInteractionEnabled = _customHeader.userInteractionEnabled;
        _mainTable.sectionHeaderHeight = _config.titleBarHeight;
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
                                     constant:-self.adjustValue];
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
- (UIView *)customHeader:(UIView *)header {
    
    if (!header) {
        header = [[UIView alloc]initWithFrame:CGRectZero];
        header.userInteractionEnabled = YES;
        header.backgroundColor = [UIColor clearColor];
    }
    
    UIView *customHeader = [[UIView alloc]initWithFrame:header.bounds];
    customHeader.backgroundColor = [UIColor clearColor];
    [customHeader addSubview:header];
    
    customHeader.userInteractionEnabled = header.userInteractionEnabled;
    
    header.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (_config.titleBarFitHeader) {
        header.clipsToBounds = YES;
        NSLayoutConstraint *relat_btm = [NSLayoutConstraint
                                         constraintWithItem:header
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:customHeader
                                         attribute:NSLayoutAttributeBottom
                                         multiplier:1
                                         constant:_config.titleBarHeight];
        [NSLayoutConstraint activateConstraints:@[relat_btm]];
    } else {
        NSLayoutConstraint *relat_btm = [NSLayoutConstraint
                                         constraintWithItem:header
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:customHeader
                                         attribute:NSLayoutAttributeBottom
                                         multiplier:1
                                         constant:0];
        [NSLayoutConstraint activateConstraints:@[relat_btm]];
    }
    
    NSLayoutConstraint *relat_top = [NSLayoutConstraint
                                     constraintWithItem:header
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:customHeader
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1
                                     constant:self.adjustValue];
    NSLayoutConstraint *relat_led = [NSLayoutConstraint
                                     constraintWithItem:header
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:customHeader
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *relat_tal = [NSLayoutConstraint
                                     constraintWithItem:header
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:customHeader
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                     constant:0];
    [NSLayoutConstraint activateConstraints:@[relat_top, relat_led, relat_tal]];
    
    CGFloat headerHeight = [XDPagesTools adjustFloatValue:CGRectGetHeight(header.bounds)]+self.adjustValue;
    customHeader.frame = CGRectMake(0,
                                    0,
                                    CGRectGetWidth(self.bounds),
                                    headerHeight);
    
    CGFloat cmargin = _config.titleBarMarginTop > headerHeight ? headerHeight : _config.titleBarMarginTop;
    CGFloat cheight = headerHeight-cmargin-self.adjustValue;
    cheight = [@(cheight).stringValue floatValue];
    _canChangeHeight = cheight > 0 ? cheight : 0;
    self.customHeader = customHeader;
    
    return customHeader;
}

#pragma mark -- sys_method
// 利用hittest在手势进入之前，判断手势不在container中时就关闭手势共享，目的：防止header中有滚动控件，造成共同滚动
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *view = [super hitTest:point withEvent:event];
    
    CGPoint relative_point = [self.pagesContainer convertPoint:point fromView:self];
    
    if ([self.pagesContainer.layer containsPoint:relative_point]) {
        if (!self.mainTable.gesturePublic) self.mainTable.gesturePublic = YES;
        [self.mainCell setCurrentMainTalbelOffsety:self.mainTable.contentOffset.y];
    } else {
        if (self.mainTable.gesturePublic) self.mainTable.gesturePublic = NO;
    }
    
    [self scrollViewDidScroll:self.mainTable];
    
    return view;
}

@end
