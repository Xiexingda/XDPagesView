//
//  XDPagesConfig.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/29.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesConfig.h"
#import "XDPagesTools.h"

@implementation XDPagesConfig
+ (instancetype)config {
    return [[self alloc]init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    _beginPage = 0;
    _maxCacheCount = 20;
    _pagesSlideEnable = YES;
    _animateForPageChange = YES;
    _pagesHorizontalBounce = YES;
    
    _needTitleBar = YES;
    _titleBarFitHeader = NO;
    _titleBarHeight = 50;
    _titleBarMarginTop = 0;
    _needTitleBarBottomLine = YES;
    _titleBarBottomLineColor = [UIColor lightGrayColor];
    _needTitleBarSlideLine = YES;
    _titleBarSlideLineStyle = XDSlideLine_translation;
    _titleBarSlideLineWidthRatio = 0.5;
    _titleBarSlideLineColor = [UIColor grayColor];
    _titleBarBackColor = [UIColor orangeColor];
    _titleBarBackImage = nil;
    _titleBarHorizontalBounce = YES;
    _customTitleBar = nil;
    
    _titleItemBackColor = [UIColor clearColor];
    _titleItemBackHightlightColor = [UIColor clearColor];
    _titleItemBackImage = nil;
    _titleItemBackHightlightImage = nil;
    
    _titleFlex = YES;
    _titleGradual = YES;
    _titleVerticalAlignment = XDVerticalAlignmentMiddle;
    _titleTextColor = [UIColor grayColor];
    _titleTextHightlightColor = [UIColor greenColor];
    _titleFont = [UIFont systemFontOfSize:16];
    _titleHightlightFont = [UIFont systemFontOfSize:18];
    
    _needRightBtn = NO;
    _rightBtnSize = CGSizeMake(40, 50);
    _rightBtn = nil;
}

- (void)setNeedTitleBar:(BOOL)needTitleBar {
    _needTitleBar = needTitleBar;
    if (!needTitleBar) {
        _titleBarHeight = 0;
    }
}

- (void)setTitleBarHeight:(CGFloat)titleBarHeight {
    if (!_needTitleBar) return;
    _titleBarHeight = fabs([XDPagesTools adjustFloatValue:titleBarHeight]);
}

- (void)setTitleBarMarginTop:(CGFloat)titleBarMarginTop {
    _titleBarMarginTop = fabs([XDPagesTools adjustFloatValue:titleBarMarginTop]);
}

- (void)setTitleBarFitHeader:(BOOL)titleBarFitHeader {
    _titleBarFitHeader = titleBarFitHeader;
    if (titleBarFitHeader) {
        _titleBarBackColor = [UIColor clearColor];
        _titleBarBackImage = nil;
    }
}

- (void)setTitleBarBackColor:(UIColor *)titleBarBackColor {
    if (_titleBarFitHeader) return;
    _titleBarBackColor = titleBarBackColor;
}

- (void)setTitleBarBackImage:(UIImage *)titleBarBackImage {
    if (_titleBarFitHeader) return;
    _titleBarBackImage = titleBarBackImage;
}
@end
