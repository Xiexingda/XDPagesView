//
//  XDPagesTitle.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/29.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesTitle.h"

@interface XDPagesTitle ()
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIImageView *backImage;
@end

typedef struct {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
} XDRGB;

NS_INLINE XDRGB
XDRGBMake(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
    XDRGB rgb;
    rgb.red = red;
    rgb.green = green;
    rgb.blue = blue;
    rgb.alpha = alpha;
    return rgb;
}

@implementation XDPagesTitle
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self creatItem];
    }
    
    return self;
}

- (void)configTitleByTitle:(NSString *)title focusIdx:(NSInteger)fidx config:(XDPagesConfig *)config indexPath:(NSIndexPath *)indexPath {
    
    self.title.text = title;
    
    if (fidx == indexPath.row) {
        // 当前选中
        self.backImage.backgroundColor = config.titleItemBackHightlightColor;
        self.backImage.image = config.titleItemBackHightlightImage;
        self.title.backgroundColor = config.titleItemBackHightlightColor;
        self.title.font = [UIFont systemFontOfSize:config.titleHightlightFont];
        self.title.textColor = config.titleTextHightlightColor;
    
    } else {
        // 未选中
        self.backImage.backgroundColor = config.titleItemBackColor;
        self.backImage.image = config.titleItemBackImage;
        self.title.backgroundColor = config.titleItemBackColor;
        self.title.font = [UIFont systemFontOfSize:config.titleFont];
        self.title.textColor = config.titleTextColor;
    }
}

- (void)gradualUpByConfig:(XDPagesConfig *)config percent:(CGFloat)percent {
    // 标题渐变
    CGFloat d_value = config.titleHightlightFont-config.titleFont;
    self.title.font = [UIFont systemFontOfSize:config.titleFont+d_value*percent];
    
    // 标题颜色渐变
    XDRGB c_RGB = [self getRGBValueFromColor:config.titleTextColor];
    XDRGB w_RGB = [self getRGBValueFromColor:config.titleTextHightlightColor];
    CGFloat g_red = c_RGB.red+(w_RGB.red-c_RGB.red)*percent;
    CGFloat g_green = c_RGB.green+(w_RGB.green-c_RGB.green)*percent;
    CGFloat g_blue = c_RGB.blue+(w_RGB.blue-c_RGB.blue)*percent;
    
    self.title.textColor = [[UIColor alloc]initWithRed:g_red green:g_green blue:g_blue alpha:1];
}

- (void)gradualDownByConfig:(XDPagesConfig *)config percent:(CGFloat)percent {
    // 标题渐变
    CGFloat d_value = config.titleHightlightFont-config.titleFont;
    self.title.font = [UIFont systemFontOfSize:config.titleHightlightFont-d_value*percent];
    
    // 标题颜色渐变
    XDRGB c_RGB = [self getRGBValueFromColor:config.titleTextColor];
    XDRGB w_RGB = [self getRGBValueFromColor:config.titleTextHightlightColor];
    CGFloat g_red = w_RGB.red-(w_RGB.red-c_RGB.red)*percent;
    CGFloat g_green = w_RGB.green-(w_RGB.green-c_RGB.green)*percent;
    CGFloat g_blue = w_RGB.blue-(w_RGB.blue-c_RGB.blue)*percent;
   
    self.title.textColor = [[UIColor alloc]initWithRed:g_red green:g_green blue:g_blue alpha:1];
}

// 颜色RGB值
- (XDRGB)getRGBValueFromColor:(UIColor *)color {
    
    CGFloat red   = 0.0;
    CGFloat green = 0.0;
    CGFloat blue  = 0.0;
    CGFloat alpha = 1.0;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return XDRGBMake(red, green, blue, alpha);
}

#pragma mark -- getter
- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc]initWithFrame:self.bounds];
        _title.backgroundColor = [UIColor clearColor];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.textAlignment = NSTextAlignmentCenter;
    }
    
    return _title;
}

- (UIImageView *)backImage {
    if (!_backImage) {
        _backImage = [[UIImageView alloc]initWithFrame:self.bounds];
        _backImage.contentMode = UIViewContentModeScaleAspectFill;
        _backImage.userInteractionEnabled = YES;
    }
    
    return _backImage;
}

#pragma mark -- UI
- (void)creatItem {
    
    [self.contentView addSubview:self.backImage];
    [self.contentView addSubview:self.title];
    
    self.backImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    
    // backImage
    NSLayoutConstraint *back_top = [NSLayoutConstraint
                                    constraintWithItem:self.backImage
                                    attribute:NSLayoutAttributeTop
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                    attribute:NSLayoutAttributeTop
                                    multiplier:1
                                    constant:0];
    NSLayoutConstraint *back_lef = [NSLayoutConstraint
                                    constraintWithItem:self.backImage
                                    attribute:NSLayoutAttributeLeading
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                    attribute:NSLayoutAttributeLeading
                                    multiplier:1
                                    constant:0];
    NSLayoutConstraint *back_btm = [NSLayoutConstraint
                                    constraintWithItem:self.backImage
                                    attribute:NSLayoutAttributeBottom
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                    attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                    constant:0];
    NSLayoutConstraint *back_rit = [NSLayoutConstraint
                                    constraintWithItem:self.backImage
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.contentView
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1
                                    constant:0];
    [NSLayoutConstraint activateConstraints:@[back_top, back_lef, back_btm, back_rit]];
    
    // title
    NSLayoutConstraint *title_top = [NSLayoutConstraint
                                     constraintWithItem:self.title
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *title_lef = [NSLayoutConstraint
                                     constraintWithItem:self.title
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *title_btm = [NSLayoutConstraint
                                     constraintWithItem:self.title
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *title_rit = [NSLayoutConstraint
                                     constraintWithItem:self.title
                                     attribute:NSLayoutAttributeTrailing
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                     constant:0];
    [NSLayoutConstraint activateConstraints:@[title_top, title_lef, title_btm, title_rit]];
}
@end
