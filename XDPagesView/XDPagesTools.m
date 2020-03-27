//
//  XDPagesTools.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/16.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesTools.h"

@implementation XDPagesTools
+ (UIViewController *)viewControllerForView:(UIView *)view {
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    
    return nil;
}

// 关闭自适应
+ (void)closeAdjustForScroll:(UIScrollView *)scrollView controller:(UIViewController *)controller {
    if (@available(iOS 11.0, *)) {
        if (scrollView) {
            if (scrollView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
                scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
    } else {
        if (controller) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if (controller.automaticallyAdjustsScrollViewInsets) {
                controller.automaticallyAdjustsScrollViewInsets = NO;
            }
#pragma clang diagnostic pop
        }
    }
}

// 由于float值是非精确的，设置粒度为0.5
+ (CGFloat)adjustFloatValue:(CGFloat)value {
    return (floor(value)+ceil(value))/2.0;
}

+ (CGFloat)adjustItemWidthByString:(NSString *)str font:(CGFloat)font baseSize:(CGSize)baseSize {
    CGSize c_size = [str boundingRectWithSize:baseSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size;
    return c_size.width;
}

+ (BOOL)hasRepeatItemInArray:(NSArray *)array {
    NSMutableSet *setArry = [NSMutableSet setWithArray:array];
    return (array.count > setArry.count ? YES : NO);
}

+ (NSArray<NSString *> *)canceledTitlesInNewTitles:(NSArray<NSString *> *)newTitles comparedOldTitles:(NSArray<NSString *> *)oldTitles {
    
    NSMutableSet *oldSet = [NSMutableSet setWithArray:oldTitles];
    NSMutableSet *newSet = [NSMutableSet setWithArray:newTitles];
    
    [newSet intersectSet:oldSet];
    [oldSet minusSet:newSet];
    
    return oldSet.allObjects;
}
@end
