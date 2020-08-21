//
//  XDPagesCell.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/13.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesCell.h"
#import "XDPagesCache.h"
#import "XDPagesTools.h"
#import "XDPagesValueLock.h"

@interface XDPagesCell ()<UIScrollViewDelegate>
@property (nonatomic, weak) id <XDPagesCellDelegate> delegate;
@property (nonatomic,   weak) XDPagesTable *mainTable;              // 主列表
@property (nonatomic, strong) UIScrollView *pagesContainer;         // 子列表容器
@property (nonatomic, strong) XDPagesConfig *config;                // 配置管理
@property (nonatomic, strong) XDPagesCache *pagesCache;             // 缓存管理
@property (nonatomic, strong) XDPagesValueLock *childLock;          // 子列表偏移锁
@property (nonatomic,   weak) UIScrollView *currentChild;           // 当前子列表

@property (nonatomic, assign) NSInteger willShowPage;   // 将要出现的页
@property (nonatomic, assign) NSInteger currentPage;    // 当前页
@property (nonatomic, assign) CGFloat mainOffsetStatic; // 主table锁定偏移量
@property (nonatomic, assign) CGFloat childOffsetStatic;// 子table锁定偏移量
@property (nonatomic, assign) NSInteger pagePullStyle;  // 风格
@property (nonatomic, assign) BOOL isRectChanging;      // 是否正在调整rect
@property (nonatomic, assign) CGFloat const adjustValue;// 调整值
@end
@implementation XDPagesCell
- (void)dealloc {
    [self clearKVO];
    [self.pagesCache clearPages];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier contentController:(UIViewController *)controller delegate:(id<XDPagesCellDelegate>)delegate pagesPullStyle:(NSInteger)pullStyle config:(XDPagesConfig *)config adjustValue:(CGFloat)adjustValue {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.adjustValue = adjustValue;
        self.config = config;
        self.delegate = delegate;
        self.pagePullStyle = pullStyle;
        self.childLock = [XDPagesValueLock lock];
        self.pagesCache.mainController = controller;
        self.pagesCache.maxCacheCount = config.maxCacheCount;
        _willShowPage = config.beginPage;
        _currentPage = config.beginPage;
 
        [self createUI];
        [self reloadToPage:config.beginPage finish:nil];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(self.contentView.bounds, self.pagesContainer.bounds)) {
        self.isRectChanging = YES;
        [self rectChanged];
        self.isRectChanging = NO;
    }
}

// 互换通道，使内外都拿到彼此的对象去做响应控制
- (UIScrollView *)exchangeChannelOfPagesContainerAndMainTable:(XDPagesTable *)mainTable {
    
    self.mainTable = mainTable;
    
    return self.pagesContainer;
}

// 刷新并跳到对应页
- (void)reloadToPage:(NSInteger)page finish:(void(^)(NSArray<NSString *>* titles))finish {
    [self clearKVO];
    
    NSArray <NSString *>*old_titles = [self.pagesCache.titles copy];
    
    [self configAllTitles];
    
    // 找到所有原标题组在新标题组中被去掉的标题，并删除对应的页
    [[XDPagesTools canceledTitlesInNewTitles:self.pagesCache.titles comparedOldTitles:old_titles] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.pagesCache cancelPageForTitle:obj];
    }];
    
    [self resetAllRect];
    
    if (finish) {
        finish(self.pagesCache.titles);
    }
    
    [self changeToPage:page animate:NO];
    
    if (self.pagesCache.titles.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollViewDidScroll:self.pagesContainer];
            [self pageIndexDidChangedToPage:page];
        });
    }
}

// 清除监听
- (void)clearKVO {
    while (self.pagesCache.kvoTitles.count) {
        for (UIScrollView *child in [self.pagesCache scrollViewsForTitle:self.pagesCache.kvoTitles.lastObject]) {
            [child removeObserver:self forKeyPath:@"contentOffset"];
        }
        
        [self.pagesCache.kvoTitles removeLastObject];
    }
}

