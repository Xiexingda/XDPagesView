//
//  XDTitleBarLayout.m
//  Demo
//
//  Created by 谢兴达 on 2018/11/24.
//  Copyright © 2018 谢兴达. All rights reserved.
//

#import "XDTitleBarLayout.h"

@implementation XDTitleBarLayout
- (instancetype)init {
    self = [super init];
    if (self) {
        _needBar = YES;
        _barItemSize = CGSizeMake(80, 40);
        _barMarginTop = 0;
        _barBounces = YES;
        _barAlwaysBounceHorizontal = NO;
        
        _needBarFirstItemIcon = NO;
        _needBarRightButten = NO;
        
        _needBarBottomLine = YES;
        _barBottomLineColor = [UIColor lightGrayColor];
        
        _needBarFollowLine = YES;
        _barFollowLineColor = [UIColor orangeColor];
        _barFollowLinePercent = 0.6;
        
        _barTextFont = [UIFont systemFontOfSize:16.f];
        _barTextColor = [UIColor blackColor];
        _barTextSelectedColor = [UIColor orangeColor];
        
        _barTag = 0;
    }
    
    return self;
}
@end
