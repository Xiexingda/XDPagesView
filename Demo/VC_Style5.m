//
//  VC_Style5.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/3/8.
//  Copyright © 2020 xie. All rights reserved.
//

#import "VC_Style5.h"
#import "XDPagesView.h"
#import "Page_0.h"
#import "Page_1.h"
#import "Page_2.h"
#import "Page_3.h"

@interface VC_Style5 ()<XDPagesViewDelegate>
@property (nonatomic, strong) XDPagesView *pages;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIImageView *header;
@property (nonatomic, strong) UIButton *rightBtn;
@end

@implementation VC_Style5
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    // 在这个示例里详细介绍一下 XDPagesConfig
    XDPagesConfig *config = [XDPagesConfig config];
    
    // 起始页面
    config.beginPage = 1;
    
    // 最大缓存页数
    config.maxCacheCount = 20;
    
    // 是否可以滑动翻页
    config.pagesSlideEnable = YES;
    
    // 相邻页面变动时是否需要展示动画
    config.animateForPageChange = YES;
    
    // 是否可以边界自由滑动
    config.pagesHorizontalBounce = NO;
    
    // 是否需要标题栏
    config.needTitleBar = YES;
    
    // 是否标题栏和header作为一个整体 (当设置为yes时 标题栏的背景颜色和背景图片将失效)
//    config.titleBarFitHeader = YES;
    
    // 标题栏高度
    config.titleBarHeight = 50;
    
    // 距离上端的悬停距离
    config.titleBarMarginTop = 64;
    
    // 是否需要标题栏底线
    config.needTitleBarBottomLine = YES;
    
    // 底线颜色
    config.titleBarBottomLineColor = [UIColor lightGrayColor];
    
    // 是否需要下滑线
    config.needTitleBarSlideLine = YES;
    
    // 下滑线跟踪方式
    config.titleBarSlideLineStyle = XDSlideLine_Scale;
    
    // 下滑线宽度比例
    config.titleBarSlideLineWidthRatio = 0.5;
    
    // 下滑线颜色
    config.titleBarSlideLineColor = [UIColor grayColor];
    
    // 标题栏背景色
    config.titleBarBackColor = [UIColor greenColor];
    
    // 标题栏背景图片
    config.titleBarBackImage = nil;
    
    // 标题栏是否可以边界自由滑动
    config.titleBarHorizontalBounce = NO;
    
    // 自定义标题栏(传入自定义的标题栏即可)
//    config.customTitleBar = myTitleBar;
    
    // 标题背景颜色
    config.titleItemBackColor = [UIColor clearColor];
    
    // 标题选中时背景颜色
    config.titleItemBackHightlightColor = [UIColor clearColor];
    
    // 标题背景图片
    config.titleItemBackImage = nil;
    
    // 标题选中时的背景图片
    config.titleItemBackHightlightImage = nil;
    
    // 是否自动计算标题宽 (当设置为yes时会自动根据标题计算宽度，自定义宽度将失效)
    config.titleFlex = YES;
    
    // 标题是否采用渐变方式(设置yes时 标题的大小和颜色在切换时会有正常到高光的渐变效果)
    config.titleGradual = YES;
    
    // 标题竖直方向对齐方式
    config.titleVerticalAlignment = XDVerticalAlignmentMiddle;
    
    // 正常标题颜色
    config.titleTextColor = [UIColor grayColor];
    
    // 高光标题颜色
    config.titleTextHightlightColor = [UIColor orangeColor];
    
    // 标题字号大小(默认16)
    config.titleFont = [UIFont systemFontOfSize:16];
    
    // 选中后的字号大小(默认18)
    config.titleHightlightFont = [UIFont systemFontOfSize:18 weight:bold];
    
    
    // ************************************设置右边按钮**********************************
    // 是否需要右按钮
    config.needRightBtn = YES;
    
    // 右按钮大小(高度最好要小于等于标题栏高度)
    config.rightBtnSize = CGSizeMake(80, 50);
    
    // 自定义右按钮
    config.rightBtn = self.rightBtn;
    
    // 顶部下拉 XDPagesPullOnTop
    _pages = [[XDPagesView alloc]initWithFrame:self.view.bounds config:config style:XDPagesPullOnTop];
    _pages.delegate = self;
    _pages.pagesHeader = self.header;
    [self.view addSubview:_pages];
    [self layoutPage];
    
    // 不能有重复标题
    _titles = @[@"普通视图",@"多列表组合",@"单列表",@"多列表组合2",@"视图"];
}

- (void)beginRefresh {
    NSLog(@"下拉刷新");
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.pages.refreshControl endRefreshing];
    });
}

- (void)rightBtnTap {
    NSLog(@"点击右按钮");
    [self.pages scrollToCeiling:YES];
}

#pragma mark -- XDPagesViewDelegate
// 必须实现以下两个代理
- (NSArray<NSString *> *)xd_pagesViewPageTitles {
    return _titles;
}

- (UIViewController *)xd_pagesView:(XDPagesView *)pagesView controllerForIndex:(NSInteger)index title:(NSString *)title {
    
    // 缓存复用控制器
    UIViewController *vc = [pagesView dequeueReusablePageForIndex:index];
    
    if (!vc) {
        if ([title isEqualToString:@"普通视图"]) {
            // 传值方式，可以通过重写init来实现传值
            Page_0 *page = [[Page_0 alloc]initByInfo:@"普通视图"];
            vc = page;
            
        } else if ([title isEqualToString:@"多列表组合"]) {
            Page_1 *page = [[Page_1 alloc]init];
            vc = page;
            
        } else if([title isEqualToString:@"单列表"]) {
            Page_2 *page = [[Page_2 alloc]init];
            vc = page;
        } else if ([title isEqualToString:@"多列表组合2"]) {
            Page_1 *page = [[Page_1 alloc]init];
            vc = page;
            
        } else if ([title isEqualToString:@"视图"]) {
            Page_0 *page = [[Page_0 alloc]initByInfo:@"视图"];
            vc = page;
        }
    }
    return vc;
}

// 以下代理非必须实现
- (void)xd_pagesViewVerticalScrollOffsetyChanged:(CGFloat)changedy isCeiling:(BOOL)ceiling {
    NSLog(@"竖直：%f",changedy);
}

- (void)xd_pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx {
    NSLog(@"水平：%f",changedx);
}

- (void)xd_pagesViewDidChangeToController:(UIViewController *const)controller index:(NSInteger)index title:(NSString *)title {
    NSLog(@"当前页面：%@",title);
}

#pragma mark -- getter
- (UIImageView *)header {
    if (!_header) {
        _header = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"xd_header.jpg"]];
        [_header setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 200)];
        _header.contentMode = UIViewContentModeScaleAspectFill;
        _header.clipsToBounds = YES;
        
    }
    return _header;
}

- (UIButton *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_rightBtn setFrame:CGRectMake(0, 0, 80, 50)];
        _rightBtn.backgroundColor = [[UIColor alloc]initWithWhite:1 alpha:0.5];
        [_rightBtn setTitle:@"右按钮" forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightBtnTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

#pragma mark -- 自适应布局
- (void)layoutPage {
    _pages.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_pages attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_pages attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_pages attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_pages attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraints:@[top, leading, bottom, trailing]];
}
@end
