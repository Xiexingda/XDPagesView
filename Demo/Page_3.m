//
//  Page_3.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/3/3.
//  Copyright © 2020 xie. All rights reserved.
//

#import "Page_3.h"
#import <WebKit/WebKit.h>

@interface Page_3 () <WKUIDelegate,WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *web;
@end

@implementation Page_3
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Page_3_viewWillAppear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"Page_3_viewWillDisappear");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"Page_3_viewDidAppear");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"Page_3_viewDidDisappear");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.contents = (__bridge id)[UIImage imageNamed:@"xd_back.jpg"].CGImage;
    self.view.layer.contentsScale = [UIScreen mainScreen].scale;
    self.view.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.view.layer.masksToBounds = YES;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    config.ignoresViewportScaleLimits = NO;
    // 创建设置对象
    WKPreferences *preference = [[WKPreferences alloc]init];
    preference.minimumFontSize = 0;
    preference.javaScriptEnabled = YES;
    preference.javaScriptCanOpenWindowsAutomatically = YES;
    config.preferences = preference;
    _web = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:config];
    _web.backgroundColor = [[UIColor alloc]initWithWhite:1 alpha:0.5];
    _web.opaque = NO;
    _web.UIDelegate = self;
    _web.allowsBackForwardNavigationGestures = YES;
    [_web loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.jianshu.com/p/b8aa3f98af78"]]];
    [self.view addSubview:_web];
    
    _web.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_web attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_web attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_web attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_web attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [self.view addConstraints:@[top, leading, bottom, trailing]];
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}
   
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
}
    
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}
    
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
