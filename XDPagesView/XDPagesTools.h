//
//  XDPagesTools.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/16.
//  Copyright © 2020 xie. All rights reserved.
//  工具

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XDPagesTools : NSObject
// 获取视图所在控制器
+ (UIViewController *)viewControllerForView:(UIView *)view;

// 关闭滚动控件自适应
+ (void)closeAdjustForScroll:(UIScrollView *)scrollView controller:(UIViewController *)controller;

// 由于float值是非精确的，设置粒度为0.5
+ (CGFloat)adjustFloatValue:(CGFloat)value;

// 根据文字大小计算宽度
+ (CGFloat)adjustItemWidthByString:(NSString *)str font:(CGFloat)font baseSize:(CGSize)baseSize;

// 检测数值中是否有重复项
+ (BOOL)hasRepeatItemInArray:(NSArray *)array;

// 找出老数组在新数组中被去掉的标题
+ (NSArray<NSString *>*)canceledTitlesInNewTitles:(NSArray<NSString *>*)newTitles comparedOldTitles:(NSArray<NSString *>*)oldTitles;
@end

