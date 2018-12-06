//
//  XDSildeItem.h
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ItemIconSize 18

@interface XDTitleItem : UICollectionViewCell
/**
 赋值item

 @param title 标题
 @param needIcon 是否首个item需要图标
 @param iconImage 首个item图标
 @param selectedIconImage 首个item选中时的图标
 @param needFollowLine 是否需要跟踪条
 @param followLineColor 跟宗条颜色
 @param followPercent 跟踪条所占百分比
 @param titleFont 标题大小
 @param textColor 标题颜色
 @param textSelectedColor 选中时的标题颜色
 @param barTag 标识，增加灵活性
 @param index 每个item对应的index
 @param selectedIndex 当前选中的index
 */
- (void)configItemByTitle:(NSString *)title
                titleFont:(UIFont *)titleFont
                textColor:(UIColor *)textColor
        textSelectedColor:(UIColor *)textSelectedColor
                 needIcon:(BOOL)needIcon
                iconImage:(UIImage *)iconImage
        selectedIconImage:(UIImage *)selectedIconImage
           needFollowLine:(BOOL)needFollowLine
          followLineColor:(UIColor *)followLineColor
            followPercent:(CGFloat)followPercent
                   barTag:(id)barTag
                    index:(NSIndexPath *)index
            selectedIndex:(NSInteger)selectedIndex;
@end
