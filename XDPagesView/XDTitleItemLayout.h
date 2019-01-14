//
//  XDTitleItemLayout.h
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//  自定义滑动标题的布局，这里只是简单的实现，可以进行自定义实现更炫酷的效果

#import <UIKit/UIKit.h>

@interface XDTitleItemLayout : UICollectionViewLayout
@property (nonatomic, strong) CGSize(^itemSizeBlock)(NSIndexPath *indexPath);//获取item大小
@end
