//
//  XDPagesLayout.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/29.
//  Copyright © 2020 xie. All rights reserved.
//  标题栏自定义布局

#import <UIKit/UIKit.h>

@protocol XDPagesLayouDelegate <NSObject>
- (CGSize)xd_itemLayoutSizeAtIndex:(NSIndexPath *)indexPath;
@end
@interface XDPagesLayout : UICollectionViewLayout
@property (nonatomic,   weak) id <XDPagesLayouDelegate> delegate;
@property (nonatomic, strong) NSArray <UICollectionViewLayoutAttributes *>*allAttributes;
@end

