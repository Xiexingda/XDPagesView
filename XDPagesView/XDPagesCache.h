//
//  XDPagesCache.h
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/11.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XDPagesCache : NSObject
@property (nonatomic, strong) NSMutableDictionary        *caches_vc;       //子控制器缓存
@property (nonatomic, strong) NSMutableDictionary        *caches_sview;    //子控制器ScrollView缓存
@property (nonatomic, strong) NSMutableDictionary        *caches_headery;  //每个页面变动前对应的headery
@property (nonatomic, strong) NSArray<NSString *>        *caches_titles;   //所有标题缓存
@property (nonatomic, strong) NSMutableArray<NSString *> *caches_table;    //当前缓存顺序表
@property (nonatomic, strong) NSMutableArray<NSString *> *caches_kvo;      //当前所有添加了观察者的对象标题
@property (nonatomic, assign) NSUInteger                 cachenumber;      //最大缓存数
@end
