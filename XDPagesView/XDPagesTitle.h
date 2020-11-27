//
//  XDPagesTitle.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/29.
//  Copyright © 2020 xie. All rights reserved.
//  标题

#import <UIKit/UIKit.h>
#import "XDPagesConfig.h"
#import "XDPagesCache.h"
@class XDPagesTitleLabel;

@interface XDPagesTitle : UICollectionViewCell
/// 初始化标题
/// @param title 标题
/// @param fidx 当前选中项索引
/// @param config 配置
/// @param badge 未读标记
/// @param indexPath 索引
- (void)configTitleByTitle:(NSString *)title focusIdx:(NSInteger)fidx config:(XDPagesConfig *)config badge:(XDBADGE)badge indexPath:(NSIndexPath *)indexPath;

// 渐变上升
- (void)gradualUpByConfig:(XDPagesConfig *)config percent:(CGFloat)percent;
// 渐变下降
- (void)gradualDownByConfig:(XDPagesConfig *)config percent:(CGFloat)percent;
@end

@interface XDPagesTitleLabel : UILabel
@property (nonatomic, assign) TitleVerticalAlignment verticalAlignment;
@end
