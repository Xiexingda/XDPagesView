//
//  XDPagesTitleBar.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/29.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesTitleBar.h"
#import "XDPagesLayout.h"
#import "XDPagesTitle.h"
#import "XDPagesTools.h"
#import "XDSlideEffect.h"

@interface XDPagesTitleBar ()<UICollectionViewDataSource,UICollectionViewDelegate,XDPagesLayouDelegate>
@property (nonatomic, strong) UICollectionView *titleBar;
@property (nonatomic, strong) XDPagesLayout *layout;
@property (nonatomic, strong) XDPagesConfig *config;
@property (nonatomic, strong) XDSlideEffect *effect;
@property (nonatomic, strong) NSArray <NSString *>*titles;
@property (nonatomic, strong) UIImageView   *backImage;
@property (nonatomic, assign) NSInteger focusIndex;
@property (nonatomic, assign) BOOL slideByTapTitle;
/**
 -------------------------------------------------
 | title_1 | title_2 | ....           | rightBtn |
 -------------------------------------------------
 */
@property (nonatomic, strong) UIView *rightBtn;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UIView *slideLine;
@end

@implementation XDPagesTitleBar
- (instancetype)initWithFrame:(CGRect)frame config:(XDPagesConfig *)config titles:(NSArray<NSString *> *)titles {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.config = config;
        self.titles = titles;
        [self creatBar];
    }
    
    return self;
}

- (void)pagesViewHorizontalScrollOffsetxChanged:(CGFloat)changedx currentPage:(NSInteger)page willToPage:(NSInteger)willToPage width:(CGFloat)width {
    
    // 保持百分比为正数
    CGFloat percent = fabs((changedx-page*width)/width);
    
    if (_config.needTitleBarSlideLine) {
        
        // 下划线滑动效果
        if (_config.titleBarSlideLineStyle == XDSlideLine_translation) {
            
            [self.effect slideLineTransEffectForView:self.slideLine
                                          attributes:_layout.allAttributes
                                         currentPage:page
                                            willPage:willToPage
                                             percent:percent
                                               ratio:_config.titleBarSlideLineWidthRatio];
            
        } else if (_config.titleBarSlideLineStyle == XDSlideLine_Scale) {
            
            [self.effect slideLineScaleEffectForView:self.slideLine
                                          attributes:_layout.allAttributes
                                         currentPage:page
                                            willPage:willToPage
                                             percent:percent
                                               ratio:_config.titleBarSlideLineWidthRatio];

        } else {
            
            [self.effect slideLineNoneEffectForView:self.slideLine
                                         attributes:_layout.allAttributes
                                        currentPage:page
                                           willPage:willToPage
                                              ratio:_config.titleBarSlideLineWidthRatio];
        }
    }
    
    // 标题渐变
    if (_config.titleGradual) {
        
        if (page != willToPage) {
            
            NSIndexPath *c_idx = [NSIndexPath indexPathForItem:page inSection:0];
            NSIndexPath *w_idx = [NSIndexPath indexPathForItem:willToPage inSection:0];
            
            XDPagesTitle *c_title = (XDPagesTitle*)[self.titleBar cellForItemAtIndexPath:c_idx];
            XDPagesTitle *w_title = (XDPagesTitle*)[self.titleBar cellForItemAtIndexPath:w_idx];
        
            [c_title gradualDownByConfig:_config percent:percent];
            [w_title gradualUpByConfig:_config percent:percent];
            
        } else {
            [self refreshTitleBarNeedReSetAttributes:NO];
        }
    }
}

#pragma mark -- delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _titles.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_focusIndex != indexPath.row) {
        self.slideByTapTitle = YES;
        [self.delegate title_tapAtIndex:indexPath.row];
        self.slideByTapTitle = NO;
        _focusIndex = indexPath.row;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XDPagesTitle *title = [collectionView dequeueReusableCellWithReuseIdentifier:@"title" forIndexPath:indexPath];
    
    [title configTitleByTitle:_titles[indexPath.row] focusIdx:_focusIndex config:_config indexPath:indexPath];
    
    return title;
}

#pragma mark -- XDPagesLayouDelegate
- (CGSize)xd_itemLayoutSizeAtIndex:(NSIndexPath *)indexPath {
    
    CGFloat c_width = _config.titleFlex ? ([XDPagesTools adjustItemWidthByString:_titles[indexPath.row] font:_config.titleFont.pointSize baseSize:CGSizeMake(MAXFLOAT, _config.titleFont.pointSize+2)]+30) : _config.titleWidth;
    
    return CGSizeMake(c_width, _config.titleBarHeight-(self.config.needTitleBarBottomLine ? 0.5 : 0));
}

