//
//  XDPagesLayout.m
//  XDPagesView
//
//  Created by 谢兴达 on 2020/2/29.
//  Copyright © 2020 xie. All rights reserved.
//

#import "XDPagesLayout.h"

@interface XDPagesLayout ()
// 用来记录X值
@property (nonatomic, assign) CGFloat item_x;

// 用来记录高
@property (nonatomic, assign) CGFloat item_height;

// 保存每一个item的attributes
@property (nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *>*attributesArray;
@end
@implementation XDPagesLayout
- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _item_x = 0;
        _item_height = 0;
        _attributesArray = @[].mutableCopy;
    }
    
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    //关掉预估取值，否则在某些机型上可能会崩溃
    if (@available(iOS 10.0, *)) {
        if ([self.collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
            self.collectionView.prefetchingEnabled = NO;
        }
    }
    
    _item_x = 0;
    _item_height = 0;
    [self.attributesArray removeAllObjects];
    
    // 获取Bar中cell总个数
    NSInteger items_insection_0 = [self.collectionView numberOfItemsInSection:0];
    
    // 为每一个cell 创建一个依赖
    for (int i = 0; i < items_insection_0; i ++) {
        UICollectionViewLayoutAttributes *item_attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [self.attributesArray addObject:item_attributes];
    }
    
    self.allAttributes = [self.attributesArray copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 根据indexPath获取item的attributes
    UICollectionViewLayoutAttributes *item_attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 从外面获取每个cell的高度
    CGSize item_size = [self.delegate xd_itemLayoutSizeAtIndex:indexPath];

    // 设置attributes
    item_attribute.frame = CGRectMake(_item_x, 0, item_size.width, item_size.height);
    _item_x += item_size.width;
    _item_height = item_size.height;
    
    return item_attribute;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(_item_x, _item_height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributesArray;
}

@end
