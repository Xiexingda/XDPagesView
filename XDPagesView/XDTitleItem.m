//
//  XDSildeItem.m
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import "XDTitleItem.h"

#define Icon_Edge 15
#define FollowLineThin 2.0

@interface XDTitleItem()
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *followLine;
@property (nonatomic, strong) UIImageView *icon;
@end
@implementation XDTitleItem
- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc]init];
        _title.textAlignment = NSTextAlignmentCenter;
        _followLine = [[UILabel alloc]init];
        _followLine.clipsToBounds = YES;
        _followLine.layer.cornerRadius = FollowLineThin/2;
    }
    return _title;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatMainUI];
    }
    return self;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc]init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        _icon.clipsToBounds = YES;
    }
    return _icon;
}

- (void)creatMainUI {
    [self.contentView addSubview:self.icon];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:_followLine];
}

- (void)configItemByTitle:(NSString *)title index:(NSIndexPath *)index selectedIndex:(NSInteger)selectedIndex titleBarLayout:(XDTitleBarLayout *)titleBarLayout {
    self.title.text = title;
    self.title.font = titleBarLayout.barTextFont;
    
    CGFloat xd_width = self.bounds.size.width;
    CGFloat xd_height = self.bounds.size.height;
    
    if (titleBarLayout.needBarFirstItemIcon && index.row == 0) {
        self.icon.hidden = NO;
        self.icon.frame = CGRectMake(Icon_Edge, 0, ItemIconSize, xd_height);
        self.title.frame = CGRectMake(CGRectGetMaxX(self.icon.frame), 0, xd_width-Icon_Edge-ItemIconSize, self.frame.size.height);
        
    } else {
        self.icon.hidden = YES;
        self.title.frame = self.bounds;
    }
    
    //选中时的状态
    if (index.row == selectedIndex) {
        self.backgroundColor = titleBarLayout.currentItemBackGroundColor;
        self.title.textColor = titleBarLayout.barTextSelectedColor;
        if (!self.icon.isHidden) {
            self.icon.image = [titleBarLayout.firstItemIconSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
        }
        [self bottomLineHandleByNeedLine:titleBarLayout.needBarFollowLine isSelected:YES color:titleBarLayout.barFollowLineColor percent:titleBarLayout.barFollowLinePercent];
        
    } else {
        self.backgroundColor = [UIColor clearColor];
        self.title.textColor = titleBarLayout.barTextColor;
        if (!self.icon.isHidden) {
            self.icon.image = [titleBarLayout.firstItemIconNormal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        [self bottomLineHandleByNeedLine:titleBarLayout.needBarFollowLine isSelected:NO color:titleBarLayout.barFollowLineColor percent:titleBarLayout.barFollowLinePercent];
    }
}

- (void)bottomLineHandleByNeedLine:(BOOL)needLine isSelected:(BOOL)isSelected color:(UIColor *)color percent:(CGFloat)percent {
    percent = percent < 0 ? 0 : percent > 1 ? 1 : percent;
    if (!needLine) {
        _followLine.hidden = YES;
        return;
    }
    _followLine.backgroundColor = color;
    CGFloat xd_width = self.bounds.size.width;
    CGFloat xd_height = self.bounds.size.height;
    CGFloat lineWidth = xd_width * percent;
    [_followLine setFrame:CGRectMake((xd_width-lineWidth)/2.0, xd_height- FollowLineThin - 0.5, lineWidth, FollowLineThin)];
    _followLine.hidden = !isSelected;
}
@end
