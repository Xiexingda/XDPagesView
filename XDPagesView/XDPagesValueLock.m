//
//  XDPagesValueLock.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/22.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesValueLock.h"

typedef NS_ENUM(NSInteger,LockValue) {
    XD_Lock = 1,
    XD_UnLock = 2
};

@interface XDPagesValueLock ()
@property (nonatomic, assign) LockValue lock;
@property (nonatomic, assign) CGFloat value;
@end
@implementation XDPagesValueLock
+ (instancetype)lock {
    return [[XDPagesValueLock alloc]init];
}

- (CGFloat)value:(CGFloat)value lock:(BOOL)lock {
    
    LockValue c_lock = lock ? XD_Lock : XD_UnLock;
    
    if (c_lock == XD_UnLock) {
        _value = value;
        _lock = 0;
    } else if (_lock != c_lock) {
        _lock = c_lock;
        _value = value;
    }
    
    return _value;
}
@end
