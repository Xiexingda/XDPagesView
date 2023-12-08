# XDPagesView

# 最近更新2023-12-7(未在cocopods更新，直接把XDPagesView文件夹拉入项目中)

#功能简介：
- XDPagesView是一个多控制器视图，代码结构简单，拥有极多的自定义配置项，使用起来非常简介灵活（该控件不采用分类，也不需要继承，对源代码没有任何代码污染）

1. 支持横竖屏
2. 支持刷新列表
3. 支持暗夜模式
4. 支持header视图
5. 还有很多，就不一一列举了，自己看吧...

#基本用法:


```
#import "XDPagesView.h"
    
    
@interface Demo ()<XDPagesViewDelegate>
...
@end

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //配置项，可以做一些自定义配置
    XDPagesConfig *config = [XDPagesConfig config];
    
    // 顶部下拉 XDPagesPullOnTop
    XDPagesView *pagesView = [[XDPagesView alloc]initWithFrame:self.view.bounds config:config style:XDPagesPullOnTop];
    
    //遵循代理
    pagesView.delegate = self;
    
    //设置header试图
    pagesView.pagesHeader = self.header;
    
    [self.view addSubview:pagesView];
 }
    
    
 #pragma mark -- XDPagesViewDelegate 必须实现以下两个代理   
    
/*
    返回一个标题组
    标题作为每个页面的唯一，不能重复
*/
- (NSArray<NSString *> *)xd_pagesViewPageTitles {
    return @[@"标题一", @"标题二", @"标题三"];
}
    
- (UIViewController *)xd_pagesView:(XDPagesView *)pagesView controllerForIndex:(NSInteger)index title:(NSString *)title {
    
    // 缓存复用控制器
    UIViewController *vc = [pagesView dequeueReusablePageForIndex:index];
    
    if (!vc) {
        if (index == 0) {
            // 传值方式，可以通过重写init来实现传值
            Page_0 *page = [[Page_0 alloc]init];
            vc = page; 
        } 
        else if (index == 1) {
            Page_1 *page = [[Page_1 alloc]init];
            vc = page;
        } 
        else if(index == 2) {
            Page_2 *page = [[Page_2 alloc]init];
            vc = page;  
        } 
    }
    
    return vc;
}
    
```

# 基础功能

####1. 跳转到某一页

```
应用场景:
想要切换到某个页面，可以使用下面两个方法

功能方法：
- (void)jumpToPage:(NSInteger)page;
- (void)jumpToPage:(NSInteger)page animate:(BOOL)animate;

使用示例:
[pagesView jumpToPage:1];
```

####2. 刷新列表

```
应用场景:
当控制器列表有变动时，可以刷新列表，
比如开始只有控制@[@"标题一", @"标题二", @"标题三"]，后来又添加了一个变成了@[@"标题一", @"标题二", @"标题三", @"标题四"]

功能方法：刷新列表后定位到哪一页
- (void)reloadataToPage:(NSInteger)page;

使用示例:
[pagesView reloadataToPage:1];
```

####3. 刷新配置

```
应用场景:
当要对某些配置进行更改时，可以通过刷新配置来实现，比如暗黑模式的处理（注意* 有些属性是不能被刷新的，具体可参考代码里注释）

功能方法：
- (void)reloadConfigs;

使用示例:

//初始化时，我们把标题栏配置成绿色
XDPagesConfig *config = [XDPagesConfig config];
config.titleBarBackColor = [UIColor greenColor];
XDPagesView *pagesView = [[XDPagesView alloc]initWithFrame:self.view.bounds config:config style:XDPagesPullOnTop];
pagesView.delegate = self;
pagesView.pagesHeader = self.header;
[self.view addSubview:pagesView];


//暗夜模式时我们需要把导航栏变成黄色
config.titleBarBackColor = [UIColor yellowColor];
//配置更改后，调用刷新会立即生效
[pagesView reloadConfigs];
```

####4. 滚动到吸顶位置

```
应用场景:
在某些情况下，为了让列表展示的内容更多，可能需要把列表滚动到吸顶位置

功能方法：
- (void)scrollToCeiling:(BOOL)animate;

使用示例:
[pagesView scrollToCeiling:YES];
```

####5. 添加标题栏未读标记

```
应用场景:
通知，未读消息

功能方法：
/**
 展示标题栏某个页面的未读消息
 @param number 未读数，当为0时隐藏
 @param idx 对应索引
 @param color badge颜色
 @param isNumber 是否显示数字
 */
- (void)showBadgeNumber:(NSInteger)number index:(NSInteger)idx color:(UIColor *)color isNumber:(BOOL)isNumber;

使用示例: 在第一个标题上展示有五个未读消息
[pagesView showBadgeNumber:5 index:0 color:[UIColor greenColor] isNumber:YES];
```

#其他可用delegate

```
/**
 已经跳到的当前界面
 @param controller 当前控制器
 @param index 索引
 @param title 标题
 */
- (void)xd_pagesViewDidChangeToController:(UIViewController *const)controller index:(NSInteger)index title:(NSString *)title {

}

/**
 竖直滚动监听
 @param changedy 竖直offset.y
 @param ceiling 是否已吸顶
 */
- (void)xd_pagesViewVerticalScrollOffsetyChanged:(CGFloat)changedy isCeiling:(BOOL)ceiling {

}

/**
 水平滚动监听
 @param changedx 水平offset.x
 @param currentPage 当前页
 @param willShowPage 目标页
 */
- (void)xd_pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx currentPage:(NSInteger)currentPage willShowPage:(NSInteger)willShowPage {
    
}

/**
 自定义标题宽度 (注意* 只有当config.titleFlex=NO的时候，该代理才会生效)
 @param index 索引
 @param title 标题
 */
- (CGFloat)xd_pagesViewTitleWidthForIndex:(NSInteger)index title:(NSString *)title {
    return 100;
}

```

