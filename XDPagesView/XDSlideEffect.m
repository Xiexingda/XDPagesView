//
//  XDSlideEffect.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/3/6.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDSlideEffect.h"

@implementation XDSlideEffect

// 下划线伸缩效果
- (void)slideLineScaleEffectForView:(UIView *)view attributes:(NSArray<UICollectionViewLayoutAttributes *> *)attributes currentPage:(NSInteger)cpage willPage:(NSInteger)wpage percent:(CGFloat)percent ratio:(CGFloat)ratio {
    
    if (attributes.count == 0) {
        view.hidden = YES;
        return;
    }
    
    if (view.isHidden) {
        view.hidden = NO;
    }
    
    UICollectionViewLayoutAttributes *c_attr = attributes[cpage];
    UICollectionViewLayoutAttributes *w_attr = attributes[wpage];
    CGFloat c_width = CGRectGetWidth(c_attr.bounds);
    CGFloat w_width = CGRectGetWidth(w_attr.bounds);
    
    // 换算后的一半
    CGFloat c_hf_width = c_width*ratio/2.0;
    CGFloat w_hf_widht = w_width*ratio/2.0;
    CGFloat distance = ((c_width + w_width)/2.0 + w_hf_widht - c_hf_width);
    CGRect c_frame = CGRectZero;
    
    if (cpage > wpage) {
        c_frame = CGRectMake(CGRectGetMidX(c_attr.frame)-c_hf_width-distance*percent,
                             CGRectGetMinY(view.frame),
                             c_hf_width*2+distance*percent,
                             CGRectGetHeight(view.bounds));
    } else {
        c_frame = CGRectMake(CGRectGetMidX(c_attr.frame)-c_hf_width,
                             CGRectGetMinY(view.frame),
                             c_hf_width*2+distance*percent,
                             CGRectGetHeight(view.bounds));
    }
    
    [view setFrame:c_frame];
}

// 下划线平移效果
- (void)slideLineTransEffectForView:(UIView *)view attributes:(NSArray<UICollectionViewLayoutAttributes *> *)attributes currentPage:(NSInteger)cpage willPage:(NSInteger)wpage percent:(CGFloat)percent ratio:(CGFloat)ratio {
    
    if (attributes.count == 0) {
        view.hidden = YES;
        return;
    }
    
    if (view.isHidden) {
        view.hidden = NO;
    }
    
    UICollectionViewLayoutAttributes *c_attr = attributes[cpage];
    UICollectionViewLayoutAttributes *w_attr = attributes[wpage];
    CGFloat c_width = CGRectGetWidth(c_attr.bounds);
    CGFloat w_width = CGRectGetWidth(w_attr.bounds);
    
    // 换算后的一半
    CGFloat c_hf_width = c_width*ratio/2.0;
    CGFloat w_hf_widht = w_width*ratio/2.0;
    CGFloat distance = ((c_width + w_width)/2.0 + w_hf_widht - c_hf_width);
    CGFloat d_value = (w_hf_widht-c_hf_width)*2;
    CGRect c_frame = CGRectZero;
    
    if (cpage > wpage) {
        // 因为不管向左还是向右，都是以左边为基准，所以向左变化时自身长度变化不会影响最终结果，无需要减去长度变化补偿
        c_frame = CGRectMake(CGRectGetMidX(c_attr.frame)-c_hf_width-distance*percent,
                             CGRectGetMinY(view.frame),
                             c_hf_width*2+d_value*percent,
                             CGRectGetHeight(view.bounds));
    } else {
        // 因为不管向左还是向右，都是以左边为基准，所以向右变化时自身长度变化会影响最终结果，需要减去长度变化补偿
        c_frame = CGRectMake(CGRectGetMidX(c_attr.frame)-c_hf_width+(distance-d_value)*percent,
                             CGRectGetMinY(view.frame),
                             c_hf_width*2+d_value*percent,
                             CGRectGetHeight(view.bounds));
    }
    
    [view setFrame:c_frame];
}

// 无滑动效果
- (void)slideLineNoneEffectForView:(UIView *)view attributes:(NSArray<UICollectionViewLayoutAttributes *> *)attributes currentPage:(NSInteger)cpage willPage:(NSInteger)wpage ratio:(CGFloat)ratio {
    
    if (attributes.count == 0) {
        view.hidden = YES;
        return;
    }
    
    if (view.isHidden) {
        view.hidden = NO;
    }
    
    if (cpage == wpage) {
        UICollectionViewLayoutAttributes *c_attr = attributes[cpage];
        CGFloat c_width = CGRectGetWidth(c_attr.bounds);
        
        // 换算后的一半
        CGFloat c_hf_width = c_width*ratio/2.0;
        CGRect c_frame = CGRectMake(CGRectGetMidX(c_attr.frame)-c_hf_width,
                                    CGRectGetMinY(view.frame),
                                    c_hf_width*2,
                                    CGRectGetHeight(view.bounds));
        
        [view setFrame:c_frame];
    }
}
@end
