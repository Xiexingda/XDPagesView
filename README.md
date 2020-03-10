# XDPagesView2.0
一个可以添加header的多子视图横向滚动列表

# 最新动态(XDPagesView 2.0 来了)
XDPagesView1.0时我曾说过“不会支持头部放大，和顶端下拉刷新”，不好意思，兄弟们我食言了，虽然1.0实现方式更加简洁优雅，但随着业务的增加1.0显得越来越力不从心，在对多列表和各种控制器的支持上尤为不足，所以不得已只能升级到2.0了，但大家不需要担心，2.0依旧保持了1.0简单优雅的调用方式，甚至比1.0更加简单优雅，你总说你不认识2.0，我相信你在认识它之后，一定不会让你失望的！

## XDPagesView2.0支持的功能：
1. 支持左右上下无卡顿的顺畅滚动
2. 支持自定义header
3. 支持屏幕旋转
4. 支持普通控制器
5. 支持含有滚动控件的控制器
6. 支持含有网页的控制器
7. 支持同一页面内有多个列表的控制器
8. 支持顶部下拉刷新
9. 支持子列表下拉刷新
10. 支持子控制器生命周期的触发
11. 支持对子列表滚动位置的保持
12. 支持对某个页面内或某个滚动控件的监听取消


# 展示
顶部刷新：
![show1 style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/show1.gif)

列表刷新：
![show2 style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/show2.gif)

标题一体：
![show3 style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/show3.gif)

# XDPagesView2.0使用方法
###### 引入头文件 XDPagesView 并添加代理 XDPagesViewDelegate
```
#import "XDPagesView.h"
@interface ViewController ()<XDPagesViewDelegate>
@property (nonatomic, strong) XDPagesView   *pagesView;
@property (nonatomic, strong) NSArray   *titles;
@end
```
#### 创建一个标题组，类似于collectionview的numberOfItems，因此不管需不需要标题栏，都需要返回这个数组
```
_titles = @[@"page_0",@"page_1",@"page_2",@"page_3",@"page_4",@"page_5",@"page_6",@"page_7",@"page_8",@"page_9",@"page_10"];
```
#### 创建pagesView
```
/*
style 有两种形式
1.XDPagesPullOnTop 顶端下拉
2.XDPagesPullOnCenter 列表下拉
*/
//初始化
_pagesView = [[XDPagesView alloc]initWithFrame:self.view.bounds config:nil style:XDPagesPullOnTop];
_pagesView.delegate = self;
_pagesView.pagesHeader = self.header;
[self.view addSubview:_pagesView];
```
#### 代理方法
一. 两个必须实现的代理，用于返回标题组，和子控制器
```
#pragma mark -- 必须实现的代理
- (NSArray<NSString *> *)xd_pagesViewPageTitles {
    return _titles;
}

- (UIViewController *)xd_pagesViewChildControllerToPagesView:(XDPagesView *)pagesView forIndex:(NSInteger)index title:(NSString *)title {

    //复用缓存
    UIViewController *pageVc = [pagesView dequeueReusablePageForIndex:index];

    if (!pageVc) {
        //这里可以通过自定义控制器的init实现控制器传参，用于控制器的review
        //注意:该子控制器中的必须包含一个可滚动的子view
        pageVc = [[Page alloc]initWithTag:index];

        /*
        如果控制器不同，可以通过索引index，或者title分别返回
        if (index == 0) {
            pageVc = [[Page alloc]initWithTag:index];
        } else {
            pageVc = [[Page_other alloc]initWithTag:index];
        }
        */
    }

    return pageVc;
}

```
二. 其他代理方法
```
#pragma mark -- 非必须实现代理

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
```

# 其他炫酷用法请看demo或简书：
如果有别的需求或发现了问题还请issue 或加群提问：

群：659700776

暗号：iOS

[炫酷用法：点此跳转我的简书](https://www.jianshu.com/p/b8aa3f98af78)
