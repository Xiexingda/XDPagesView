//
//  XDMap.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/16.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesMap.h"

@implementation XDPagesMap

+ (instancetype)map {
    return [[self alloc]init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self->mapDic = @{}.mutableCopy;
    }
    return self;
}

- (void)insertNode:(XDPagesNode *)node {
    if (!node || [self->mapDic objectForKey:node->key]) {
        return;
    }
    self->count += 1;
    if (!self->header) {
        self->header = node;
        self->footer = node;
    } else {
        self->header->pre = node;
        node->next = self->header;
        self->header = node;
        node->pre = nil;
    }
    [self->mapDic setValue:node forKey:node->key];
}

- (void)addNode:(XDPagesNode *)node {
    if (!node || [self->mapDic objectForKey:node->key]) {
        return;
    }
    self->count += 1;
    if (!self->footer) {
        self->footer = node;
        self->header = node;
    } else {
        self->footer->next = node;
        node->pre = self->footer;
        self->footer = node;
        node->next = nil;
    }
    [self->mapDic setValue:node forKey:node->key];
}

- (void)bringNodeToHeader:(XDPagesNode *)node {
    if (!node || ![self->mapDic objectForKey:node->key] || node == self->header) {
        return;
    }
    if (node->pre) node->pre->next = node->next;
    if (node->next) node->next->pre = node->pre;
    if (!node->next) self->footer = node->pre;
    self->header->pre = node;
    node->next = self->header;
    self->header = node;
    node->pre = nil;
}

- (void)bringNodeToFooter:(XDPagesNode *)node {
    if (!node || ![self->mapDic objectForKey:node->key] || node == self->footer) {
        return;
    }
    if (node->next) node->next->pre = node->pre;
    if (node->pre) node->pre->next = node->next;
    if (!node->pre) self->header = node->next;
    self->footer->next = node;
    node->pre = self->footer;
    self->footer = node;
    node->next = nil;
}

- (XDPagesNode *)removeFirstNode {
    if (!header) return nil;
    return [self removeNode:header];
}

- (XDPagesNode *)removeLastNode {
    if (!footer) return nil;
    return [self removeNode:footer];
}

- (XDPagesNode *)removeNode:(XDPagesNode *)node {
    if (!node || ![self->mapDic objectForKey:node->key]) {
        return node;
    }
    self->count -= 1;
    if (node->next) node->next->pre = node->pre;
    if (!node->next) footer = node->pre;
    if (node->pre) node->pre->next = node->next;
    if (!node->pre) header = node->next;
    [self->mapDic removeObjectForKey:node->key];
    return node;
}

- (void)removeAllNode {
    [self->mapDic removeAllObjects];
    self->count = 0;
    self->footer = nil;
    self->header = nil;
}
@end


