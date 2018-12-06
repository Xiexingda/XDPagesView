//
//  XDHeaderContentView.m
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import "XDHeaderContentView.h"
#import "XDTitleBar.h"

@interface XDHeaderContentView()
@property (nonatomic, assign) __block CGFloat headerContentHeight;
@property (nonatomic, assign) __block CGFloat headerBarHeight;
@property (nonatomic, assign) __block CGFloat headerHeight;
@property (nonatomic, assign) __block CGFloat headerEdgeTop;
@property (nonatomic, assign) __block CGFloat barMarginTop;

@property (nonatomic, strong)XDTitleBar *bar;
@property (nonatomic, strong) UIView *headerView;
@end
@implementation XDHeaderContentView
#pragma mark -- headerContener赋值
- (void (^)(NSArray *))titleBarTitles {
    __weak typeof(self) weakSelf = self;
    return ^(NSArray *titles) {
        if (weakSelf.bar) {
            weakSelf.bar.titles = titles;
        }
    };
}

- (CGFloat (^)(UIView *))pagesHeader {
    __weak typeof(self) weakSelf = self;
    return ^(UIView *header) {
        if (weakSelf.headerView) {
            [weakSelf.headerView removeFromSuperview];
            weakSelf.headerView = nil;
        }
        weakSelf.headerView = header;
        if (![weakSelf.headerView isDescendantOfView:weakSelf]) {
            [weakSelf addSubview:weakSelf.headerView];
        }
        [weakSelf resetFrame];
        return weakSelf.headerHeight;
    };
}

- (void (^)(NSInteger))titleBarChangedToIndex {
    __weak typeof(self) weakSelf = self;
    return ^(NSInteger index) {
        if (weakSelf.bar && weakSelf.bar.barIndexChangedBlock) {
            weakSelf.bar.barIndexChangedBlock(index);
        }
    };
}

- (void (^)(CGFloat))pagesHeaderEdgeTop {
    __weak typeof(self) weakSelf = self;
    return ^(CGFloat edgetop) {
        weakSelf.headerEdgeTop = edgetop > 0 ? edgetop : 0;
        [weakSelf resetFrame];
    };
}

#pragma mark -- 初始化
- (instancetype)initWithFrame:(CGRect)frame titleBarLayout:(XDTitleBarLayout *)titleBarLayout titleBarRightBtn:(void(^)(void))titleBarRightBtnBlock {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat itemSizeHeight = titleBarLayout.needBar ? titleBarLayout.barItemSize.height : 0;
        _headerBarHeight = itemSizeHeight > 0 ? itemSizeHeight : 0;
        _headerHeight = 0;
        _headerEdgeTop = 0;
        _headerContentHeight = _headerHeight + _headerBarHeight + _headerEdgeTop;
        _barMarginTop = titleBarLayout.barMarginTop > 0 ? titleBarLayout.barMarginTop : 0;
        
        if (_headerBarHeight > 0) {
            _bar = [[XDTitleBar alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, _headerBarHeight)
                                     titleBarLayout:titleBarLayout
                                   titleBarRightBtn:titleBarRightBtnBlock];
            
            [self addSubview:self.bar];
            
            __weak typeof(self) weakSelf = self;
            [_bar setBarItemTapBlock:^(NSIndexPath *index) {
                if (weakSelf.titleBarItemTap) {
                    weakSelf.titleBarItemTap(index);
                }
            }];
        }
        
        [self resetFrame];
    }
    return self;
}

//重置XDHeaderContentView的frame
- (void)resetFrame {
    if ([self.headerView isDescendantOfView:self]) {
        CGRect headerFrame = _headerView.frame;
        headerFrame.origin.x = 0;
        headerFrame.origin.y = _headerEdgeTop;
        headerFrame.size.width = self.bounds.size.width;
        _headerView.frame = headerFrame;
        _headerHeight = CGRectGetHeight(headerFrame);
    }
    
    if (self.bar) {
        CGRect barFrame = self.bar.frame;
        barFrame.origin.x = 0;
        barFrame.origin.y = [self.headerView isDescendantOfView:self] ? CGRectGetMaxY(_headerView.frame) : _headerEdgeTop;
        barFrame.size.width = self.bounds.size.width;
        self.bar.frame = barFrame;
        _headerBarHeight = CGRectGetHeight(barFrame);
    }
    
    CGRect cframe = self.bounds;
    CGFloat headerWidth = self.bounds.size.width;
    CGFloat headerContentHeight = _headerHeight + _headerBarHeight + _headerEdgeTop;
    
    cframe.size.width = headerWidth;
    cframe.size.height = headerContentHeight;
    self.frame = cframe;
    _headerContentHeight = CGRectGetHeight(cframe);
}

@end
