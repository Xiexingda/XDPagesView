//
//  ViewController.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/13.
//  Copyright © 2020 xie. All rights reserved.
//

#import "ViewController.h"
#import "UINavigationBar+handle.h"
#import "VC_Style0.h"
#import "VC_Style1.h"
#import "VC_Style2.h"
#import "VC_Style3.h"
#import "VC_Style4.h"
#import "VC_Style5.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar navBarBottomLineHidden:YES];
    [self.navigationController.navigationBar navBarBackGroundColor:[UIColor clearColor] image:nil isOpaque:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"XDPagesStyle";
    self.view.backgroundColor = [UIColor grayColor];
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:_tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [NSLayoutConstraint activateConstraints:@[top, leading, bottom, trailing]];
    _titles = @[@"顶部下拉",@"列表下拉",@"顶部下拉刷新",@"列表下拉刷新",@"头部和标题栏一体化",@"其他用法(主要介绍自定义配置属性)"];
}

#pragma mark -- Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //顶部下拉
        VC_Style0 *root = [[VC_Style0 alloc]init];
        [self.navigationController pushViewController:root animated:YES];
        
    } else if (indexPath.row == 1) {
        //列表下拉
        VC_Style1 *root = [[VC_Style1 alloc]init];
        [self.navigationController pushViewController:root animated:YES];
        
    } else if (indexPath.row == 2) {
        //顶部下拉刷新
        VC_Style2 *root = [[VC_Style2 alloc]init];
        [self.navigationController pushViewController:root animated:YES];
        
    } else if (indexPath.row == 3) {
        //顶部下拉刷新
        VC_Style3 *root = [[VC_Style3 alloc]init];
        [self.navigationController pushViewController:root animated:YES];
        
    } else if (indexPath.row == 4) {
        //头部和标题栏一体化
        VC_Style4 *root = [[VC_Style4 alloc]init];
        [self.navigationController pushViewController:root animated:YES];
        
    } else if (indexPath.row == 5) {
        //其他用法
        VC_Style5 *root = [[VC_Style5 alloc]init];
        [self.navigationController pushViewController:root animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    }
    cell.textLabel.text = _titles[indexPath.row];
    return cell;
}
@end
