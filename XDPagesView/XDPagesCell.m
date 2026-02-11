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

@property (nonatomic, assign) NSInteger willShowPage;   // 将要出现的页
@property (nonatomic, assign) NSInteger currentPage;    // 当前页
@property (nonatomic, assign) XDPagesPullStyle pagePullStyle;  // 风格
@property (nonatomic, assign) BOOL isRectChanging;      // 是否正在调整rect
@property (nonatomic, assign) BOOL skipLoop; //跳过当前loop
@property (nonatomic,   copy) void (^reloadToPageDelayBlock)(void);
@end
@implementation XDPagesCell
- (void)dealloc {
    [self clearKVO];
    [self.pagesCache clearPages];
    [self unregisterFromNotifications];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier contentController:(UIViewController *)controller delegate:(id<XDPagesCellDelegate>)delegate pagesPullStyle:(XDPagesPullStyle)pullStyle config:(XDPagesConfig *)config {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.config = config;
        self.delegate = delegate;
        self.pagePullStyle = pullStyle;
        self.childLock = [XDPagesValueLock lock];
        self.pagesCache.mainController = controller;
        self.pagesCache.maxCacheCount = config.maxCacheCount;
        _willShowPage = config.beginPage;
        _currentPage = config.beginPage;
        self.contentView.frame = self.frame;
        [self createUI];
        [self reloadToPage:config.beginPage finish:nil];
        [self registerForNotifications];
    }
    
    return self;
}

- (void)registerForNotifications {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(statusBarOrientationDidChange)
               name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
#pragma clang diagnostic pop
}

- (void)unregisterFromNotifications {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
#pragma clang diagnostic pop
}

- (void)statusBarOrientationDidChange {
    self.isRectChanging = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rectChangedToPage:self.currentPage];
        self.isRectChanging = NO;
        if (self.reloadToPageDelayBlock) {
            self.reloadToPageDelayBlock();
            self.reloadToPageDelayBlock = nil;
        }
    });
}

