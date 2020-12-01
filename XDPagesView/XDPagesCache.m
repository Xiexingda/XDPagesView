//
//  XDPagesCache.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/16.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesCache.h"
#import "XDPagesMap.h"
#import <WebKit/WebKit.h>
#import "XDPagesTools.h"

#define IgnoreTag 5201314

NS_INLINE XDBADGE
XDBADGEMake(NSInteger number, UIColor *color) {
    XDBADGE badge;
    badge.badgeNumber = number;
    badge.badgeColor = color;
    return badge;
}

@interface XDPagesCache ()
@property (nonatomic, strong) XDPagesMap *map;
@property (nonatomic, strong) XDPagesMap *badgeMap;
@end
@implementation XDPagesCache
- (void)setMaxCacheCount:(NSInteger)maxCacheCount {
    _maxCacheCount = maxCacheCount >= 2 ? maxCacheCount : 2;
}
- (void)setTitles:(NSArray<NSString *> *)titles {
    NSAssert(![XDPagesTools hasRepeatItemInArray:titles], @"____XDPagesView___出现重复标题");
    _titles = titles;
}

+ (instancetype)cache {
    return [[self alloc]init];
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _kvoTitles = @[].mutableCopy;
        _map = [XDPagesMap map];
        _badgeMap = [XDPagesMap map];
    }
    
    return self;
}

- (void)setPage:(UIViewController *)page title:(NSString *)title {
    if (!page) return;
    
    XDPagesNode *node = [_map->mapDic objectForKey:title];
    
    if (node) {
        node->right += 1;
        [_map bringNodeToHeader:node];
    } else {
        node = [XDPagesNode node];
        node->key = title;
        node->controller = page;
        node->view = [self viewClipsBoundsForView:page.view];
        node->scrollViews = [self allNeedObserveScrollsInView:page.view];
        [_map insertNode:node];
        
        [node->scrollViews enumerateObjectsUsingBlock:^(UIScrollView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [XDPagesTools closeAdjustForScroll:obj controller:page];
        }];
    }
    
    [self surplusOfCaches:_maxCacheCount];
}

- (void)pageWillAppearHandle:(BOOL)need {
    if (!need) return;
    
    if (_map->header) {
        if (_map->header->right>=1) [_map->header->controller viewWillAppear:YES];
    }
    
    if (_map->header->next) {
        [_map->header->next->controller viewWillDisappear:YES];
    }
}

- (void)pageDidApearHandle:(BOOL)need {
    if (!need) return;
    
    if (_map->header) {
        // 添加到当前控制器
        NSAssert(_mainController, @"cache没有添加主控器");
        if (![_mainController.childViewControllers containsObject:_map->header->controller]) {
            [_mainController addChildViewController:_map->header->controller];
            [_map->header->controller didMoveToParentViewController:_mainController];
        }
        if (_map->header->right>=1)[_map->header->controller viewDidAppear:YES];
    }
    
    if (_map->header->next) {
        [_map->header->next->controller viewDidDisappear:YES];
        if ([_mainController.childViewControllers containsObject:_map->header->next->controller]) {
            [_map->header->next->controller willMoveToParentViewController:nil];
            [_map->header->next->controller removeFromParentViewController];
        }
    }
}

- (void)cancelPageForTitle:(NSString *)title {
    
    XDPagesNode *node = [_map->mapDic objectForKey:title];
    
    if (node) {
        [_map removeNode:node];
        node->scrollViews = nil;
        [node->view removeFromSuperview];
        [node->controller willMoveToParentViewController:nil];
        [node->controller removeFromParentViewController];
        node->controller = nil;
        node = nil;
    }
}

- (void)clearPages {
    [self surplusOfCaches:0];
}


- (UIView *)viewForTitle:(NSString *)title {
    
    XDPagesNode *node = [_map->mapDic objectForKey:title];
    
    if (node) {
        return node->view;
    }
    
    return nil;
}

- (UIViewController *)controllerForTitle:(NSString *)title {
    
    XDPagesNode *node = [_map->mapDic objectForKey:title];
    
    if (node) {
        return node->controller;
    }
    
    return nil;
}

- (NSArray<UIScrollView *> *)scrollViewsForTitle:(NSString *)title {
    
    XDPagesNode *node = [_map->mapDic objectForKey:title];
    
    if (node) {
        return node->scrollViews;
    }
    
    return nil;
}

// 使缓存剩余个数
- (void)surplusOfCaches:(NSInteger)count {
    while (_map->count > count) {
        XDPagesNode *cancelNode = [_map removeLastNode];
        cancelNode->scrollViews = nil;
        [cancelNode->view removeFromSuperview];
        [cancelNode->controller willMoveToParentViewController:nil];
        [cancelNode->controller removeFromParentViewController];
        cancelNode->controller = nil;
        cancelNode = nil;
    }
}

// 把控制器内的view进行剪裁，否则可能会因为设置背景造成view的bounds变化
- (UIView *)viewClipsBoundsForView:(UIView *)view {
    
    view.clipsToBounds = YES;
    
    return view;
}

// 找到所有符合的滚动控件
- (NSArray <UIScrollView *>*)allNeedObserveScrollsInView:(UIView *)view {
    
    __block NSMutableArray <UIScrollView *>*scrolls = @[].mutableCopy;
    
    if (view.tag != IgnoreTag) {
        [self subViewsInView:view matchView:^(UIScrollView *scroll) {
            if (scroll) {
                [scrolls addObject:scroll];
            }
        }];
    }
    
    return scrolls.count > 0 ? [scrolls copy] : nil;
}

// 遍历（对于嵌套的滚动控件，只监听父滚动控件）
- (void)subViewsInView:(UIView *)view matchView:(void(^)(UIScrollView *scroll))match {
    for (UIScrollView *child in view.subviews) {
        
        if (child.tag == IgnoreTag) continue;
        
        if ([child isKindOfClass:UIScrollView.class]) {
            if (match) {
                match(child);
            }
            continue;

        } else if ([child isKindOfClass:WKWebView.class]) {
            if (((WKWebView *)child).scrollView.tag != IgnoreTag) {
                if (match) {
                    match(((WKWebView *)child).scrollView);
                }
            };
            continue;
        }
        
        [self subViewsInView:child matchView:match];
    }
}

- (void)setBadgeForIndex:(NSInteger)idx number:(NSInteger)number color:(UIColor *)color {
    XDPagesNode *node = [_badgeMap->mapDic objectForKey:@(idx).stringValue];
    if (!node) {
        node = [XDPagesNode node];
        node->key = @(idx).stringValue;
        node->value = number>0?@(number):@(0);
        node->badgeColor = color;
        [_badgeMap insertNode:node];
    } else {
        node->value = number>0?@(number):@(0);
        node->badgeColor = color;
        [_badgeMap bringNodeToHeader:node];
    }
}

- (XDBADGE)badgeNumberForIndex:(NSInteger)idx {
    XDPagesNode *node = [_badgeMap->mapDic objectForKey:@(idx).stringValue];
    if (node) {
        return XDBADGEMake([node->value integerValue], node->badgeColor);
    }
    return XDBADGEMake(0, UIColor.clearColor);
}

@end
