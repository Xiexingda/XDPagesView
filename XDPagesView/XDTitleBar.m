//
//  XDSlideBar.m
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import "XDTitleBar.h"
#import "XDTitleItemLayout.h"
#import "XDTitleItem.h"
#import "UIView+XDhandle.h"

#define RightBtnWidth 45 //右按钮宽度
#define RightImageMarginLeft 10 //按钮图案左边距
#define RightImageMarginRigth 15 //按钮图片右边距

#define itemID @"XDTitleItemID"

@interface XDTitleBar()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) XDTitleItemLayout *layout;         //collectionView的布局（_bar）
@property (nonatomic, strong) XDTitleBarLayout  *barLayout;      //titleBar的布局(self)
@property (nonatomic, strong) UICollectionView  *bar;
@property (nonatomic, strong) UIImageView *backGroundImageView;
@property (nonatomic, strong) UIView *rightBtn;
@property (nonatomic, strong) UIImageView *rightBtnImage;
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, assign) __block NSInteger selectedIndex;
@end

@implementation XDTitleBar
- (UIImageView *)backGroundImageView {
    if (!_backGroundImageView) {
        _backGroundImageView = [[UIImageView alloc]init];
        _backGroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        _backGroundImageView.clipsToBounds = YES;
    }
    return _backGroundImageView;
}

- (UIView *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [[UIView alloc]initWithFrame:CGRectZero];
        _rightBtn.userInteractionEnabled = YES;
        [_rightBtn addSubview:self.rightBtnImage];
    }
    return _rightBtn;
}

- (UIImageView *)rightBtnImage {
    if (!_rightBtnImage) {
        _rightBtnImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        _rightBtnImage.userInteractionEnabled = NO;
        _rightBtnImage.contentMode = UIViewContentModeScaleAspectFit;
        _rightBtnImage.clipsToBounds = YES;
    }
    return _rightBtnImage;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc]init];
    }
    return _bottomLine;
}

- (void)setTitles:(NSArray *)titles {
    _titles = titles;
    if (_bar) {
        [_bar reloadData];
    }
}

- (instancetype)initWithFrame:(CGRect)frame titleBarLayout:(XDTitleBarLayout *)titleBarLayout titleBarRightBtn:(void(^)(void))titleBarRightBtnBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = titleBarLayout.barBackGroundColor;
        if (titleBarLayout.barBackGroundImage && [titleBarLayout.barBackGroundImage isKindOfClass:[UIImage class]]) {
            [self.backGroundImageView setFrame:self.bounds];
            [self.backGroundImageView setImage:titleBarLayout.barBackGroundImage];
            [self addSubview:self.backGroundImageView];
        }
        self.barLayout = titleBarLayout;
        _selectedIndex = 0;
        [self creatMainUIByBarLayout:titleBarLayout itleBarRightBtn:titleBarRightBtnBlock];
    }
    return self;
}

