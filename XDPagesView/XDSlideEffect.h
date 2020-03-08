//
//  XDSlideEffect.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/3/6.
//  Copyright © 2020 xie. All rights reserved.
//  下划线滑动效果管理

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XDSlideEffect : NSObject

/// 下划线伸缩效果
/// @param view 展示动画的view
/// @param attributes 当前所有标题的布局
/// @param cpage 当前页
/// @param wpage 目标页
/// @param percent 翻页进度
/// @param ratio 下划线相对宽度的百分比
- (void)slideLineScaleEffectForView:(UIView *)view attributes:(NSArray <UICollectionViewLayoutAttributes *>*)attributes currentPage:(NSInteger)cpage willPage:(NSInteger)wpage percent:(CGFloat)percent ratio:(CGFloat)ratio;

/// 下划线平移效果
/// @param view 展示动画的view
/// @param attributes 当前所有标题的布局
/// @param cpage 当前页
/// @param wpage 目标页
/// @param percent 翻页进度
/// @param ratio 下划线相对宽度的百分比
- (void)slideLineTransEffectForView:(UIView *)view attributes:(NSArray <UICollectionViewLayoutAttributes *>*)attributes currentPage:(NSInteger)cpage willPage:(NSInteger)wpage percent:(CGFloat)percent ratio:(CGFloat)ratio;

/// 无滑动效果
/// @param view 展示动画的view
/// @param attributes 当前所有标题的布局
/// @param cpage 当前页
/// @param wpage 目标页
/// @param ratio 下划线相对宽度的百分比
- (void)slideLineNoneEffectForView:(UIView *)view attributes:(NSArray <UICollectionViewLayoutAttributes *>*)attributes currentPage:(NSInteger)cpage willPage:(NSInteger)wpage ratio:(CGFloat)ratio;
@end

