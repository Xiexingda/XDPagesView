//
//  XDTitleItemLayout.m
//  XDSlideController
//
//  Created by 谢兴达 on 2018/8/9.
//  Copyright © 2018年 谢兴达. All rights reserved.
//

#import "XDTitleItemLayout.h"

@interface XDTitleItemLayout()
//用来记录X值
@property (nonatomic, assign) CGFloat item_x;

//用来记录高
@property (nonatomic, assign) CGFloat item_height;

//保存每一个item的attributes
@property (nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *>*attributesArray;
@end

@implementation XDTitleItemLayout
#pragma mark -- lazyLoad
- (NSMutableArray *)attributesArray {
    if (!_attributesArray) {
        _attributesArray = [NSMutableArray array];
    }
    return _attributesArray;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _item_x = 0;
        _item_height = 0;
    }
    return self;
}

//当collection开始布局时调用zz
- (void)prepareLayout {
    [super prepareLayout];
    _item_x = 0;
    _item_height = 0;
    [self.attributesArray removeAllObjects];
    
    //获取Bar中cell总个数
    NSInteger items_insection_0 = [self.collectionView numberOfItemsInSection:0];
    
    //为每一个cell 创建一个依赖
    for (int i = 0; i < items_insection_0; i ++) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [self.attributesArray addObject:attributes];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据indexPath获取item的attributes
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //从外面获取每个cell的高度
    __block CGSize item_size = CGSizeZero;
    if (self.itemSizeBlock) {
        item_size = self.itemSizeBlock(indexPath);
    }
    
    //设置attributes
    attributes.frame = CGRectMake(_item_x, 0, item_size.width, item_size.height);
    _item_x += item_size.width;
    _item_height = item_size.height;
    
    return attributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    //当bounds变化变动时不需要重绘画
    return NO;
}

//计算collectionView的contentSize
- (CGSize)collectionViewContentSize {
    return CGSizeMake(_item_x, _item_height);
}

//返回rect范围内item的attributes
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributesArray;
}
@end
