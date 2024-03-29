//
//  XDPagesTitle.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/29.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesTitle.h"

@interface XDPagesTitle ()
@property (nonatomic, strong) XDPagesTitleLabel *title;
@property (nonatomic, strong) UIImageView *backImage;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIView *numberTip;
@property (nonatomic, strong) UILabel *tipNumerLabel;
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

- (void)configTitleByTitle:(NSString *)title focusIdx:(NSInteger)fidx config:(XDPagesConfig *)config badge:(XDBADGE)badge indexPath:(NSIndexPath *)indexPath {
    self.title.config = config;
    self.title.text = title;
    
    self.tipLabel.hidden = badge.badgeNumber > 0 ? NO : YES;
    self.numberTip.hidden = badge.badgeNumber > 0 ? NO : YES;
    
    if (badge.isNumber) {
        //以数字形式展示未读
        self.numberTip.backgroundColor = badge.badgeColor;
        self.tipNumerLabel.text = badge.badgeNumber > 99 ? @"99+" : @(badge.badgeNumber).stringValue;
        self.tipLabel.hidden = YES;
        [self layoutIfNeeded];
    } else {
        //以红点形式展示未读
        self.tipLabel.backgroundColor = badge.badgeColor;
        self.numberTip.hidden = YES;
        [self layoutIfNeeded];
    }
    
    if (fidx == indexPath.row) {
        // 当前选中
        self.backImage.backgroundColor = config.titleItemBackHightlightColor;
        self.backImage.image = config.titleItemBackHightlightImage;
        self.title.backgroundColor = config.titleItemBackHightlightColor;
        self.title.font = config.titleHightlightFont;
        self.title.textColor = config.titleTextHightlightColor;
    
    } else {
        // 未选中
        self.backImage.backgroundColor = config.titleItemBackColor;
        self.backImage.image = config.titleItemBackImage;
        self.title.backgroundColor = config.titleItemBackColor;
        self.title.font = config.titleFont;
        self.title.textColor = config.titleTextColor;
    }
}

- (void)gradualUpByConfig:(XDPagesConfig *)config percent:(CGFloat)percent {
    // 标题渐变
    CGFloat d_value = config.titleHightlightFont.pointSize-config.titleFont.pointSize;
    self.title.font = [UIFont systemFontOfSize:config.titleFont.pointSize + d_value*percent weight:[[config.titleHightlightFont.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute][UIFontWeightTrait] floatValue]];
    
    // 标题颜色渐变
    XDRGB c_RGB = [self getRGBValueFromColor:config.titleTextColor];
    XDRGB w_RGB = [self getRGBValueFromColor:config.titleTextHightlightColor];
    CGFloat g_red = c_RGB.red + (w_RGB.red - c_RGB.red) * percent;
    CGFloat g_green = c_RGB.green + (w_RGB.green - c_RGB.green) * percent;
    CGFloat g_blue = c_RGB.blue + (w_RGB.blue - c_RGB.blue) * percent;
    
    self.title.textColor = [[UIColor alloc]initWithRed:g_red green:g_green blue:g_blue alpha:1];
}

- (void)gradualDownByConfig:(XDPagesConfig *)config percent:(CGFloat)percent {
    // 标题渐变
    CGFloat d_value = config.titleHightlightFont.pointSize-config.titleFont.pointSize;
    self.title.font = [UIFont systemFontOfSize:config.titleHightlightFont.pointSize - d_value*percent weight:[[config.titleFont.fontDescriptor objectForKey:UIFontDescriptorTraitsAttribute][UIFontWeightTrait] floatValue]];
    
    // 标题颜色渐变
    XDRGB c_RGB = [self getRGBValueFromColor:config.titleTextColor];
    XDRGB w_RGB = [self getRGBValueFromColor:config.titleTextHightlightColor];
    CGFloat g_red = w_RGB.red - (w_RGB.red - c_RGB.red) * percent;
    CGFloat g_green = w_RGB.green - (w_RGB.green - c_RGB.green) * percent;
    CGFloat g_blue = w_RGB.blue - (w_RGB.blue - c_RGB.blue) * percent;
   
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
- (XDPagesTitleLabel *)title {
    if (!_title) {
        _title = [[XDPagesTitleLabel alloc]initWithFrame:self.bounds];
        _title.backgroundColor = [UIColor clearColor];
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

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
        _tipLabel.clipsToBounds = YES;
        _tipLabel.layer.cornerRadius = 4;
        _tipLabel.backgroundColor = UIColor.redColor;
        _tipLabel.hidden = YES;
    }
    
    return _tipLabel;
}

- (UILabel *)tipNumerLabel {
    if (!_tipNumerLabel) {
        _tipNumerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 16, 16)];
        _tipNumerLabel.backgroundColor = UIColor.clearColor;
        _tipNumerLabel.textAlignment = NSTextAlignmentCenter;
        _tipNumerLabel.textColor = UIColor.whiteColor;
        _tipNumerLabel.font = [UIFont systemFontOfSize:11.f];
    }
    
    return _tipNumerLabel;
}

- (UIView *)numberTip {
    if (!_numberTip) {
        _numberTip = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 16, 16)];
        _numberTip.clipsToBounds = YES;
        _numberTip.layer.cornerRadius = 8;
    }
    
    return _numberTip;
}

