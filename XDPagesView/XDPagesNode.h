//
//  XDPagesNode.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/16.
//  Copyright © 2020 xie. All rights reserved.
//  页面链表节点

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XDPagesNode : NSObject {
    @package
    NSString *key;                          // key
    id  value;                              // value
    UIColor *badgeColor;                    // 未读消息颜色
    UIViewController *controller;           // 控制器
    UIView *view;                           // 控制器中的子view
    NSArray <UIScrollView *>*scrollViews;   // 每页需要监控的所有滚动单元
    NSInteger right;                        // 加权
    __weak XDPagesNode *pre;        // 上一个
    __weak XDPagesNode *next;       // 下一个
}
+ (instancetype)node;

@end
