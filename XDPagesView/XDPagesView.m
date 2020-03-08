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
@interface XDPagesView () <UITableViewDelegate, UITableViewDataSource, XDPagesCellDelegate, XDPagesTitleBarDelegate>
@property (nonatomic, strong) XDPagesTable     *mainTable;
@property (nonatomic, strong) XDPagesCell      *mainCell;
@property (nonatomic, strong) XDPagesValueLock *mainLock;
@property (nonatomic,   weak) UIScrollView     *pagesContainer;
@property (nonatomic, assign) BOOL              needLockOffset;
@property (nonatomic, strong) XDPagesTitleBar  *titleBar;
@property (nonatomic, strong) XDPagesConfig    *config;
@property (nonatomic, assign) XDPagesPullStyle  pagesPullStyle;
@end

@implementation XDPagesView
- (void)dealloc {
    NSLog(@"\n_____XDPagesView_____已释放\n");
}

- (instancetype)initWithFrame:(CGRect)frame config:(XDPagesConfig *)config style:(XDPagesPullStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.mainLock = [XDPagesValueLock lock];
        self.config = config ? config : [XDPagesConfig config];
        _pagesPullStyle = style;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createUI];
        });
    }
    return self;
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
        weakSelf.titleBar.refreshTitles(titles);
    }];
}

//标题可变动高度
- (CGFloat)headerVerticalCanChangedSpace {
    CGFloat margin = _config.titleBarMarginTop > CGRectGetHeight(self.pagesHeader.bounds) ? CGRectGetHeight(self.pagesHeader.bounds) : _config.titleBarMarginTop;
    return CGRectGetHeight(self.pagesHeader.bounds)-margin-ADJUSTVALUE;
}

//当竖直滚动时禁止横向滚动，由于此时仍需要手势共享，所以只能关闭横向滚动的scrollEnabled
- (void)pagesContainerScrollEnable:(BOOL)enabel {
    if (self.pagesContainer && self.pagesContainer.scrollEnabled != enabel && self.config.pagesSlideEnable) {
        self.pagesContainer.scrollEnabled = enabel;
    }
}

//是否锁定主列表偏移
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
    CGFloat margin = _config.titleBarMarginTop > CGRectGetHeight(self.pagesHeader.bounds) ? CGRectGetHeight(self.pagesHeader.bounds) : _config.titleBarMarginTop;
    return CGRectGetHeight(self.mainTable.bounds) - self.mainTable.sectionHeaderHeight - margin;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _config.needTitleBar ? self.titleBar : nil;
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
    if (scrollView.contentOffset.y > [self headerVerticalCanChangedSpace]) {
        scrollView.contentOffset = CGPointMake(0, [self headerVerticalCanChangedSpace]);
    }
    
    if (_needLockOffset && _mainTable.gesturePublic) {
        CGFloat offsety = [self lockMainTableAtOffsety:scrollView.contentOffset.y needLock:YES];
        if (offsety >= -ADJUSTVALUE) {
            scrollView.contentOffset = CGPointMake(0, offsety);
        } else {
            [self lockMainTableAtOffsety:scrollView.contentOffset.y needLock:NO];
        }
    } else {
        [self lockMainTableAtOffsety:scrollView.contentOffset.y needLock:NO];
    }

    if ([self.delegate respondsToSelector:@selector(xd_pagesViewVerticalScrollOffsetxChanged:)]) {
        CGFloat offy = scrollView.contentOffset.y;
        offy = offy == [self headerVerticalCanChangedSpace] ? 0 : offy;
        [self.delegate xd_pagesViewVerticalScrollOffsetxChanged:offy];
    }
}

//以下代理用于判断mainTable是否在滚动状态
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
- (void)title_tapAtIndex:(NSInteger)index {
    [self.mainCell changeToPage:index animate:self.config.animateForPageChange];
}

#pragma mark -- cell_delegate
- (NSArray<NSString *> *)cell_allTitles {
    return [self.delegate xd_pagesViewPageTitles];
}

- (UIViewController *)cell_pagesViewChildControllerForIndex:(NSInteger)index title:(NSString *)title {
    return [self.delegate xd_pagesViewChildControllerToPagesView:self forIndex:index title:title];
}

- (CGFloat)cell_headerVerticalCanChangedSpace {
    return [self headerVerticalCanChangedSpace];
}

- (void)cell_pagesViewDidChangeToPageController:(UIViewController *const)pageController title:(NSString *)pageTitle pageIndex:(NSInteger)pageIndex {
    self.titleBar.currentFocusIndex(pageIndex);
    if ([self.delegate respondsToSelector:@selector(xd_pagesViewDidChangeToPageController:title:pageIndex:)]) {
        [self.delegate xd_pagesViewDidChangeToPageController:pageController title:pageTitle pageIndex:pageIndex];
    }
}

- (void)cell_pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx {
    if ([self.delegate respondsToSelector:@selector(xd_pagesViewHorizontalScrollOffsetxChanged:)]) {
        [self.delegate xd_pagesViewHorizontalScrollOffsetxChanged:changedx];
    }
}

- (void)cell_pagesViewSafeHorizontalScrollOffsetxChanged:(CGFloat)changedx currentPage:(NSInteger)page willShowPage:(NSInteger)willShowPage {
    [self.titleBar pagesViewHorizontalScrollOffsetxChanged:changedx
                                               currentPage:page
                                                willToPage:willShowPage
                                                     width:CGRectGetWidth(self.bounds)];
}

