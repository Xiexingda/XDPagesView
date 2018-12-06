//
//  XDSlideBar.h
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XDTitleBarLayout.h"

@interface XDTitleBar : UIView

//标题数组
@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, copy) void (^barItemTapBlock)(NSIndexPath *index);
@property (nonatomic, copy) void (^barIndexChangedBlock)(NSInteger index);

- (instancetype)initWithFrame:(CGRect)frame titleBarLayout:(XDTitleBarLayout *)titleBarLayout titleBarRightBtn:(void(^)(void))titleBarRightBtnBlock;
@end
