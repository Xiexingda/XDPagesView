//
//  XDPagesTitleBar.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/29.
//  Copyright © 2020 xie. All rights reserved.
//  标题栏

#import <UIKit/UIKit.h>
#import "XDPagesConfig.h"

@protocol XDPagesTitleBarDelegate <NSObject>

- (void)title_tapAtIndex:(NSInteger)index;

@end
@interface XDPagesTitleBar : UIView
@property (nonatomic, weak) id <XDPagesTitleBarDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame config:(XDPagesConfig *)config titles:(NSArray<NSString*>*)titles;

//刷新标题
- (void(^)(NSArray <NSString *>* titles))refreshTitles;
//滑动翻页时，聚焦到当前页标题
- (void(^)(NSInteger focusIdx))currentFocusIndex;
//监听横向滑动值 当前页 将要跳转到的页面 页面宽度，用于渐变动画
- (void)pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx currentPage:(NSInteger)page willToPage:(NSInteger)willToPage width:(CGFloat)width;
@end