- (void)creatMainUIByBarLayout:(XDTitleBarLayout *)titleBarLayout itleBarRightBtn:(void (^)(void))titleBarRightBtnBlock {
    
    __weak typeof(self) weakSelf = self;
    CGFloat rightBtnWidth = 0;
    //如果需要右按钮
    if (titleBarLayout.needBarRightButten) {
        //自定义按钮优先
        if (titleBarLayout.barRightCustomView && titleBarLayout.barRightCustomView.frame.size.width > 0) {
            [self addSubview:titleBarLayout.barRightCustomView];
            CGRect customBounds = titleBarLayout.barRightCustomView.bounds;
            customBounds.size.width = customBounds.size.width > self.bounds.size.width ? self.bounds.size.width : customBounds.size.width;
            customBounds.origin.x = self.bounds.size.width - customBounds.size.width;
            customBounds.size.height = self.bounds.size.height;
            [titleBarLayout.barRightCustomView setFrame:customBounds];
            rightBtnWidth = CGRectGetWidth(titleBarLayout.barRightCustomView.bounds);
            
        } else {
            [self addSubview:self.rightBtn];
            [self.rightBtn setFrame:CGRectMake(self.bounds.size.width-RightBtnWidth, 0, RightBtnWidth, self.bounds.size.height)];
            [self.rightBtnImage setFrame:CGRectMake(RightImageMarginLeft, 0, RightBtnWidth-RightImageMarginRigth-RightImageMarginLeft, self.bounds.size.height)];
            [self.rightBtnImage setImage:titleBarLayout.barRightButtenImage];
            rightBtnWidth = RightBtnWidth;
            [self.rightBtn tapBlock:^(id  _Nonnull obj) {
                titleBarRightBtnBlock();
            }];
        }
    }
    
    _layout = [[XDTitleItemLayout alloc]init];
    _layout.itemSizeBlock = ^CGSize(NSIndexPath *indexPath) {
        CGSize baseSize = [weakSelf autoSizeWithBase:titleBarLayout.barItemSize string:weakSelf.titles[indexPath.row] font:titleBarLayout.barTextFont];
        CGFloat itemWidth = baseSize.width + 20 < titleBarLayout.barItemSize.width ? titleBarLayout.barItemSize.width : baseSize.width + 20;
        
        
        if (indexPath.row == 0) {
            CGSize firstItemSize = CGSizeMake(itemWidth, titleBarLayout.barItemSize.height);
            if (titleBarLayout.needBarFirstItemIcon) {
                firstItemSize.width = itemWidth + ItemIconSize;
            }
            return firstItemSize;
        }
        return CGSizeMake(itemWidth, titleBarLayout.barItemSize.height);
    };
    
    _bar = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width-rightBtnWidth, self.bounds.size.height) collectionViewLayout:_layout];
    _bar.dataSource = self;
    _bar.delegate = self;
    _bar.bounces = titleBarLayout.barBounces;
    _bar.alwaysBounceHorizontal = titleBarLayout.barAlwaysBounceHorizontal;
    _bar.showsVerticalScrollIndicator = NO;
    _bar.showsHorizontalScrollIndicator = NO;
    _bar.backgroundColor = [UIColor clearColor];
    [self addSubview:_bar];
    _bar.hidden = rightBtnWidth == self.bounds.size.width ? YES : NO;
    
    [_bar registerClass:[XDTitleItem class] forCellWithReuseIdentifier:itemID];
    
    //页面更换通知
    self.barIndexChangedBlock = ^(NSInteger index) {
        if (!weakSelf.bar || weakSelf.selectedIndex == index) {
            return;
        }
        //先要完成布局，然后才能进行准确的滚动
        [weakSelf.bar layoutSubviews];
        [weakSelf.bar scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        weakSelf.selectedIndex = index;
        [weakSelf.bar reloadData];
    };
    
    //底线
    if (titleBarLayout.needBarBottomLine) {
        if (![self.bottomLine isDescendantOfView:self]) {
            [self addSubview:self.bottomLine];
        }
        self.bottomLine.backgroundColor = titleBarLayout.barBottomLineColor;
        [self.bottomLine setFrame:CGRectMake(0, CGRectGetHeight(self.bounds)-0.5, CGRectGetWidth(self.bounds), 0.5)];
    }
}

- (CGSize)autoSizeWithBase:(CGSize)baseSize string:(NSString *)str font:(UIFont *)font {
    CGSize cSize = CGSizeMake(MAXFLOAT, baseSize.height);
    CGSize c_msize = [str
                      boundingRectWithSize:cSize
                      options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{NSFontAttributeName:font}
                      context:nil].size;
    return c_msize;
}

#pragma mark -- datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _titles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XDTitleItem *item = [collectionView dequeueReusableCellWithReuseIdentifier:itemID forIndexPath:indexPath];
    [item configItemByTitle:_titles[indexPath.row]
                      index:indexPath
              selectedIndex:_selectedIndex
             titleBarLayout:_barLayout];
    return item;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.barItemTapBlock) {
        self.barItemTapBlock(indexPath);
    }
}

@end
