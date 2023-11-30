//
//  XDPagesValueLock.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/22.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesValueLock.h"

typedef NS_ENUM(NSInteger,LockValue) {
    XD_UnLock,
    XD_Lock
};

@interface XDPagesValueLock ()
@property (nonatomic, assign) LockValue lock;
@property (nonatomic, assign) CGFloat value;
@end
@implementation XDPagesValueLock
+ (instancetype)lock {
    return [[XDPagesValueLock alloc]init];
}

- (CGFloat)lockValue:(CGFloat)value {
    if (_lock != XD_Lock) {
        _lock = XD_Lock;
        _value = value;
    }
    
    return _value;
}

- (void)unlock {
    _lock = XD_UnLock;
}
@end