#pragma mark -- getter
- (XDSlideEffect *)effect {
    if (!_effect) {
        _effect = [[XDSlideEffect alloc]init];
    }
    
    return _effect;
}

- (UIImageView *)backImage {
    if (!_backImage) {
        _backImage = [[UIImageView alloc] initWithImage:self.config.titleBarBackImage];
        _backImage.contentMode = UIViewContentModeScaleAspectFill;
        _backImage.backgroundColor = self.config.titleBarBackColor;
        _backImage.clipsToBounds = YES;
    }
    
    return _backImage;
}

- (UICollectionView *)titleBar {
    if (!_titleBar) {
        
        _layout = [[XDPagesLayout alloc]init];
        _layout.needPrepareLayout = YES;
        
        _titleBar = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:_layout];
        _layout.delegate = self;
        _titleBar.delegate = self;
        _titleBar.dataSource = self;
        _titleBar.alwaysBounceHorizontal = YES;
        _titleBar.showsVerticalScrollIndicator = NO;
        _titleBar.showsHorizontalScrollIndicator = NO;
        _titleBar.backgroundColor = [UIColor clearColor];
        _titleBar.bounces = _config.titleBarHorizontalBounce;
        [_titleBar registerClass:XDPagesTitle.class forCellWithReuseIdentifier:@"title"];
    }
    
    return _titleBar;
}

- (UIView *)rightBtn {
    if (!_rightBtn) {
        _rightBtn = [[UIView alloc]initWithFrame:CGRectZero];
        _rightBtn.backgroundColor = [UIColor clearColor];
        _rightBtn.clipsToBounds = YES;
        _rightBtn.hidden = !self.config.needRightBtn;
    }
    
    return _rightBtn;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0.5)];
        _bottomLine.backgroundColor = _config.titleBarBottomLineColor;
        _bottomLine.hidden = !_config.needTitleBarBottomLine;
    }
    
    return _bottomLine;
}

- (UIView *)slideLine {
    if (!_slideLine) {
        CGFloat height = 3;
        UICollectionViewLayoutAttributes *attributes = _layout.allAttributes[_config.beginPage];
        CGFloat c_hf_width = CGRectGetWidth(attributes.frame)*_config.titleBarSlideLineWidthRatio/2.0;
        _slideLine = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(attributes.frame)-c_hf_width, _config.titleBarHeight-height-(_config.needTitleBarBottomLine ? 0.5 : 0), c_hf_width*2, height)];
        _slideLine.clipsToBounds = YES;
        _slideLine.layer.cornerRadius = height/2.0;
        _slideLine.backgroundColor = _config.titleBarSlideLineColor;
        _slideLine.hidden = !_config.needTitleBarSlideLine;
    }
    
    return _slideLine;
}

- (void (^)(NSArray<NSString *> *))refreshTitles {
    __weak typeof(self) weakSelf = self;
    return ^(NSArray <NSString *> *titles) {
        weakSelf.titles = titles;
        [weakSelf refreshTitleBarNeedReSetAttributes:YES];
    };
}

