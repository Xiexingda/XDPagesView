//
//  XDTitleBarLayout.h
//  Demo
//
//  Created by 谢兴达 on 2018/11/24.
//  Copyright © 2018 谢兴达. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XDTitleBarLayout : NSObject
//标题栏
@property (nonatomic, assign) BOOL needBar;             //默认为YES
@property (nonatomic, assign) CGFloat barMarginTop;     //标题栏距顶端边距
@property (nonatomic, assign) CGSize barItemSize;       //标题item大小，默认为80*40
@property (nonatomic, assign) BOOL barBounces;
@property (nonatomic, assign) BOOL barAlwaysBounceHorizontal;

//标题栏首个标题是否需要图标
@property (nonatomic, assign) BOOL needBarFirstItemIcon;
@property (nonatomic, strong) UIImage *firstItemIconNormal;         //首个item图标
@property (nonatomic, strong) UIImage *firstItemIconSelected;       //选中时的首个item图标

//标题栏右按钮
@property (nonatomic, assign) BOOL needBarRightButten;          //默认为NO，当为YES时如果没有自定义按钮则会默认添加一个按钮
@property (nonatomic, strong) UIImage *barRightButtenImage;     //为默认右按钮设置背景图片
@property (nonatomic, strong) UIView *barRightCustomView;       //自定义右按钮，需要传入一个自定义的视图或者按钮，此时不再创建默认按钮

//标题栏底线
@property (nonatomic, assign) BOOL needBarBottomLine;       //默认为YES
@property (nonatomic, strong) UIColor *barBottomLineColor;  //默认浅灰色

//标题栏底部跟踪线
@property (nonatomic, assign) BOOL needBarFollowLine;       //默认为YES
@property (nonatomic, strong) UIColor *barFollowLineColor;  //默认橘黄色
@property (nonatomic, assign) CGFloat barFollowLinePercent; //跟踪线占item宽的百分比 0~1 之间

//文字属性
@property (nonatomic, strong) UIFont *barTextFont;      //默认16号字
@property (nonatomic, strong) UIColor *barTextColor;    //默认黑色
@property (nonatomic, strong) UIColor *barTextSelectedColor; //默认橘黄色

//tag
@property (nonatomic, assign) id barTag;  //增加灵活性，如果需要自定义标题栏样式时，可以用这个tag进行区分，避免互相影响
@end