- (void)reloadConfigs {
    _pagesCache.maxCacheCount = _config.maxCacheCount;
    _pagesContainer.bounces = _config.pagesHorizontalBounce;
    _pagesContainer.scrollEnabled = _config.pagesSlideEnable;
    [self scrollViewDidScroll:_pagesContainer];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        [self setReloadToPageDelayBlock:^{
            [weakSelf rectChangedToPage:page];
            [weakSelf scrollViewDidScroll:weakSelf.pagesContainer];
            [weakSelf pageIndexDidChangedToPage:page];
        }];
        
        if (!weakSelf.isRectChanging) {
            if (weakSelf.reloadToPageDelayBlock) {
                weakSelf.reloadToPageDelayBlock();
                weakSelf.reloadToPageDelayBlock = nil;
            }
        }
    });
    
    if (finish) {
        finish(self.pagesCache.titles);
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
    
    NSArray<UIScrollView *>* childs = [self.pagesCache scrollViewsForTitle:self.pagesCache.titles[currentPage]];
    if (childs && childs.count) {
        for (UIScrollView *child in childs) {
            [child addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        }
        [self.pagesCache.kvoTitles addObject:self.pagesCache.titles[currentPage]];
    }
}

// 配置所有标题
- (void)configAllTitles {
    NSArray *allTitles = [self.delegate cell_pagesViewAllTitles];
    self.pagesCache.titles = allTitles;
    
    [self.pagesContainer setContentSize:CGSizeMake(allTitles.count * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
}

// 监听到rect变化，比如横屏
- (void)rectChangedToPage:(NSInteger)page {
    if (!CGRectEqualToRect(self.contentView.bounds, self.bounds)) {
        self.contentView.frame = self.frame;
    }
    
    [self.pagesContainer setContentSize:CGSizeMake(self.pagesCache.titles.count * CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    
    [self resetAllRect];
    
    [self changeToPage:page animate:NO];
}

// 重置所有rect
- (void)resetAllRect {
    [self layoutIfNeeded];
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
    NSInteger page_right = ceil(xValue/c_w);   // 右页

    if (_currentPage == page_left) {
        // 当前面在前面时，说明是往左滑动， 所以将要出现的是右边的子页（下一页）
        if (_willShowPage != page_right) {
            [self handleForPage:page_right];
        }
    }
    else if (_currentPage == page_right) {
        // 当前页在右面时，说明是往右滑动，所以将要出现的是左边的子页（上一页）
        if (_willShowPage != page_left) {
            [self handleForPage:page_left];
        }
    } 
    else if (_currentPage < page_left) {
        // 当前页超出左边界时说明切换到了新的一页
        [self pageIndexDidChangedToPage:page_right];
    }
    else if (_currentPage > page_right) {
        // 当前页超出右边界时说明切换到了新的一页
        [self pageIndexDidChangedToPage:page_left];
    }
}

// 页面已经更换处理
- (void)pageIndexDidChangedToPage:(NSInteger)page {
    if (!self.pagesCache.titles.count || _isRectChanging) return;
    self.currentPage = page;
    [self.pagesCache pageDidApearHandle:!_isRectChanging];
    
    NSString *c_title = self.pagesCache.titles[page];
    UIViewController *c_vc = [self.pagesCache controllerForTitle:c_title];
    
    [self.delegate cell_pagesViewDidChangeToPageController:c_vc
                                                     title:c_title
                                                 pageIndex:page];
}

// 是否锁定主列表偏移通知
- (void)mainTableLock:(BOOL)need offsety:(CGFloat)y {
    [self.delegate cell_mainTableNeedLock:need offsety:y];
}

#pragma mark -- kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
   
    UIScrollView *kvo_scroll = (UIScrollView *)object;
    
    // 手动拉动哪个滚动控件就把那个滚动控件作为当前滚动控件
    if (_currentKVOChild != kvo_scroll && kvo_scroll.isTracking) {
        [_childLock unlock];
        _skipLoop = NO;
        _currentKVOChild = kvo_scroll;
    }

    // 如果滚动的并非当前滚动控件就过滤掉
    if (_currentKVOChild != kvo_scroll) return;
    
    //跳过本次监听
    if (_skipLoop) return;
    
    CGFloat changeSpace = [self.delegate cell_headerVerticalCanChangedSpace];
    CGPoint oldPoint = [[change objectForKey:NSKeyValueChangeOldKey] CGPointValue];
    CGPoint newPoint = [[change objectForKey:NSKeyValueChangeNewKey] CGPointValue];
    
    if (oldPoint.y < newPoint.y) {
        /* 向上拉动
           所有模式的上拉逻辑是相同的
         */
        _mainOffsetStatic = _mainTable.contentOffset.y;
        
        if (_mainOffsetStatic < changeSpace) {
            if (newPoint.y >= 0) {
                [self mainTableLock:NO offsety:0];
                
                _skipLoop = YES;
                kvo_scroll.contentOffset = CGPointMake(0, [_childLock lockValue:oldPoint.y >= 0 ? oldPoint.y : 0]);
                _skipLoop = NO;
            } else {
                [_childLock unlock];
            }
        } else {
            [self mainTableLock:NO offsety:0];
            [_childLock unlock];
        }
    } 
    else if (oldPoint.y > newPoint.y) {
        /* 向下拉动 */
        [_childLock unlock];
        if (newPoint.y > 0) {
            if (_mainOffsetStatic >= 0) {
                [self mainTableLock:YES offsety:_mainOffsetStatic];
            } else {
                [self mainTableLock:NO offsety:0];
            }
        } else {
            [self mainTableLock:NO offsety:0];
            if (self.pagePullStyle == XDPagesPullOnCenter) {
                /*
                 子列表下拉逻辑
                 该逻辑下子列表偏移可小于0
                */
                
                if (self.mainTable.contentOffset.y > 0) {
                    _skipLoop = YES;
                    kvo_scroll.contentOffset = CGPointMake(0, 0);
                    _skipLoop = NO;
                }
            } else {
                /*
                顶部下拉逻辑
                该逻辑下子列表偏移不可小于0
                */
                
                _skipLoop = YES;
                kvo_scroll.contentOffset = CGPointMake(0, 0);
                _skipLoop = NO;
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
    self.mainTable.scrollEnabled = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.mainTable.scrollEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.mainTable.scrollEnabled = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.mainTable.scrollEnabled = YES;
}

#pragma mark -- getter
- (UIScrollView *)pagesContainer {
    if (!_pagesContainer) {
        _pagesContainer = [[UIScrollView alloc]initWithFrame:self.bounds];
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

#pragma mark -- UI
- (void)createUI {
    
    [self addSubview:self.pagesContainer];
    
    self.pagesContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *relat_top = [NSLayoutConstraint
                                     constraintWithItem:self.pagesContainer
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *relat_led = [NSLayoutConstraint
                                     constraintWithItem:self.pagesContainer
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *relat_btm = [NSLayoutConstraint
                                     constraintWithItem:self.pagesContainer
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *relat_tal = [NSLayoutConstraint
                                     constraintWithItem:self.pagesContainer
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                     constant:0];
    [NSLayoutConstraint activateConstraints:@[relat_top, relat_led, relat_btm, relat_tal]];
}
@end
