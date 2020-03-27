//
//  XDPagesMap.h
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/16.
//  Copyright © 2020 xie. All rights reserved.
//  页面双链表

#import <Foundation/Foundation.h>
#import "XDPagesNode.h"

@interface XDPagesMap : NSObject {
    @package
    NSMutableDictionary <NSString *,XDPagesNode *>*mapDic; // 存储map中的节点
    NSInteger count;     // 当前节点个数
    XDPagesNode *header; // 头结点
    XDPagesNode *footer; // 尾节点
}

+ (instancetype)map;
- (void)insertNode:(XDPagesNode *)node;          // 添加一个节点在最顶端
- (void)addNode:(XDPagesNode *)node;             // 添加一个节点在最末端

- (void)bringNodeToHeader:(XDPagesNode *)node;   // 把节点移动到最顶端
- (void)bringNodeToFooter:(XDPagesNode *)node;   // 把节点移动到最末端

- (XDPagesNode *)removeFirstNode;                // 删除最顶端节点
- (XDPagesNode *)removeLastNode;                 // 删除最末端节点

- (XDPagesNode *)removeNode:(XDPagesNode *)node; // 删除某个节点
- (void)removeAllNode;                           // 删除所有节点

@end