- (void (^)(NSInteger))currentFocusIndex {
    __weak typeof(self) weakSelf = self;
    return ^(NSInteger focusIndex) {
        [weakSelf.titleBar setNeedsLayout];
        [weakSelf.titleBar layoutSubviews];
        [weakSelf.titleBar scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:focusIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        weakSelf.focusIndex = focusIndex;
        [weakSelf refreshTitleBarNeedReSetAttributes:NO];
    };
}

#pragma mark - Private
- (void)refreshTitleBarNeedReSetAttributes:(BOOL)need {
    self.layout.needPrepareLayout = need;
    [self.titleBar reloadData];
}

#pragma mark -- UI
- (void)creatBar {
    
    [self addSubview:self.backImage];
    [self addSubview:self.titleBar];
    [self addSubview:self.rightBtn];
    [self addSubview:self.bottomLine];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.titleBar addSubview:self.slideLine];
    });
    
    self.backImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.rightBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 背景
    NSLayoutConstraint *back_top = [NSLayoutConstraint
                                    constraintWithItem:self.backImage
                                    attribute:NSLayoutAttributeTop
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                    attribute:NSLayoutAttributeTop
                                    multiplier:1
                                    constant:0];
    NSLayoutConstraint *back_lef = [NSLayoutConstraint
                                    constraintWithItem:self.backImage
                                    attribute:NSLayoutAttributeLeading
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                    attribute:NSLayoutAttributeLeading
                                    multiplier:1
                                    constant:0];
    NSLayoutConstraint *back_btm = [NSLayoutConstraint
                                    constraintWithItem:self.backImage
                                    attribute:NSLayoutAttributeBottom
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                    attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                    constant:0];
    NSLayoutConstraint *back_rit = [NSLayoutConstraint
                                    constraintWithItem:self.backImage
                                    attribute:NSLayoutAttributeTrailing
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                    attribute:NSLayoutAttributeTrailing
                                    multiplier:1
                                    constant:0];
    [NSLayoutConstraint activateConstraints:@[back_top, back_lef, back_btm, back_rit]];
    
    // 标题栏
    NSLayoutConstraint *title_top = [NSLayoutConstraint
                                     constraintWithItem:self.titleBar
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeTop
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *title_led = [NSLayoutConstraint
                                     constraintWithItem:self.titleBar
                                     attribute:NSLayoutAttributeLeading
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeLeading
                                     multiplier:1
                                     constant:0];
    NSLayoutConstraint *title_btm = [NSLayoutConstraint
                                     constraintWithItem:self.titleBar
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self
                                     attribute:NSLayoutAttributeBottom
                                     multiplier:1
                                     constant:(self.config.needTitleBarBottomLine ? -0.5 : 0)];
    NSLayoutConstraint *title_tal = [NSLayoutConstraint
                                     constraintWithItem:self.titleBar
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.rightBtn
                                     attribute:NSLayoutAttributeLeft
                                     multiplier:1
                                     constant:0];
    [NSLayoutConstraint activateConstraints:@[title_top, title_led, title_btm, title_tal]];
    
    // 右按钮
    NSLayoutConstraint *btn_top = [NSLayoutConstraint
                                   constraintWithItem:self.rightBtn
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                   attribute:NSLayoutAttributeTop
                                   multiplier:1
                                   constant:0];
    NSLayoutConstraint *btn_led = [NSLayoutConstraint
                                   constraintWithItem:self.rightBtn
                                   attribute:NSLayoutAttributeLeft
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.titleBar
                                   attribute:NSLayoutAttributeRight
                                   multiplier:1
                                   constant:0];
    NSLayoutConstraint *btn_btm = [NSLayoutConstraint
                                   constraintWithItem:self.rightBtn
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                   attribute:NSLayoutAttributeBottom
                                   multiplier:1
                                   constant:(self.config.needTitleBarBottomLine ? -0.5 : 0)];
    NSLayoutConstraint *btn_tal = [NSLayoutConstraint
                                   constraintWithItem:self.rightBtn
                                   attribute:NSLayoutAttributeTrailing
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self
                                   attribute:NSLayoutAttributeTrailing
                                   multiplier:1
                                   constant:0];
    NSLayoutConstraint *btn_width = [NSLayoutConstraint
                                     constraintWithItem:self.rightBtn
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1
                                     constant:(self.config.needRightBtn ? self.config.rightBtnSize.width : 0)];
    [NSLayoutConstraint activateConstraints:@[btn_top, btn_led, btn_btm, btn_tal, btn_width]];
    
    // 底线
    NSLayoutConstraint *bottom_bottom = [NSLayoutConstraint
                                         constraintWithItem:self.bottomLine
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                         attribute:NSLayoutAttributeBottom
                                         multiplier:1
                                         constant:0];
    NSLayoutConstraint *bottom_left = [NSLayoutConstraint
                                       constraintWithItem:self.bottomLine
                                       attribute:NSLayoutAttributeLeading
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:self
                                       attribute:NSLayoutAttributeLeading
                                       multiplier:1
                                       constant:0];
    NSLayoutConstraint *bottom_right = [NSLayoutConstraint
                                        constraintWithItem:self.bottomLine
                                        attribute:NSLayoutAttributeTrailing
                                        relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                        attribute:NSLayoutAttributeTrailing
                                        multiplier:1
                                        constant:0];
    NSLayoutConstraint *bottom_height = [NSLayoutConstraint
                                         constraintWithItem:self.bottomLine
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                         multiplier:1
                                         constant:(self.config.needTitleBarBottomLine ? 0.5 : 0)];
    [NSLayoutConstraint activateConstraints:@[bottom_bottom, bottom_left, bottom_right, bottom_height]];
    
    if (_config.needRightBtn) {
        
        [self layoutIfNeeded];
        
        [_config.rightBtn setFrame:CGRectMake(0, 0, _config.rightBtnSize.width, _config.rightBtnSize.height-(self.config.needTitleBarBottomLine ? 0.5 : 0))];
        
        if (![self.rightBtn isDescendantOfView:_config.rightBtn]) {
            [self.rightBtn addSubview:_config.rightBtn];
        }
    }
}
@end
