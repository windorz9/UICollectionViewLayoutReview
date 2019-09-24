//
//  LineLayout.m
//  Review-02-LineLayout
//
//  Created by windorz on 2019/9/23.
//  Copyright © 2019 Q. All rights reserved.
//

#import "LineLayout.h"

@interface LineLayout ()
/** attributes */
@property (nonatomic, strong) NSMutableArray *layoutAttributes;

@end

@implementation LineLayout

- (void)prepareLayout {
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    self.layoutAttributes = [NSMutableArray array];

    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];

    CGFloat collectionViewCenterX = self.collectionView.bounds.size.width * 0.5;

    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        UICollectionViewLayoutAttributes *copyAttribute = attribute.copy;
        // 计算和集合视图的中心横向距离差
        CGFloat deltaX = fabs(collectionViewCenterX - (copyAttribute.center.x - self.collectionView.contentOffset.x));
        // 计算屏幕显示范围内的 cell 的 transform
        if (deltaX < self.collectionView.bounds.size.width) {
            CGFloat scale = 1.0 - deltaX / collectionViewCenterX * 0.5;
            copyAttribute.transform = CGAffineTransformMakeScale(scale, scale);
            copyAttribute.alpha = scale;
        }
        [self.layoutAttributes addObject:copyAttribute];
    }
    return self.layoutAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
