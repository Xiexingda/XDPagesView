//
//  UIView+XDhandle.m
//  Demo
//
//  Created by 谢兴达 on 2018/11/12.
//  Copyright © 2018 谢兴达. All rights reserved.
//

#import "UIView+XDhandle.h"
#import <objc/runtime.h>

@interface UIView()
@property(nonatomic, copy) void (^tapBlock)(id obj);
@end

@implementation UIView (XDhandle)
static char tapBlock_key;
#pragma mark -
#pragma mark -- make set&get
- (void)setTapBlock:(void (^)(id))tapBlock {
    objc_setAssociatedObject(self, &tapBlock_key, tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(id))tapBlock {
    return objc_getAssociatedObject(self, &tapBlock_key);
}

#pragma mark -
#pragma mark -- methord tap
- (void)tapBlock:(void (^)(id))block {
    self.tapBlock = block;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHandle:)];
    [self addGestureRecognizer:tap];
}

- (void)tapHandle:(id) tap {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    if (self.tapBlock) {
        self.tapBlock(tap);
    }
}
@end
