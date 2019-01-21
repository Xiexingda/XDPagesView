//
//  XDSildeItem.h
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDTitleBarLayout.h"

#define ItemIconSize 18

@interface XDTitleItem : UICollectionViewCell
/**
 赋值item

 @param title 标题
 @param index 每个item对应的index
 @param selectedIndex 当前选中的index
 @param titleBarLayout 布局
 */
- (void)configItemByTitle:(NSString *)title
                    index:(NSIndexPath *)index
            selectedIndex:(NSInteger)selectedIndex
           titleBarLayout:(XDTitleBarLayout *)titleBarLayout;
@end
