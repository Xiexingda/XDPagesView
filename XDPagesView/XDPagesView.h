//
//  XDPagesView.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/13.
//  Copyright © 2020 xie. All rights reserved.
//  控制器列表页

#import <UIKit/UIKit.h>
#import "XDPagesConfig.h"
@class XDPagesView;

typedef NS_ENUM(NSInteger, XDPagesPullStyle) {
    XDPagesPullOnTop = 0,       //顶端下拉
    XDPagesPullOnCenter = 1     //中间下拉
};

@protocol XDPagesViewDelegate <NSObject>
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
 @param title 对应标题
 @return 子控制器
 */
- (UIViewController *)xd_pagesView:(XDPagesView *)pagesView controllerForIndex:(NSInteger)index title:(NSString *)title;

@optional

/**
 已经跳到的当前界面
 @param controller 当前控制器
 @param index 索引
 @param title 标题
 */
- (void)xd_pagesViewDidChangeToController:(UIViewController *const)controller index:(NSInteger)index title:(NSString *)title;

/**
 竖直滚动监听
 @param changedy 竖直offset.y
 @param ceiling 是否已吸顶
 */
- (void)xd_pagesViewVerticalScrollOffsetyChanged:(CGFloat)changedy isCeiling:(BOOL)ceiling;

/**
 水平滚动监听
 @param changedx 水平offset.x
 @param currentPage 当前页
 @param willShowPage 目标页
 */
- (void)xd_pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx currentPage:(NSInteger)currentPage willShowPage:(NSInteger)willShowPage;

/**
 自定义标题宽度
 @param index 索引
 @param title 标题
 */
- (CGFloat)xd_pagesViewTitleWidthForIndex:(NSInteger)index title:(NSString *)title;
@end

@interface XDPagesView : UIView
@property (nonatomic, weak) id <XDPagesViewDelegate> delegate;
@property (nonatomic, strong) UIView *pagesHeader;

//系统下拉刷新（头部下拉只支持系统下拉刷新）
@property (nonatomic, strong) UIRefreshControl *refreshControl;

/**
 初始化
 @param frame rect
 @param config 配置信息
 @param style 列表风格
 */
- (instancetype)initWithFrame:(CGRect)frame config:(XDPagesConfig *)config style:(XDPagesPullStyle)style;

/**
 缓存复用
 @param index 索引
 @return 缓存的子控制器
 */
- (UIViewController *)dequeueReusablePageForIndex:(NSInteger)index;

/**
 跳转到某页
 @param page 页面索引
 */
- (void)jumpToPage:(NSInteger)page;
- (void)jumpToPage:(NSInteger)page animate:(BOOL)animate;

 /**
  刷新控制器列表，并定位到页
  @param page 刷新后定位到的页面索引
  */
 - (void)reloadataToPage:(NSInteger)page;

/**
 展示某个item的未读消息
 @param number 未读数，当为0时隐藏
 @param idx 对应索引
 @param color badge颜色
 @param isNumber 是否显示数字
 */
- (void)showBadgeNumber:(NSInteger)number index:(NSInteger)idx color:(UIColor *)color isNumber:(BOOL)isNumber;
@end

