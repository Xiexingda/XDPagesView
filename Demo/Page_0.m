//
//  Page_0.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/3/3.
//  Copyright © 2020 xie. All rights reserved.
//

#import "Page_0.h"

@interface Page_0 ()
@property (nonatomic, strong) id info;
@end

@implementation Page_0
- (instancetype)initByInfo:(id)info {
    self = [super init];
    if (self) {
        _info = info;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Page_0_viewWillAppear");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"Page_0_viewWillDisappear");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"Page_0_viewDidAppear");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"Page_0_viewDidDisappear");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.contents = (__bridge id)[UIImage imageNamed:@"xd_back.jpg"].CGImage;
    self.view.layer.contentsScale = [UIScreen mainScreen].scale;
    self.view.layer.contentsGravity = kCAGravityResizeAspectFill;
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
