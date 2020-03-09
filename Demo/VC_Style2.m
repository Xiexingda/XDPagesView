//
//  VC_Style2.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/3/8.
//  Copyright © 2020 xie. All rights reserved.
//

#import "VC_Style2.h"
#import "XDPagesView.h"
#import "Page_0.h"
#import "Page_1.h"
#import "Page_2.h"
#import "Page_3.h"

@interface VC_Style2 ()<XDPagesViewDelegate>
@property (nonatomic, strong) XDPagesView *pages;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIImageView *header;
@end

@implementation VC_Style2
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    //顶部下拉刷新时需要设置列表风格为 XDPagesPullOnTop
    _pages = [[XDPagesView alloc]initWithFrame:self.view.bounds config:nil style:XDPagesPullOnTop];
    _pages.delegate = self;
    _pages.pagesHeader = self.header;
    [self.view addSubview:_pages];
    [self layoutPage];
    
    /*
     说明：由于不想把主列表暴露出来，所以顶部刷新只支持系统下拉刷新，
          如果需要其他刷新，可以自行把XDPagesView.m内的mainTable移到.h文件中。（只可用来做刷新，不可更改其属性，frame等）
     */
    UIRefreshControl *downRefresh = [[UIRefreshControl alloc]init];
    [downRefresh addTarget:self action:@selector(beginRefresh) forControlEvents:UIControlEventValueChanged];
    [_pages setRefreshControl:downRefresh];
    
    //不能有重复标题
    _titles = @[@"普通视图",@"多列表组合",@"单列表",@"网页"];
}

- (void)beginRefresh {
    NSLog(@"顶部下拉刷新");
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //停止刷新
        [weakSelf.pages.refreshControl endRefreshing];
    });
}

#pragma mark -- XDPagesViewDelegate
//必须实现以下两个代理
- (NSArray<NSString *> *)xd_pagesViewPageTitles {
    return _titles;
}

- (UIViewController *)xd_pagesViewChildControllerToPagesView:(XDPagesView *)pagesView forIndex:(NSInteger)index title:(NSString *)title {
    
    //缓存复用控制器
    UIViewController *vc = [pagesView dequeueReusablePageForIndex:index];
    
    if (!vc) {
        if ([title isEqualToString:@"普通视图"]) {
            //传值方式，可以通过重写init来实现传值
            Page_0 *page = [[Page_0 alloc]initByInfo:@"普通视图"];
            vc = page;
            
        } else if ([title isEqualToString:@"多列表组合"]) {
            Page_1 *page = [[Page_1 alloc]init];
            vc = page;
            
        } else if([title isEqualToString:@"单列表"]) {
            Page_2 *page = [[Page_2 alloc]init];
            vc = page;
            
        } else if([title isEqualToString:@"网页"]) {
            Page_3 *page = [[Page_3 alloc]init];
            vc = page;
        }
    }
    return vc;
}

//以下代理非必须实现
- (void)xd_pagesViewVerticalScrollOffsetyChanged:(CGFloat)changedy {
//    NSLog(@"竖直：%f",changedy);
}
- (void)xd_pagesViewDidChangeToPageController:(UIViewController *const)pageController title:(NSString *)pageTitle pageIndex:(NSInteger)pageIndex {
    NSLog(@"当前页面：%@",pageTitle);
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