#pragma mark -- UI
- (void)creatItem {
    
    [self.contentView addSubview:self.backImage];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.tipLabel];
    [self.contentView addSubview:self.numberTip];
    [self.numberTip addSubview:self.tipNumerLabel];
    self.backImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    self.tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.tipNumerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.numberTip.translatesAutoresizingMaskIntoConstraints = NO;
    
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
                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
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
                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeTrailing
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *title_mid = [NSLayoutConstraint
                                     constraintWithItem:self.title
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.contentView
                                     attribute:NSLayoutAttributeCenterX
                                     multiplier:1
                                     constant:0];
    [NSLayoutConstraint activateConstraints:@[title_top, title_lef, title_btm, title_rit, title_mid]];
    
    [self redDotTipLayout];
    [self numberTipLayout];
}

- (void)redDotTipLayout {
    // tip for red dot type
    NSLayoutConstraint *tip_top = [NSLayoutConstraint
                                   constraintWithItem:self.tipLabel
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.contentView
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1
                                   constant:-6];
    NSLayoutConstraint *tip_lef = [NSLayoutConstraint
                                   constraintWithItem:self.tipLabel
                                   attribute:NSLayoutAttributeLeft
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.title
                                   attribute:NSLayoutAttributeRight
                                   multiplier:1
                                   constant:0];
    NSLayoutConstraint *tip_wid = [NSLayoutConstraint
                                   constraintWithItem:self.tipLabel
                                   attribute:NSLayoutAttributeWidth
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:1
                                   constant:8];
    NSLayoutConstraint *tip_hei = [NSLayoutConstraint
                                   constraintWithItem:self.tipLabel
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:1
                                   constant:8];
    [NSLayoutConstraint activateConstraints:@[tip_top, tip_lef, tip_wid, tip_hei]];
}

- (void)numberTipLayout {
    // tip for number type
    
    NSLayoutConstraint *lab_c_y = [NSLayoutConstraint
                                   constraintWithItem:self.tipNumerLabel
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.numberTip
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1
                                   constant:0];
    NSLayoutConstraint *lab_rig = [NSLayoutConstraint
                                   constraintWithItem:self.tipNumerLabel
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.numberTip
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1
                                   constant:-5];
    NSLayoutConstraint *lab_lef = [NSLayoutConstraint
                                   constraintWithItem:self.tipNumerLabel
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.numberTip
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1
                                   constant:5];
    NSLayoutConstraint *lab_wid = [NSLayoutConstraint
                                   constraintWithItem:self.tipNumerLabel
                                   attribute:NSLayoutAttributeWidth
                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:1
                                   constant:0];
    [NSLayoutConstraint activateConstraints:@[lab_c_y, lab_lef, lab_rig, lab_wid]];
    
    
    NSLayoutConstraint *tip_top = [NSLayoutConstraint
                                   constraintWithItem:self.numberTip
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.contentView
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1
                                   constant:-6];
    NSLayoutConstraint *tip_rig = [NSLayoutConstraint
                                   constraintWithItem:self.numberTip
                                   attribute:NSLayoutAttributeRight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.title
                                   attribute:NSLayoutAttributeRight
                                   multiplier:1
                                   constant:10];
    NSLayoutConstraint *tip_wid = [NSLayoutConstraint
                                   constraintWithItem:self.numberTip
                                   attribute:NSLayoutAttributeWidth
                                   relatedBy:NSLayoutRelationGreaterThanOrEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:1
                                   constant:16];
    NSLayoutConstraint *tip_hei = [NSLayoutConstraint
                                   constraintWithItem:self.numberTip
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                   multiplier:1
                                   constant:16];
    [NSLayoutConstraint activateConstraints:@[tip_top, tip_rig, tip_wid, tip_hei]];
}

@end

@implementation XDPagesTitleLabel

- (id)init {
    self = [super init];
    if (self) {
        [self setNeedsDisplay];
    }
    
    return self;
}

- (void)setConfig:(XDPagesConfig *)config {
    _config = config;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    TitleVerticalAlignment alignment = _config.titleVerticalAlignment;
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    CGFloat topSpace = 2;
    CGFloat bottomSpace = _config.needTitleBarSlideLine ? 5 : 2;
    CGFloat hf_edge = (bounds.size.height-textRect.size.height) / 2.0;
    
    switch (alignment) {
        case XDVerticalAlignmentTop:
            if (hf_edge > topSpace) {
                textRect.origin.y = bounds.origin.y + topSpace;
            } else {
                textRect.origin.y = bounds.origin.y + hf_edge;
            }
            break;

        case XDVerticalAlignmentMiddle:
            textRect.origin.y = bounds.origin.y + hf_edge;
            break;

        case XDVerticalAlignmentBottom:
            if (hf_edge > bottomSpace) {
                textRect.origin.y =  bounds.origin.y + hf_edge * 2 - bottomSpace;
            } else {
                textRect.origin.y = bounds.origin.y + hf_edge;
            }
            break;

        default:
            textRect.origin.y = bounds.origin.y + hf_edge;
            break;
    }
    
    return textRect;
}

- (void)drawTextInRect:(CGRect)rect {
    CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end
