//
//  VC_Style3.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/3/8.
//  Copyright © 2020 xie. All rights reserved.
//

#import "VC_Style3.h"
#import "XDPagesView.h"
#import "Page_4.h"

@interface VC_Style3 ()<XDPagesViewDelegate>
@property (nonatomic, strong) XDPagesView *pages;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIImageView *header;
@end

@implementation VC_Style3

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    // 子列表下拉 XDPagesPullOnCenter
    _pages = [[XDPagesView alloc]initWithFrame:self.view.bounds config:nil style:XDPagesPullOnCenter];
    _pages.delegate = self;
    _pages.pagesHeader = self.header;
    [self.view addSubview:_pages];
    [self layoutPage];
    
    // 不能有重复标题
    _titles = @[@"列表刷新_1",@"列表刷新_2",@"列表刷新_3",@"列表刷新_4"];
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
        Page_4 *page = [[Page_4 alloc]init];
        vc = page;
    }
    return vc;
}

// 以下代理非必须实现
- (void)xd_pagesViewVerticalScrollOffsetyChanged:(CGFloat)changedy isCeiling:(BOOL)ceiling {
    NSLog(@"竖直：%f",changedy);
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