// 更换kvo监听
- (void)setKVOForCurrentPage:(NSInteger)currentPage {
    if (self.pagesCache.titles.count == 0) return;
    
    [self clearKVO];
    
    for (UIScrollView *child in [self.pagesCache scrollViewsForTitle:self.pagesCache.titles[currentPage]]) {
        [child addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    }
    
    [self.pagesCache.kvoTitles addObject:self.pagesCache.titles[currentPage]];
}

// 配置所有标题
- (void)configAllTitles {
    NSArray *allTitles = [self.delegate cell_allTitles];
    self.pagesCache.titles = allTitles;
    
    [self.pagesContainer setContentSize:CGSizeMake(allTitles.count * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    
}

// 监听到rect变化，比如横屏
- (void)rectChanged {
    self.pagesContainer.bounds = self.contentView.bounds;
    [self.pagesContainer setContentSize:CGSizeMake(self.pagesCache.titles.count * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    
    [self resetAllRect];
    
    [self changeToPage:self.currentPage animate:NO];
}

// 重置所有rect
- (void)resetAllRect {
    [self.pagesCache.titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setRectForPage:idx];
    }];
}

// 设置当前位置的view的frame
- (void)setRectForPage:(NSInteger)page {
    
    UIView *c_view = [self.pagesCache viewForTitle:self.pagesCache.titles[page]];
    
    if (c_view) {
        CGRect c_frame = self.bounds;
        c_frame.origin.x = page*CGRectGetWidth(self.bounds);
        [c_view setFrame:c_frame];
        
        if (![c_view isDescendantOfView:self.pagesContainer]) {
            [self.pagesContainer addSubview:c_view];
        }
    }
}

// 添加页面处理
- (void)handleForPage:(NSInteger)page {
    if (!self.pagesCache.titles.count) return;
    
    _willShowPage = page;
    
    NSString *c_title = self.pagesCache.titles[page];
    
    UIViewController *childController = [self.delegate cell_pagesViewChildControllerForIndex:page title:c_title];
    
    /*
     验证缓存，这里有个很实用的技巧，
     为了提高性能，用双链表去管理子控制器，
     通过LRU算法实现其生命周期函数的调用
     */
    if (childController == [self dequeueReusablePageForIndex:page]) {
        [self.pagesCache setPage:childController title:c_title];
    } else {
        [self.pagesCache cancelPageForTitle:c_title];
        [self.pagesCache setPage:childController title:c_title];
        [self setRectForPage:page];
    }
    
    [self.pagesCache pageWillAppearHandle:!_isRectChanging];
}

- (void)changeToPage:(NSInteger)page animate:(BOOL)animate {
    
    NSAssert((page>=0&&page<self.pagesCache.titles.count || !self.pagesCache.titles.count), @"索引越界了");
    
    animate = animate ? (ABS(self.currentPage - page) == 1 ? YES : NO) : animate;
    
    [self handleForPage:page];
    
    [self.pagesContainer setContentOffset:CGPointMake(page*self.bounds.size.width, 0) animated:animate];
}

- (UIViewController *)dequeueReusablePageForIndex:(NSInteger)index {
    if (!self.pagesCache.titles.count) return nil;
    
    NSAssert((index>=0&&index<self.pagesCache.titles.count), @"索引越界了");
    
    NSString *title = self.pagesCache.titles[index];
    
    return [self.pagesCache controllerForTitle:title];
}

// 页面更换算法
- (void)pageAppearanceHandleByScrollXvalue:(CGFloat)xValue {
    CGFloat c_w = CGRectGetWidth(self.bounds);   // 当前页宽
    NSInteger page_left = floor(xValue/c_w);     // 左页
    NSInteger page_right   = ceil(xValue/c_w);   // 右页

    // 当前页超出左右边界时说明切换到了新的一页
    if (_currentPage < page_left) {
        [self pageIndexDidChangedToPage:page_left];
        
    } else if (_currentPage > page_right) {
        [self pageIndexDidChangedToPage:page_right];
    }

    // 当前面在前面时，说明是往左滑动， 所以将要出现的是右边的子页（下一页）
    if (_currentPage == page_left) {
        if (_willShowPage != page_right) {
            [self handleForPage:page_right];
        }
    // 当前页在右面时，说明是往右滑动，所以将要出现的是左边的子页（上一页）
    } else if (_currentPage == page_right) {
        if (_willShowPage != page_left) {
            [self handleForPage:page_left];
        }
    }
}

// 页面已经更换处理
- (void)pageIndexDidChangedToPage:(NSInteger)page {
    if (!self.pagesCache.titles.count) return;
    
    self.currentPage = page;
    
    // 如果本页没有滚动控件就解锁所有滚动相关的锁定
    if (![self.pagesCache scrollViewsForTitle:self.pagesCache.titles[page]]) {
        [self lockChildTableAtOffsety:0 needLock:NO lock:_childLock];
        [self mainTableLock:NO offsety:0];
        [self.delegate cell_currentPageScollEnable:NO];
    } else {
        [self.delegate cell_currentPageScollEnable:YES];
    }
    
    [self.pagesCache pageDidApearHandle:!_isRectChanging];
    
    NSString *c_title = self.pagesCache.titles[page];
    UIViewController *c_vc = [self.pagesCache controllerForTitle:c_title];
    
    [self.delegate cell_pagesViewDidChangeToPageController:c_vc
                                                     title:c_title
                                                 pageIndex:page];
}

// 返回顶端边距，由于11加入了safeArea的概念，所以11后用adjustedContentInset计算
- (CGFloat)topOfScrollView:(UIScrollView *)scrollView {
    if (@available(iOS 11.0, *)) {
        return -scrollView.adjustedContentInset.top;
    }
    
    return -scrollView.contentInset.top;
}

// 是否锁定主列表偏移通知
- (void)mainTableLock:(BOOL)need offsety:(CGFloat)y {
    [self.delegate cell_mainTableNeedLock:need offsety:y];
}

// 是否锁定子表偏移
- (CGFloat)lockChildTableAtOffsety:(CGFloat)y needLock:(BOOL)need lock:(XDPagesValueLock *)lock {
    
    CGFloat offsety = [lock value:y lock:need];
    
    return offsety;
}

// 当横向滚动时不需要手势共享，达到禁止一切竖直滚动
- (void)mainTabelNeedGesturePublick:(BOOL)publick {
    if (self.mainTable && self.mainTable.gesturePublic != publick) {
        self.mainTable.gesturePublic = publick;
    }
}

#pragma mark -- kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
   
    UIScrollView *kvo_scroll = (UIScrollView *)object;
    
    // 手动拉动哪个滚动控件就把那个滚动控件作为当前滚动控件
    if (_currentChild != kvo_scroll && kvo_scroll.isTracking) {
        [self lockChildTableAtOffsety:0 needLock:NO lock:_childLock];
        _currentChild = kvo_scroll;
    }

    // 如果滚动的并非当前滚动控件就过滤掉
    if (_currentChild != kvo_scroll) return;
    
    CGFloat headerHeight = [self.delegate cell_headerVerticalCanChangedSpace];
    CGPoint oldPoint = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
    CGPoint newPoint = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
    
    /*
     根据不同下拉类型分别实现各自逻辑，这里有个取巧的地方，
     就是在向上或者向下拉动过程中去处理，屏蔽掉静止状态，
     否则会因为强行修改contentoffset造成死循环
     */
    
    if (self.pagePullStyle == 0) {
        
        /*
        顶部下拉逻辑
        该逻辑下子列表偏移不可小于0
        */
        
        if (oldPoint.y < newPoint.y && newPoint.y != _childOffsetStatic) {
            
            /* 向上拉动 */
            
            _childOffsetStatic = newPoint.y;
            _mainOffsetStatic = _mainTable.contentOffset.y;
            
            if (self.mainTable.contentOffset.y < headerHeight) {
                
                [self mainTableLock:NO offsety:0];
                
                _childOffsetStatic = [self lockChildTableAtOffsety:(oldPoint.y > self.adjustValue ? oldPoint.y : self.adjustValue) needLock:YES lock:_childLock];
                kvo_scroll.contentOffset = CGPointMake(0, _childOffsetStatic);
                
            } else {
                [self lockChildTableAtOffsety:newPoint.y needLock:NO lock:_childLock];
            }
            
        } else if (oldPoint.y > newPoint.y && newPoint.y != _childOffsetStatic) {
            
            /* 向下拉动 */
            
            _childOffsetStatic = newPoint.y;
            
            [self lockChildTableAtOffsety:newPoint.y needLock:NO lock:_childLock];
            
            if (newPoint.y > 0) {
                
                if (_mainOffsetStatic >= 0) {
                    [self mainTableLock:YES offsety:_mainOffsetStatic];
                }
                
            } else {
                
                [self mainTableLock:NO offsety:0];
                
                CGFloat adjust = (kvo_scroll.contentSize.height >= self.bounds.size.height+self.adjustValue) ? self.adjustValue : 0;
                
                _childOffsetStatic = [self topOfScrollView:kvo_scroll] + adjust;
                
                kvo_scroll.contentOffset = CGPointMake(0, [self topOfScrollView:kvo_scroll] + adjust);
            }
        }
        
    } else if (self.pagePullStyle == 1) {
        
        /*
        列表下拉逻辑
        该逻辑下子列表偏移会小于0
        */
        
        if (oldPoint.y < newPoint.y && newPoint.y != _childOffsetStatic) {
            
            /* 向上拉动 */

            _childOffsetStatic = newPoint.y;
            _mainOffsetStatic = _mainTable.contentOffset.y;
            
            if (self.mainTable.contentOffset.y < headerHeight) {
                if (newPoint.y > 0) {
                    
                    [self mainTableLock:NO offsety:0];
                    
                    _childOffsetStatic = [self lockChildTableAtOffsety:(oldPoint.y > self.adjustValue ? oldPoint.y : self.adjustValue) needLock:YES lock:_childLock];
                    kvo_scroll.contentOffset = CGPointMake(0, _childOffsetStatic);
                } else {
                    
                    /*
                     列表下拉，所以当子列表偏移小于0，子列表不在锁定，但此时header触顶并锁定
                     */
                    [self lockChildTableAtOffsety:newPoint.y needLock:NO lock:_childLock];
                    [self mainTableLock:YES offsety:[self topOfScrollView:_mainTable]];
                }
            } else {
                [self lockChildTableAtOffsety:newPoint.y needLock:NO lock:_childLock];
            }
            
        } else if (oldPoint.y > newPoint.y && newPoint.y != _childOffsetStatic) {
            
            /* 向下拉动 */

            _childOffsetStatic = newPoint.y;
            
            [self lockChildTableAtOffsety:newPoint.y needLock:NO lock:_childLock];
            
            if (newPoint.y > 0) {
                
                if (_mainOffsetStatic >= 0) {
                    [self mainTableLock:YES offsety:_mainOffsetStatic];
                }
                
            } else {
                
                [self mainTableLock:NO offsety:0];
                
                if (self.mainTable.contentOffset.y > 0) {
                    
                    CGFloat adjust = (kvo_scroll.contentSize.height >= self.bounds.size.height+self.adjustValue) ? self.adjustValue : 0;
                    
                    _childOffsetStatic = [self topOfScrollView:kvo_scroll] + adjust;
                    kvo_scroll.contentOffset = CGPointMake(0, [self topOfScrollView:kvo_scroll] + adjust);
                }
            }
        }
    }
}

#pragma mark -- scroll_delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x <= scrollView.contentSize.width-scrollView.bounds.size.width) {
        
        [self pageAppearanceHandleByScrollXvalue:scrollView.contentOffset.x];
        
        [self.delegate cell_pagesViewSafeHorizontalScrollOffsetxChanged:scrollView.contentOffset.x currentPage:self.currentPage willShowPage:self.willShowPage];
    }

    [self.delegate cell_pagesViewHorizontalScrollOffsetxChanged:scrollView.contentOffset.x currentPage:self.currentPage willShowPage:self.willShowPage];
}

