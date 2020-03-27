//
//  XDPagesValueLock.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/22.
//  Copyright © 2020 xie. All rights reserved.
//  对某个值进行一对一锁定

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XDPagesValueLock : NSObject
+ (instancetype)lock;
// 锁定数值
- (CGFloat)value:(CGFloat)value lock:(BOOL)lock;
@end
