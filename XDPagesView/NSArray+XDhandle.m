//
//  NSArray+XDhandle.m
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/15.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import "NSArray+XDhandle.h"

@implementation NSArray (XDhandle)
- (id)hasRepeatItemInArray {
    NSArray *arr = self;
    id repeatItem = nil;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    for (id obj in arr) {
        if ([dic objectForKey:obj]) {
            repeatItem = obj;
            break;
        } else {
            [dic setObject:obj forKey:obj];
        }
    }
    dic = nil;
    return repeatItem;
}

- (NSMutableArray *)exclusiveItemsbyCompareArray:(NSArray *)carray {
    NSMutableArray *exclusiveItems = @[].mutableCopy;
    NSMutableDictionary *arrayDic = @{}.mutableCopy;
    for (id obj in carray) {
        [arrayDic setObject:obj forKey:obj];
    }
    for (id obj in self) {
        if (![arrayDic objectForKey:obj]) {
            [exclusiveItems addObject:obj];
        }
    }
    return exclusiveItems;
}
@end