#详细XDPagesConfig配置项
####具体可参考demo中的<其他用法>
####注意*：其中标记了(⚠️不可被刷新)的配置，不能会在调用- (void)reloadConfigs方法时刷新

```
/**
 titleBar的下划指示线展示效果
 */
typedef NS_ENUM(NSInteger, SlideLineStyle) {
    XDSlideLine_None,          // 下划线无展示效果
    XDSlideLine_Scale,         // 下划线伸缩
    XDSlideLine_translation    // 下划线平移(默认效果)
};

/**
 titleBar的标题文字对齐方式
 */
typedef NS_ENUM(NSInteger, TitleVerticalAlignment) {
    XDVerticalAlignmentTop = 0, //标题顶部垂直对齐
    XDVerticalAlignmentMiddle,  //标题中部垂直对齐
    XDVerticalAlignmentBottom,  //标题底部垂直对齐
};


@property (nonatomic, assign) NSInteger beginPage;                  // 起始页(⚠️不可被刷新)
@property (nonatomic, assign) NSInteger maxCacheCount;              // 最大缓存页数
@property (nonatomic, assign) BOOL pagesSlideEnable;                // 是否可滑动翻页（默认YES）
@property (nonatomic, assign) BOOL animateForPageChange;            // 页面变动时是否需要动画（默认YES）
@property (nonatomic, assign) BOOL pagesHorizontalBounce;           // 是否页面边界自由滑动（默认YES）

@property (nonatomic, assign) BOOL needTitleBar;                    // 是否需要标题栏（默认YES）(⚠️不可被刷新)
@property (nonatomic, assign) BOOL titleBarFitHeader;               // 是否标题栏和header作为一个整体（默认NO）(⚠️不可被刷新)
@property (nonatomic, assign) CGFloat titleBarHeight;               // 标题栏高度（默认50）(⚠️不可被刷新)
@property (nonatomic, assign) CGFloat titleBarMarginTop;            // 悬停位置距上端距离（默认0）
@property (nonatomic, assign) BOOL needTitleBarBottomLine;          // 是否需要标题栏底线（默认YES）
@property (nonatomic, strong) UIColor *titleBarBottomLineColor;     // 底线颜色（默认浅灰色）
@property (nonatomic, assign) BOOL needTitleBarSlideLine;           // 是否需要下滑线（默认YES）
@property (nonatomic, assign) SlideLineStyle titleBarSlideLineStyle;// 下划线跟随方式
@property (nonatomic, assign) CGFloat titleBarSlideLineWidthRatio;  // 下滑线相对于当前item宽的比例[0-1]
@property (nonatomic, strong) UIColor *titleBarSlideLineColor;      // 下滑线颜色（默认灰色）
@property (nonatomic, strong) UIColor *titleBarBackColor;           // 标题栏背景色
@property (nonatomic, strong) UIImage *titleBarBackImage;           // 标题栏背景图
@property (nonatomic, assign) BOOL titleBarHorizontalBounce;        // 标题栏是否可以边界自由滑动（默认YES）
@property (nonatomic, strong) UIView *customTitleBar;               // 自定义标题栏(⚠️不可被刷新)

@property (nonatomic, strong) UIColor *titleItemBackColor;          // 标题背景颜色
@property (nonatomic, strong) UIColor *titleItemBackHightlightColor;// 标题选中时背景颜色
@property (nonatomic, strong) UIImage *titleItemBackImage;          // 标题背景图片
@property (nonatomic, strong) UIImage *titleItemBackHightlightImage;// 标题选中时的背景图片

@property (nonatomic, assign) BOOL titleFlex;                       // 是否自动计算标题宽（默认YES）
@property (nonatomic, assign) BOOL titleGradual;                    // 是否采用渐变方式(默认YES,只渐变标题属性)
@property (nonatomic, assign) TitleVerticalAlignment titleVerticalAlignment; // 标题竖直对齐方式
@property (nonatomic, strong) UIColor *titleTextColor;              // 标题颜色
@property (nonatomic, strong) UIColor *titleTextHightlightColor;    // 标题选中时的颜色
@property (nonatomic, strong) UIFont *titleFont;                    // 标题字号大小(默认16)
@property (nonatomic, strong) UIFont *titleHightlightFont;          // 选中后的字号大小(默认18)

@property (nonatomic, assign) BOOL needRightBtn;                    // 是否需要右按钮（默认NO）(⚠️不可被刷新)
@property (nonatomic, assign) CGSize rightBtnSize;                  // 右按钮大小
@property (nonatomic, strong) UIView *rightBtn;                     // 右按钮自定义视图
```


# 展示

![show1 style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/show1.gif)
![show2 style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/show2.gif)
![show3 style.gifo动](https://github.com/Xiexingda/XDPagesView/blob/master/show3.gif)


# 如果有别的需求或发现了问题还请issue 或加群提问：

群：659700776

暗号：iOS
