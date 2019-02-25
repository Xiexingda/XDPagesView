# XDPagesView
一个可以添加header的多子视图横向滚动列表

# 最新动态
进阶改版：将列表分为了两种风格 ，初始化列表时只需在原有基础上添加一个style 便可随心所欲的选择不同的风格
1. XDPagesViewStyleHeaderFirst 表头优先，只要header不在吸顶状态，所有列表都会相对于header复原到最顶端 （之前的风格）
2. XDPagesViewStyleTablesFirst 列表优先，不管header怎么变动，所有的列表都会保持自己上次与header的相对位置 （新增风格）

_pagesView = [[XDPagesView alloc]initWithFrame:rect dataSourceDelegate:self beginPage:1 titleBarLayout:layout style:XDPagesViewStyleTablesFirst];

如果有别的需求或发现了问题还请issue 或加群提问：

群：659700776

暗号：iOS

## 特别说明：
1. 个人不喜欢头部放大效果，所以我是不会添加个功能的😄
2.  关于header顶部下拉刷新，这个功能我也是不会加的（目前使用列表顶部刷新）。原因：由于header是所有子控制器列表所共有的，所以这种刷新方式只有一种逻辑行得通，那就是同时刷新所有子控制器，对于多控制器列表来说，同时刷新是极不明智的，而且势必涉及到继承和遵守代理协议，这不是我的初衷，我的目的是可以添加尽量多的子控制器，并且让列表中的每个控制器和单独使用时一样，有自己的管理逻辑，既不需要继承自其它控制器，也不需要遵守任何代理协议。

# 展示（DN视频 - 首页）
通常用法：
![shows style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/shows.gif)
更新页面：
![showc style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/showc.gif)

# 比较酷的点
1. 采用类似系统UICollectionView的实现方式，并且实现了对子控制器的复用缓存，使用起来非常简单
2. 采用联动的方式实现，并且优化了联动算法，不涉及手势
3. 采用类似‘懒加载’的方式加载子控制器，避免多控制器同时创建，并且可以灵活的设置缓存页数
4. 可以灵活的添加或删除header
5. 可以灵活的刷新子控制器列表
6. 可以通过header上下拖动列表

# 使用方法
###### 引入头文件 XDPagesView 并添加代理 XDPagesViewDataSourceDelegate
```
#import "XDPagesView.h"
@interface ViewController ()<XDPagesViewDataSourceDelegate>
@property (nonatomic, strong)     XDPagesView   *pagesView;
@property (nonatomic, strong) __block NSArray   *titles;
@end
```
#### 创建一个标题组，类似于collectionview的numberOfItems，因此不管需不需要标题栏，都需要返回这个数组
```
_titles = @[@"page_0",@"page_1",@"page_2",@"page_3",@"page_4",@"page_5",@"page_6",@"page_7",@"page_8",@"page_9",@"page_10"];
```
#### 创建pagesView
一. 默认方式（如果只是创建一个控制器列表，则向下面那样就可以了）
```
/*
style 有两种形式
1.XDPagesViewStyleHeaderFirst 表头优先，只要header不在吸顶状态，所有列表都会相对于header复原到最顶端
2.XDPagesViewStyleTablesFirst 列表优先，不管header怎么变动，所有的列表都会保持自己上次与header的相对位置
*/

_pagesView = [[XDPagesView alloc]initWithFrame:rect dataSourceDelegate:self beginPage:0 titleBarLayout:nil style:XDPagesViewStyleTablesFirst];
```
二. 自定义标题栏样式（如果需要对标题栏进行一些操作，那可以像下面这样写）
```
//创建标题栏样式类
XDTitleBarLayout *layout = [[XDTitleBarLayout alloc]init];
layout.needBar = YES; //默认为YES,当设置为NO时不会创建标题栏
layout.barMarginTop = 64;//标题栏距上方的悬停距离，默认为0
layout.barItemSize = CGSizeMake(75, 50); //标题item的大小，默认为80*40
//layout.barBackGroundColor = [UIColor redColor];//标题栏背景颜色（默认白色）
layout.barBackGroundImage = [UIImage imageNamed:@"demo_bar_back.png"];//标题栏背景图片
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

/*
style 有两种形式
1.XDPagesViewStyleHeaderFirst 表头优先，只要header不在吸顶状态，所有列表都会相对于header复原到最顶端
2.XDPagesViewStyleTablesFirst 列表优先，不管header怎么变动，所有的列表都会保持自己上次与header的相对位置
*/
_pagesView = [[XDPagesView alloc]initWithFrame:rect dataSourceDelegate:self beginPage:1 titleBarLayout:layout style:XDPagesViewStyleTablesFirst];
```
#### 添加header
```
//如果需要header，添加header和tableview一样。
_pagesView.headerView = yourHeader;

//可以通过滑动表头滑动列表
_pagesView.needSlideByHeader = YES;
```
#### pagesView其他属性
```
//设置缓存数（最大同时存在页数），默认为50
_pagesView.cacheNumber = 10;

//设置时候有横向反弹效果，默认为YES
_pagesView.bounces = YES;

//pagesView上方空余类似contentInset.top
_pagesView.edgeInsetTop = 0;
```
#### 代理方法
一. 两个必须实现的代理，用于返回标题组，和子控制器
```
#pragma mark -- 必须实现的代理
- (NSArray<NSString *> *)xd_pagesViewPageTitles {
    return _titles;
}

- (UIViewController *)xd_pagesViewChildControllerToPagesView:(XDPagesView *)pagesView forIndex:(NSInteger)index {

    //复用缓存
    UIViewController *pageVc = [pagesView dequeueReusablePageForIndex:index];

    if (!pageVc) {
        //这里可以通过自定义控制器的init实现控制器传参，用于控制器的review
        //注意:该子控制器中的必须包含一个可滚动的子view
        pageVc = [[Page alloc]initWithTag:index];

        /*
        如果控制器不同，可以通过索引(index==0)，或者title ([_titles[index] isEqualToString:@"page_0"])分别返回
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
#### pagesView的炫酷方法

情况一: 

如果你想通过其他按钮去跳转pagesView中的子控制器，而不是通过点击标题栏，那么你可以使用下面方法
```
//跳转到第三个控制器（索引是从0开始的）
[_pagesView jumpToPage:2];
```

情况二:

类似一些新闻客户端，需要标题栏是动态的，可以随意的添加或删除一些标题，我不知道你听到这个需求时会用什么思路去解决，但这个需求实现起来真的是非常复杂的，但是在XDPagesView中实现这个功能就简单了，简单到让你惊讶，只需要一行代码。

例如：我们把标题组修改成了下面那样，去掉了前面三个，并在后面添加了两个
```
_titles = @[@"page_3",@"page_4",@"page_5",@"page_6",@"page_7",@"page_8",@"page_9",@"page_10",@"page_11",@"page_12"];
```
还记得那个返回控制器的代理吗，你需在里面做好相关控制器的返回

这时你要做的只是需要调用一下下面的方法
```
//刷新列表后定位到第三个控制器
[_pagesView reloadataToPage:2];
```
