//
//  ViewController.m
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import "ViewController.h"
#import "XDPagesView.h"
#import "Page.h"
#import "UIView+XDhandle.h"

@interface ViewController ()<XDPagesViewDataSourceDelegate>
@property (nonatomic, strong)  NSMutableArray   *currentItems;
@property (nonatomic, strong)     XDPagesView   *pagesView;
@property (nonatomic, strong) __block NSArray   *titles;
@end

@implementation ViewController

- (void)btnTap {
    NSLog(@"自定义按钮点击");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //很关键，数组中的名字不能有重复项，该数组不止用于返回标题，还用于返回控制器的计数，类似于collectionview的numberOfItems，因此不管需不需要标题栏，都需要返回这个数组
    _titles = @[@"page_0",@"page_1",@"page_2",@"page_3",@"page_4",@"page_5",@"page_6",@"page_7",@"page_8",@"page_9",@"page_10",@"page_11",@"page_12",@"page_13",@"page_14",@"page_15",@"page_16",@"page_17",@"page_18",@"page_19",@"page_20",@"page_21",@"page_22",@"page_23",@"page_24",@"page_25",@"page_26",@"page_27",@"page_28",@"page_29"];
    
    CGRect rect = self.view.bounds;
    
    //标题栏布局，这点很酷，你完全可以在XDSlideBarLayout类里加入自定义的属性去更改标题栏的显示
    XDTitleBarLayout *layout = [[XDTitleBarLayout alloc]init];
    //layout.needBar = YES; //默认为YES,当设置为NO时不会创建标题栏
    layout.barMarginTop = 64;//标题栏距上方的悬停距离，默认为0
    //layout.barItemSize = CGSizeMake(75, 50); //标题item的大小，默认为80*40
    layout.needBarFirstItemIcon = YES; //需要第一个标题有图标
    layout.firstItemIconNormal = [UIImage imageNamed:@"demo_bar_icon.png"]; //第一个标题的图标
    layout.firstItemIconSelected = [UIImage imageNamed:@"demo_bar_iconSelected.png"];//第一个标题选中时的图标
    layout.needBarRightButten = YES;//需要右按钮，此时如果没有自定义按钮就会创建一个默认按钮
    layout.barRightButtenImage = [UIImage imageNamed:@"demo_bar_rightimage.png"];//设置默认按钮背景图片
    
    /*
     如果需要自定义按钮则需要传入一个自定义视图或者按钮，并且此时不会创建默认按钮
     
    UIButton *mybtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [mybtn setFrame:CGRectMake(0, 0, 100, 50)];
    [mybtn addTarget:self action:@selector(btnTap) forControlEvents:UIControlEventTouchUpInside];
    [mybtn setTitle:@"自定义" forState:UIControlStateNormal];
    [mybtn setTintColor:[UIColor redColor]];
    [mybtn setBackgroundColor:[UIColor lightGrayColor]];
    layout.barRightCustomView = mybtn;
    */
    _pagesView = [[XDPagesView alloc]initWithFrame:rect dataSourceDelegate:self beginPage:0 titleBarLayout:layout];
    
    //设置缓存数（最大同时存在页数），默认为50
    //_pagesView.cacheNumber = 10;
    
    //设置时候有横向反弹效果，默认为NO
    //_pagesView.bounces = YES;
    
    //pagesView上方空余类似contentInset.top
    //_pagesView.edgeInsetTop = 0;

    //添加header,不加header为标题栏吸顶状态
    UIImageView *header = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    header.backgroundColor = [UIColor yellowColor];
    header.image = [UIImage imageNamed:@"App_header_cover"];
    _pagesView.headerView = header;
    
    [self.view addSubview:_pagesView];
}

#pragma mark -- XDSlideViewDataSourceAndDelegate
#pragma mark -- 必须实现代理
- (NSArray<NSString *> *)xd_pagesViewPageTitles {
    return _titles;
}

- (UIViewController *)xd_pagesViewChildControllerToPagesView:(XDPagesView *)pagesView forIndex:(NSInteger)index {
   
    //复用
    UIViewController *pageVc = [pagesView dequeueReusablePageForIndex:index];
    
    if (!pageVc) {
        //这里可以通过自定义控制器的init实现控制器传参，用于控制器的review
        //注意:该子控制器中的必须包含一个可滚动的子view
        pageVc = [[Page alloc]initWithTag:index];
        
        /*
         如果控制器不同，可以通过索引，或者title分别返回
        if (index == 0) {
            pageVc = [[Page alloc]initWithTag:index];
        } else {
            pageVc = [[Page_other alloc]initWithTag:index];
        }
         */
    }
    
    return pageVc;
}

#pragma mark -- 非必须实现代理
- (void)xd_pagesViewTitleBarRightBtnTap {
    NSLog(@"点击右边按钮");
}

- (void)xd_pagesViewDidChangeToPageController:(UIViewController *const)pageController title:(NSString *)pageTitle pageIndex:(NSInteger)pageIndex {
    //页面已经变化时调用
    NSLog(@"XDPagesView_title:%@ --- index: %ld",pageTitle, (long)pageIndex);
}

- (void)xd_pagesViewVerticalScrollOffsetyChanged:(CGFloat)changedy {
    //垂直变动
    NSLog(@"XDPagesView_Y:%f",changedy);
}

- (void)xd_pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx {
    //水平变动
    NSLog(@"XDPagesView_X:%f",changedx);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
