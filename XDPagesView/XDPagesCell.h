//
//  XDPagesCell.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/13.
//  Copyright © 2020 xie. All rights reserved.
//  主cell

#import <UIKit/UIKit.h>
#import "XDPagesTable.h"
#import "XDPagesConfig.h"

@protocol XDPagesCellDelegate <NSObject>

/**
数据代理，用于接受标题数组
@return 标题数组
*/
- (NSArray <NSString *>*)cell_allTitles;

/**
数据代理，用于接受当前控制器
@param index 索引
@param title 对应标题
@return 子控制器
*/
- (UIViewController *)cell_pagesViewChildControllerForIndex:(NSInteger)index title:(NSString *)title;

/**
已经跳到的当前界面
@param pageController 当前控制器
@param pageTitle 标题
@param pageIndex 索引
*/
- (void)cell_pagesViewDidChangeToPageController:(UIViewController *const)pageController title:(NSString *)pageTitle pageIndex:(NSInteger)pageIndex;

/**
 横向滚动安全范围内回调，用于标题的渐变等
 @param changedx 变动值
 @param page 当前页
 @param willShowPage 目标页
 */
- (void)cell_pagesViewSafeHorizontalScrollOffsetxChanged:(CGFloat)changedx currentPage:(NSInteger)page willShowPage:(NSInteger)willShowPage;

/**
 水平滚动监听
 @param changedx 水平offset.x
 @param page 当前页
 @param willShowPage 目标页
 */
- (void)cell_pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx currentPage:(NSInteger)page willShowPage:(NSInteger)willShowPage;

/**
 主table锁定消息传递
 @param need 是否需要锁定
 @param y 锁定值
 */
- (void)cell_mainTableNeedLock:(BOOL)need offsety:(CGFloat)y;

/**
 当前页是否可滚动
 @param enable 是否可滚动
 */
- (void)cell_currentPageScollEnable:(BOOL)enable;

/**
 列表以上可以变动的竖直高度
 */
- (CGFloat)cell_headerVerticalCanChangedSpace;
@end

@interface XDPagesCell : UITableViewCell

/**
 初始化主cell
 @param style cell风格
 @param reuseIdentifier 复用ID
 @param controller 主列表所在的父控制器
 @param delegate 代理
 @param pullStyle 下拉风格
 @param config 配置
 @param adjustValue 调整值
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
            contentController:(UIViewController *)controller
                     delegate:(id<XDPagesCellDelegate>)delegate
               pagesPullStyle:(NSInteger)pullStyle
                       config:(XDPagesConfig *)config
                  adjustValue:(CGFloat)adjustValue;

/**
 内外视图交换管道
 @param mainTable 主列表
 */
- (UIScrollView *)exchangeChannelOfPagesContainerAndMainTable:(XDPagesTable *)mainTable;

/**
 缓存复用
 @param index 索引
 @return 缓存的子控制器
*/
- (UIViewController *)dequeueReusablePageForIndex:(NSInteger)index;

/**
 页面跳转
 @param page 跳转页
 @param animate 是否有跳转动画
 */
- (void)changeToPage:(NSInteger)page animate:(BOOL)animate;

/**
 刷新列表
 @param page 刷新完成后跳转到的页面
 @param finish 刷新完成回调
 */
- (void)reloadToPage:(NSInteger)page finish:(void(^)(NSArray<NSString *>* titles))finish;

/**
 即时更新主列表的偏移量
 @param currentMainTalbelOffsety 主列表偏移量
 */
- (void)setCurrentMainTalbelOffsety:(CGFloat)currentMainTalbelOffsety;
@end
