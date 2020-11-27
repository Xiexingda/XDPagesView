//
//  XDPagesCache.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/16.
//  Copyright © 2020 xie. All rights reserved.
//  缓存管理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct {
    NSInteger badgeNumber;
    UIColor *badgeColor;
} XDBADGE;

@interface XDPagesCache : NSObject
@property (nonatomic,   weak) UIViewController *mainController;     // 主控制器
@property (nonatomic, strong) NSArray <NSString *>*titles;          // 所有标题
@property (nonatomic, strong) NSMutableArray<NSString *> *kvoTitles;// 当前所有添加了观察者的对象标题
@property (nonatomic, assign) NSInteger maxCacheCount;              // 最大缓存个数
+ (instancetype)cache;

- (void)setPage:(UIViewController *)page title:(NSString *)title;
- (void)cancelPageForTitle:(NSString *)title;
- (void)clearPages;

// will动作，包括willAppear willDisAppear
- (void)pageWillAppearHandle:(BOOL)need;
// did动作，包括didAppear didDisAppear
- (void)pageDidApearHandle:(BOOL)need;

- (UIView *)viewForTitle:(NSString *)title;
- (UIViewController *)controllerForTitle:(NSString *)title;
- (NSArray <UIScrollView *>*)scrollViewsForTitle:(NSString *)title;

// 设置未读(number用于之后数字扩展)
- (void)setBadgeForIndex:(NSInteger)idx number:(NSInteger)number color:(UIColor *)color;

//未读数
- (XDBADGE)badgeNumberForIndex:(NSInteger)idx;
@end
