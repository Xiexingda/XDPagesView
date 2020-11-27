//
//  XDPagesConfig.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/29.
//  Copyright © 2020 xie. All rights reserved.
//  配置

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SlideLineStyle) {
    XDSlideLine_None,          // 下划线无展示效果
    XDSlideLine_Scale,         // 下划线伸缩
    XDSlideLine_translation    // 下划线平移(默认效果)
};

typedef NS_ENUM(NSInteger, TitleVerticalAlignment) {
    XDVerticalAlignmentTop = 0, //标题顶部垂直
    XDVerticalAlignmentMiddle,  //标题中部垂直对齐
    XDVerticalAlignmentBottom,  //标题底部垂直对齐
};

@interface XDPagesConfig : NSObject
@property (nonatomic, assign) NSInteger beginPage;                  // 起始页
@property (nonatomic, assign) NSInteger maxCacheCount;              // 最大缓存页数
@property (nonatomic, assign) BOOL pagesSlideEnable;                // 是否可滑动翻页（默认YES）
@property (nonatomic, assign) BOOL animateForPageChange;            // 页面变动时是否需要动画（默认YES）
@property (nonatomic, assign) BOOL pagesHorizontalBounce;           // 是否页面边界自由滑动（默认YES）

@property (nonatomic, assign) BOOL needTitleBar;                    // 是否需要标题栏（默认YES）
@property (nonatomic, assign) BOOL titleBarFitHeader;               // 是否标题栏和header作为一个整体（默认NO）
@property (nonatomic, assign) CGFloat titleBarHeight;               // 标题栏高度（默认50）
@property (nonatomic, assign) CGFloat titleBarMarginTop;            // 悬停位置距上端距离（默认0）
@property (nonatomic, assign) BOOL needTitleBarBottomLine;          // 是否需要标题栏底线（默认YES）
@property (nonatomic, strong) UIColor *titleBarBottomLineColor;     // 底线颜色（默认浅灰色）
@property (nonatomic, assign) BOOL needTitleBarSlideLine;           // 是否需要下滑线（默认YES）
@property (nonatomic, assign) SlideLineStyle titleBarSlideLineStyle;// 下划线跟随方式
@property (nonatomic, assign) CGFloat titleBarSlideLineWidthRatio;  // 下滑线相对于当前item宽的比例[0-1]
@property (nonatomic, strong) UIColor *titleBarSlideLineColor;      // 下滑线颜色（默认灰色）
@property (nonatomic, strong) UIColor *titleBarBackColor;           // 标题栏背景色
@property (nonatomic, strong) UIImage *titleBarBackImage;           // 标题栏背景图
@property (nonatomic, assign) BOOL titleBarHorizontalBounce;        // 标题栏是否可以边界自由滑动（默认YES）
@property (nonatomic, strong) UIView *customTitleBar;               // 自定义标题栏

@property (nonatomic, strong) UIColor *titleItemBackColor;          // 标题背景颜色
@property (nonatomic, strong) UIColor *titleItemBackHightlightColor;// 标题选中时背景颜色
@property (nonatomic, strong) UIImage *titleItemBackImage;          // 标题背景图片
@property (nonatomic, strong) UIImage *titleItemBackHightlightImage;// 标题选中时的背景图片

@property (nonatomic, assign) BOOL titleFlex;                       // 是否自动计算标题宽（默认YES）
@property (nonatomic, assign) BOOL titleGradual;                    // 是否采用渐变方式(默认YES,只渐变标题属性)
@property (nonatomic, assign) TitleVerticalAlignment titleVerticalAlignment; // 标题竖直对齐方式
@property (nonatomic, strong) UIColor *titleTextColor;              // 标题颜色
@property (nonatomic, strong) UIColor *titleTextHightlightColor;    // 标题选中时的颜色
@property (nonatomic, strong) UIFont *titleFont;                    // 标题字号大小(默认16)
@property (nonatomic, strong) UIFont *titleHightlightFont;          // 选中后的字号大小(默认18)

@property (nonatomic, assign) BOOL needRightBtn;                    // 是否需要右按钮（默认NO）
@property (nonatomic, assign) CGSize rightBtnSize;                  // 右按钮大小
@property (nonatomic, strong) UIView *rightBtn;                     // 右按钮自定义视图

+ (instancetype)config;
@end