//以下代理用于判断pagesContainer是否在滚动状态
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self mainTabelNeedGesturePublick:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self mainTabelNeedGesturePublick:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self mainTabelNeedGesturePublick:YES];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self mainTabelNeedGesturePublick:YES];
}

#pragma mark -- getter
- (UIScrollView *)pagesContainer {
    if (!_pagesContainer) {
        _pagesContainer = [[UIScrollView alloc]initWithFrame:self.contentView.bounds];
        _pagesContainer.pagingEnabled = YES;
        _pagesContainer.showsVerticalScrollIndicator = NO;
        _pagesContainer.showsHorizontalScrollIndicator = NO;
        _pagesContainer.delegate = self;
        _pagesContainer.backgroundColor = [UIColor clearColor];
        _pagesContainer.bounces = _config.pagesHorizontalBounce;
        _pagesContainer.scrollEnabled = _config.pagesSlideEnable;
        [XDPagesTools closeAdjustForScroll:_pagesContainer controller:nil];
    }
    
    return _pagesContainer;
}

- (XDPagesCache *)pagesCache {
    if (!_pagesCache) {
        _pagesCache = [XDPagesCache cache];
    }
    
    return _pagesCache;
}

#pragma mark -- setter
- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self setKVOForCurrentPage:currentPage];
}

- (void)setCurrentMainTalbelOffsety:(CGFloat)currentMainTalbelOffsety {
    _mainOffsetStatic = currentMainTalbelOffsety;
}

#pragma mark -- UI
- (void)createUI {
    
    [self.contentView addSubview:self.pagesContainer];
    
    self.pagesContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *relat_top = [NSLayoutConstraint
                                     constraintWithItem:self.pagesContainer
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *relat_led = [NSLayoutConstraint
                                     constraintWithItem:self.pagesContainer
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *relat_btm = [NSLayoutConstraint
                                     constraintWithItem:self.pagesContainer
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *relat_tal = [NSLayoutConstraint
                                     constraintWithItem:self.pagesContainer
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                     constant:0];
    [NSLayoutConstraint activateConstraints:@[relat_top, relat_led, relat_btm, relat_tal]];
}
@end
