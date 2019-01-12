//
//  XDPagesCache.m
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/11.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import "XDPagesCache.h"

@implementation XDPagesCache
- (void)setCachenumber:(NSUInteger)cachenumber {
    if (cachenumber <= 2) {
        _cachenumber = 2;
    } else {
        _cachenumber = (NSUInteger)cachenumber;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _caches_vc = @{}.mutableCopy;
        _caches_sview = @{}.mutableCopy;
        _caches_headery = @{}.mutableCopy;
        _caches_titles = @[].copy;
        _caches_table = @[].mutableCopy;
        _caches_kvo = @[].mutableCopy;
        _cachenumber = 50;
    }
    return self;
}

@end
