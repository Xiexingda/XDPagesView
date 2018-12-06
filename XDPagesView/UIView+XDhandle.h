//
//  UIView+XDhandle.h
//  Demo
//
//  Created by 谢兴达 on 2018/11/12.
//  Copyright © 2018 谢兴达. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (XDhandle)
//点击手势
- (void)tapBlock:(void(^)(id obj))block;
@end

NS_ASSUME_NONNULL_END