- (void)cell_mainTableNeedLock:(BOOL)need offsety:(CGFloat)y {
    if (_needLockOffset != need) {
        _needLockOffset = need;
        if (need) {
            _mainTable.contentOffset = CGPointMake(0, y);
            [self scrollViewDidScroll:_mainTable];
        }
    }
}

#pragma mark -- setter
- (void)setPagesHeader:(UIView *)pagesHeader {
    if (!pagesHeader) return;
    _pagesHeader = [self resetHeader:pagesHeader];
    _pagesHeader.frame = CGRectMake(0, 0, CGRectGetWidth(pagesHeader.bounds), [XDPagesTools adjustFloatValue:CGRectGetHeight(pagesHeader.bounds)]);
    if (_mainTable) {
        _mainTable.tableHeaderView = _pagesHeader;
        [_mainTable reloadData];
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
        _mainTable.tableHeaderView.userInteractionEnabled = _pagesHeader.userInteractionEnabled;
        _mainTable.showsVerticalScrollIndicator = NO;
        _mainTable.showsHorizontalScrollIndicator = NO;
        _mainTable.gesturePublic = YES;
        _mainTable.delegate = self;
        _mainTable.dataSource = self;
        _mainTable.scrollsToTop = NO;
        _mainTable.tableHeaderView = self.pagesHeader;
        _mainTable.backgroundColor = [UIColor clearColor];
        _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTable.bounces = self.pagesPullStyle == XDPagesPullOnCenter ? NO : YES;
        _mainTable.sectionHeaderHeight = _config.titleBarHeight;
        [XDPagesTools closeAdjustForScroll:_mainTable controller:[XDPagesTools viewControllerForView:self]];
        if (_refreshControl) {
            _mainTable.refreshControl = _refreshControl;
        }
    }
    return _mainTable;
}

- (XDPagesTitleBar *)titleBar {
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
    //上
    NSLayoutConstraint *relat_top = [NSLayoutConstraint
                                     constraintWithItem:self.mainTable
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1
                                     constant:-ADJUSTVALUE];
    //左
    NSLayoutConstraint *relat_led = [NSLayoutConstraint
                                     constraintWithItem:self.mainTable
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1
                                     constant:0];
    //下
    NSLayoutConstraint *relat_btm = [NSLayoutConstraint
                                     constraintWithItem:self.mainTable
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                     constant:0];
    //右
    NSLayoutConstraint *relat_tal = [NSLayoutConstraint
                                     constraintWithItem:self.mainTable
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                     constant:0];
    //约束
    [NSLayoutConstraint activateConstraints:@[relat_top, relat_led, relat_btm, relat_tal]];
}

//重新组织header
- (UIView *)resetHeader:(UIView *)header {
    if (_config.titleBarFitHeader) {
        _pagesHeader = [[UIView alloc]initWithFrame:header.bounds];
        [_pagesHeader addSubview:header];
        header.clipsToBounds = YES;
        header.translatesAutoresizingMaskIntoConstraints = NO;
        //上
        NSLayoutConstraint *relat_top = [NSLayoutConstraint
                                         constraintWithItem:header
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:_pagesHeader
                                         attribute:NSLayoutAttributeTop
                                         multiplier:1
                                         constant:0];
        //左
        NSLayoutConstraint *relat_led = [NSLayoutConstraint
                                         constraintWithItem:header
                                         attribute:NSLayoutAttributeLeading
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:_pagesHeader
                                         attribute:NSLayoutAttributeLeading
                                         multiplier:1
                                         constant:0];
        //下
        NSLayoutConstraint *relat_btm = [NSLayoutConstraint
                                         constraintWithItem:header
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:_pagesHeader
                                         attribute:NSLayoutAttributeBottom
                                         multiplier:1
                                         constant:_config.titleBarHeight];
        //右
        NSLayoutConstraint *relat_tal = [NSLayoutConstraint
                                         constraintWithItem:header
                                         attribute:NSLayoutAttributeTrailing
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:_pagesHeader
                                         attribute:NSLayoutAttributeTrailing
                                         multiplier:1
                                         constant:0];
        //约束
        [NSLayoutConstraint activateConstraints:@[relat_top, relat_led, relat_btm, relat_tal]];
    } else {
        _pagesHeader = header;
    }
    return _pagesHeader;
}

#pragma mark -- sys_method
//利用hittest在手势进入之前，判断手势不在container中时就关闭手势共享，目的：防止header中有滚动控件，造成共同滚动
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    CGPoint relative_point = [self.pagesContainer convertPoint:point fromView:self];
    if ([self.pagesContainer.layer containsPoint:relative_point]) {
        if (!self.mainTable.gesturePublic) self.mainTable.gesturePublic = YES;
        [self.mainCell setCurrentMainTalbelOffsety:_mainTable.contentOffset.y];
    } else {
        if (self.mainTable.gesturePublic) self.mainTable.gesturePublic = NO;
    }
    if (_mainTable.contentOffset.y >= [self headerVerticalCanChangedSpace]) {
        [self scrollViewDidScroll:_mainTable];
    }
    return view;
}

@end
