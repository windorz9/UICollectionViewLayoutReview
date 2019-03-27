//
//  SpinningWheelCollectionViewLayout.m
//  Review-01-SpinningWheel
//
//  Created by windorz9 on 2019/3/27.
//  Copyright © 2019 windorz9. All rights reserved.
//

#import "SpinningWheelCollectionViewLayout.h"
#import "SpinningWheelCollectionViewLayoutAttributes.h"

@interface SpinningWheelCollectionViewLayout ()
/* itemSize 的大小 */
@property (nonatomic, assign) CGSize itemSize;
/* 圆形的半径 */
@property (nonatomic, assign) CGFloat radius;
/* 滚动过程当中每个 Cell 的夹角 */
@property (nonatomic, assign) CGFloat anglePerItem;
/* 装 LayoutAttributes 的数组*/
@property (nonatomic, strong) NSMutableArray *attributeArrays;
@end

@implementation SpinningWheelCollectionViewLayout

+ (Class)layoutAttributesClass {
    
    return [SpinningWheelCollectionViewLayoutAttributes class];
    
}

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        self.radius = 500.0;
        self.itemSize = CGSizeMake(133, 173);
        
    }
    return self;
}

/* 集合视图第一次出现在屏幕上的时候, 将调用此方法, 每次布局生效时, 此方法也会被调用 */
- (void)prepareLayout {
    [super prepareLayout];
    
    [self.attributeArrays removeAllObjects];
    NSInteger numberOfItem = [self.collectionView numberOfItemsInSection:0];
    if (numberOfItem == 0) {
        return;
    }
    // 获取总的旋转角度
    CGFloat angleAtExtreme = (numberOfItem - 1) * self.anglePerItem;
    CGFloat angle = -1 * angleAtExtreme * self.collectionView.contentOffset.x / (self.collectionView.contentSize.width - CGRectGetWidth(self.collectionView.bounds));

    CGFloat centerX = self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.bounds) * 0.5;
    CGFloat anchorPointY = ((self.itemSize.height) / 2.0 + self.radius) / self.itemSize.height;
    
    /* 计算得出当前屏幕上应该显示的 indexPath */
    CGFloat theta = atan2(self.collectionView.bounds.size.width * 0.5, self.radius + self.itemSize.height * 0.5 - self.collectionView.bounds.size.height * 0.5);
    int startIndex = 0;
    int endIndex = (int)[self.collectionView numberOfItemsInSection:0] - 1;
    if (angle < -theta) {
        startIndex = (int)(floor(((-theta - angle) / self.anglePerItem)));
    }
    endIndex = MIN(endIndex, (int)(ceil((theta - angle) / self.anglePerItem)));
    if (endIndex < startIndex) {
        endIndex = 0;
        startIndex = 0;
    }
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < numberOfItems; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    /*
    一次显示当前所有的单元格
    for (NSIndexPath *indexPath in indexPaths) {
        SpinningWheelCollectionViewLayoutAttributes *attributes = [SpinningWheelCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = self.itemSize;
        attributes.center = CGPointMake(centerX, self.collectionView.center.y);
        attributes.angle = self.anglePerItem * indexPath.item + angle;
        attributes.anchorPoint = CGPointMake(0.5, anchorPointY);
        [layoutAttributes addObject:attributes];
    }
    **/
    // 根据当前屏幕可见的 indexPath 来显示当前的单元格
    for (int i = startIndex; i <= endIndex; i++) {
        NSIndexPath *indexPath = indexPaths[i];
        SpinningWheelCollectionViewLayoutAttributes *attributes = [SpinningWheelCollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = self.itemSize;
        attributes.center = CGPointMake(centerX, self.collectionView.center.y);
        attributes.angle = self.anglePerItem * indexPath.item + angle;
        attributes.anchorPoint = CGPointMake(0.5, anchorPointY);
        [layoutAttributes addObject:attributes];
    }
    
    self.attributeArrays = layoutAttributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributeArrays;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.attributeArrays[indexPath.item];
}



// 计算获取当前的 collectionView 的 contentSize.
- (CGSize)collectionViewContentSize {
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(numberOfItems * self.itemSize.width, CGRectGetHeight(self.collectionView.bounds));
}

/* 返回 YES 告知 CollectionView 在滑动布局过程当中布局失效, 然后会调用 prepareLayout 然后重新计算角度 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}



#pragma mark - Set&Get
// 每次半径改变时 需要重新计算所有值.
- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [self invalidateLayout];
}


- (CGFloat)anglePerItem {
    return atan(self.itemSize.width / self.radius);
}

- (NSMutableArray *)attributeArrays {
    if (!_attributeArrays) {
        _attributeArrays = [NSMutableArray array];
    }
    return _attributeArrays;
}




@end
