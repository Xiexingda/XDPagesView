//
//  XDPagesView.m
//  XDPagesController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//  滑动界面

#import <UIKit/UIKit.h>
#import "XDTitleBarLayout.h"
@class XDPagesView;

typedef NS_ENUM(NSInteger, XDPagesViewStyle) {
    XDPagesViewStyleHeaderFirst,//表头优先，只要header不在吸顶状态，所有列表都会相对于header复原到最顶端
    XDPagesViewStyleTablesFirst //列表优先，不管header怎么变动，所有的列表都会保持自己上次与header的相对位置
};

@protocol XDPagesViewDataSourceDelegate <NSObject>
@required
/**
 数据代理，用于接受标题数组

 @return 标题数组
 */
- (NSArray <NSString *> *)xd_pagesViewPageTitles;

/**
 数据代理，用于接受当前控制器

 @param pagesView XDPagesView
 @param index 索引
 @return 子控制器
 */
- (UIViewController *)xd_pagesViewChildControllerToPagesView:(XDPagesView *)pagesView forIndex:(NSInteger)index;

@optional

/**
 已经跳到的当前界面

 @param pageController 当前控制器
 @param pageTitle 标题
 @param pageIndex 索引
 */
- (void)xd_pagesViewDidChangeToPageController:(UIViewController *const)pageController title:(NSString *)pageTitle pageIndex:(NSInteger)pageIndex;

/**
 竖直滚动监听
 该代理只有在有header时才会调用，且变动范围为header的高度范围
 @param changedy 竖直offset.y
 */
- (void)xd_pagesViewVerticalScrollOffsetyChanged:(CGFloat)changedy;

/**
 水平滚动监听

 @param changedx 水平offset.x
 */
- (void)xd_pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx;

/**
 标题栏右边按钮点击事件
 */
- (void)xd_pagesViewTitleBarRightBtnTap;

@end

@interface XDPagesView : UIView
//设置header
@property (nonatomic, strong) UIView *headerView;

//最大缓存页数，默认为不限制
@property (nonatomic, assign) NSUInteger cacheNumber;

//靠边后是否可滑动，默认为NO
@property (nonatomic, assign) BOOL bounces;

//需要通过header上下滑动列表（默认为NO）
@property (nonatomic, assign) BOOL needSlideByHeader;

//slideview上方空余空间 (其值要大于0)
@property (nonatomic, assign) CGFloat edgeInsetTop;

/**
 初始化XDSlideView
 
 @param frame frame
 @param delegate 代理
 @param beginPage  开始页
 @param titleBarLayout 标题栏布局配置
 @param style 两种算法
 @return slideview
 */
- (instancetype)initWithFrame:(CGRect)frame dataSourceDelegate:(id)delegate beginPage:(NSInteger)beginPage titleBarLayout:(XDTitleBarLayout *)titleBarLayout style:(XDPagesViewStyle)style;
/**
 缓存复用

 @param index 索引
 @return 缓存的子控制器
 */
- (UIViewController *)dequeueReusablePageForIndex:(NSInteger)index;

/**
 定位到某页

 @param page 页面索引
 */
- (void)jumpToPage:(NSInteger)page;

 /**
  刷新控制器列表，并定位到页

  @param page 刷新后定位到的页面索引
  */
 - (void)reloadataToPage:(NSInteger)page;

@end
