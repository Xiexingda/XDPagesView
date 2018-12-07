# XDPagesView
一个可以添加header的多子视图横向滚动列表
# 展示
通常用法：
![shows style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/shows.gif)
更新页面：
![showc style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/showc.gif)
# 使用方法
1，导入头文件,并添加代理XDPagesViewDataSourceAndDelegate
```
#import "XDSlideView.h"
@interface ViewController ()<XDPagesViewDataSourceDelegate>
```

2，创建一个标题数组，切记数组中不能有重复名字
```
//很关键，数组中的名字不能有重复项，该数组不止用于返回标题，还用于返回控制器的计数，类似于collectionview的numberOfItems，因此不管需不需要标题栏，都需要返回这个数组
_titles = @[@"page_0",@"page_1",@"page_2",@"page_3",@"page_4",@"page_5",@"page_6",@"page_7",@"page_8"];
```

3, 添加slideview
```
CGRect rect = self.view.bounds;

//标题栏布局，这点很酷，你完全可以在XDTitleBarLayout类里加入自定义的属性去更改标题栏的显示
XDTitleBarLayout *layout = [[XDTitleBarLayout alloc]init];
_pagesView = [[XDPagesView alloc]initWithFrame:rect dataSourceDelegate:self beginPage:0 titleBarLayout:layout];

//添加header,不加header为标题栏吸顶状态
_pagesView.headerView = myHeader;

[self.view addSubview:_pagesView];
```

5, 必须实现两个代理XDSlideViewPageTitles 和 XDSlideViewChildControllerToSlideView: forIndex:
```
- (NSArray<NSString *> *)xd_pagesViewPageTitles {
    return _titles;
}

- (UIViewController *)xd_pagesViewChildControllerToSlideView:(XDPagesView *)pagesView forIndex:(NSInteger)index {

    //复用
    UIViewController *pageVc = [pagesView dequeueReusablePageForIndex:index];

    if (!pageVc) {
        //注意:该子控制器中的必须包含一个可滚动的子view
        pageVc = [[Page alloc]initWithTag:index];
    }

    return pageVc;
}
```

6, 如果需要的话可以实现页面切换监听代理
```
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

```

# 效果

![image](https://github.com/Xiexingda/XDPagesView/blob/master/show.png)

