//
//  NSArray+XDhandle.h
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/15.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (XDhandle)
//数组中是否有重复项
- (id)hasRepeatItemInArray;

//找出专属于前面数组的项
- (NSMutableArray *)exclusiveItemsbyCompareArray:(NSArray *)carray;
@end
