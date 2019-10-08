//
//  FSPagerViewLayout.m
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/26.
//  Copyright © 2019 Q. All rights reserved.
//

#import "FSPagerViewLayout.h"
#import "FSPagerView.h"
#import "FSPagerViewLayoutAttributes.h"
#import "FSPagerViewTransformer.h"

@interface FSPagerViewLayout ()
/** pagerView */
@property (nonatomic, strong) FSPagerView *pagerView;
/** collectionViewSize */
@property (nonatomic, assign) CGSize collectionViewSize;
/** number of sections */
@property (nonatomic, assign) NSInteger numberOfSections;
/** number of item */
@property (nonatomic, assign) NSInteger numberOfItems;
/** actualInteritemSpacing */
@property (nonatomic, assign) CGFloat actualInteritemSpacing;
/** actualItemSize */
@property (nonatomic, assign) CGSize actualItemSize;

@end

@implementation FSPagerViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)prepareLayout {
    UICollectionView *collectionView = self.collectionView;
    FSPagerView *pagerView = self.pagerView;
    if (!collectionView || !pagerView) {
        return;
    }
    self.needsReprepare = NO;
    self.collectionViewSize = collectionView.frame.size;

    self.numberOfSections = [pagerView numberOfSectionsInCollectionView:collectionView];
    self.numberOfItems = [pagerView collectionView:collectionView numberOfItemsInSection:0];

    self.actualItemSize = CGSizeEqualToSize(pagerView.itemSize, CGSizeZero) ? collectionView.frame.size : pagerView.itemSize;
    self.actualInteritemSpacing = pagerView.transformer ? [pagerView.transformer proposedInteritemSpacing] : pagerView.interitemSpacing;
    self.scrollDirection = pagerView.scrollDirection;
    self.leadingSpacing = (self.scrollDirection == FSPagerViewScrollDirectionHorizontal) ? (collectionView.frame.size.width - self.actualItemSize.width) * 0.5 : (collectionView.frame.size.height - self.actualItemSize.height) * 0.5;
    self.itemSpacing = ((self.scrollDirection == FSPagerViewScrollDirectionHorizontal) ? self.actualItemSize.width : self.actualItemSize.height) + self.actualInteritemSpacing;

    // 计算缓存 contentSize 而不是每次都去计算.
    NSInteger numberOfItems = self.numberOfSections * self.numberOfItems;
    if (self.scrollDirection == FSPagerViewScrollDirectionHorizontal) {
        CGFloat contentSizeWidth = self.leadingSpacing * 2;
        contentSizeWidth += (numberOfItems - 1) * self.actualInteritemSpacing;
        contentSizeWidth += (numberOfItems) * self.actualItemSize.width;
        self.contentSize = CGSizeMake(contentSizeWidth, collectionView.frame.size.height);
    } else {
        CGFloat contentSizeHeight = self.leadingSpacing * 2;
        contentSizeHeight += (numberOfItems - 1) * self.actualInteritemSpacing;
        contentSizeHeight += numberOfItems * self.actualItemSize.height;
        self.contentSize = CGSizeMake(collectionView.frame.size.width, contentSizeHeight);
    }
    [self _adjustCollectionViewBounds];
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes = [NSMutableArray array];
    if (self.itemSpacing <= 0 || CGRectIsEmpty(rect)) {
        return layoutAttributes;
    }
    rect = CGRectIntersection(rect, CGRectMake(0, 0, self.contentSize.width, self.contentSize.height));
    if (CGRectIsEmpty(rect)) {
        return layoutAttributes;
    }
    // 计算当前的 position 和 rect
    NSInteger numberOfItemsBefore = (self.scrollDirection == FSPagerViewScrollDirectionHorizontal) ?
        MAX((int)((CGRectGetMinX(rect) - self.leadingSpacing) / self.itemSpacing), 0) :
        MAX((int)((CGRectGetMinY(rect) - self.leadingSpacing) / self.itemSpacing), 0);

    CGFloat startPosition = self.leadingSpacing + numberOfItemsBefore * self.itemSpacing;
    NSInteger startIndex = numberOfItemsBefore;
    // 创建 attributes
    NSInteger itemIndex = startIndex;
    CGFloat origin = startPosition;

    CGFloat maxPosition = self.scrollDirection == FSPagerViewScrollDirectionHorizontal ?
        MIN(CGRectGetMaxX(rect), self.contentSize.width - self.actualItemSize.width - self.leadingSpacing) :
        MIN(CGRectGetMaxY(rect), self.contentSize.height - self.actualItemSize.height - self.leadingSpacing);

    while ((origin - maxPosition) <= MAX(100.0 * DBL_EPSILON * fabs(origin + maxPosition), DBL_MIN)) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex % self.numberOfItems inSection:itemIndex / self.numberOfItems];
        FSPagerViewLayoutAttributes *attributes = (FSPagerViewLayoutAttributes *)[self layoutAttributesForItemAtIndexPath:indexPath];
        [self _applyTransformToAttribute:attributes withTransformer:self.pagerView.transformer];
        [layoutAttributes addObject:attributes];
        itemIndex += 1;
        origin += self.itemSpacing;
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    FSPagerViewLayoutAttributes *attribute = [FSPagerViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attribute.indexPath = indexPath;
    CGRect frame = [self frameForIndexPath:indexPath];
    CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    attribute.center = center;
    attribute.size = self.actualItemSize;
    return attribute;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    if (!self.collectionView || !self.pagerView) {
        return proposedContentOffset;
    }
    CGFloat (^ calculateTargetOffset)(CGFloat, CGFloat) = ^CGFloat (CGFloat proposedOffset, CGFloat boundedOffset) {
        CGFloat targetOffset;
        if (self.pagerView.decelerationDistance == [self.pagerView automaticSlidingInterval]) {
            if (fabs(velocity.x) >= 0.3) {
                CGFloat vector = velocity.x >= 0 ? 1.0 : -1.0;
                targetOffset = round(proposedOffset / self.itemSpacing + 0.35 * vector) * self.itemSpacing;
            } else {
                targetOffset = round(UIPopoverArrowDirectionRight / self.itemSpacing) * self.itemSpacing;
            }
        } else {
            CGFloat extraDistance = MAX(self.pagerView.decelerationDistance - 1, 0);
            if (velocity.x >= 0.3) {
                targetOffset = ceilf(self.collectionView.contentOffset.x / self.itemSpacing + extraDistance) * self.itemSpacing;
            } else if (velocity.x <= -0.3) {
                targetOffset = ceilf(self.collectionView.contentOffset.x / self.itemSpacing - extraDistance) * self.itemSpacing;
            } else {
                targetOffset = round(proposedOffset / self.itemSpacing) * self.itemSpacing;
            }
        }
        targetOffset = MAX(0, targetOffset);
        targetOffset = MIN(boundedOffset, targetOffset);
        return targetOffset;
    };

    CGFloat proposedContentOffsetX = (self.scrollDirection == FSPagerViewScrollDirectionVertical) ? proposedContentOffset.x : calculateTargetOffset(proposedContentOffset.x, self.collectionView.contentSize.width - self.itemSpacing);

    CGFloat proposedContentOffsetY = (self.scrollDirection == FSPagerViewScrollDirectionHorizontal) ? proposedContentOffset.y : calculateTargetOffset(proposedContentOffset.y, self.collectionView.contentSize.height - self.itemSpacing);

    proposedContentOffset = CGPointMake(proposedContentOffsetX, proposedContentOffsetY);
    return proposedContentOffset;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark Private Methpd
- (void)_commonInit {
    self.contentSize = CGSizeZero;
    self.leadingSpacing = 0;
    self.itemSpacing = 0;
    self.needsReprepare = YES;
    self.scrollDirection = FSPagerViewScrollDirectionHorizontal;
    self.collectionViewSize = CGSizeZero;
    self.numberOfSections = 1;
    self.numberOfItems = 0;
    self.actualInteritemSpacing = 0;
    self.actualItemSize = CGSizeZero;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)_adjustCollectionViewBounds {
    UICollectionView *collectionView = self.collectionView;
    FSPagerView *pagerView = self.pagerView;
    if (!collectionView || !pagerView) {
        return;
    }
    NSInteger currentIndex = pagerView.currentIndex;
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:currentIndex inSection:(pagerView.isInfinite ? self.numberOfSections / 2 : 0)];
    CGPoint contentOffset = [self contentOffsetForIndexPath:newIndexPath];

    CGRect newBounds = CGRectMake(contentOffset.x, contentOffset.y, collectionView.frame.size.width, collectionView.frame.size.height);
    collectionView.bounds = newBounds;
}

- (CGPoint)contentOffsetForIndexPath:(NSIndexPath *)indexPath {
    CGPoint origin = [self frameForIndexPath:indexPath].origin;
    UICollectionView *collectionView = self.collectionView;
    if (!collectionView) {
        return origin;
    }
    CGFloat contentOffsetX;
    CGFloat contentOffsetY;
    if (self.scrollDirection == FSPagerViewScrollDirectionHorizontal) {
        contentOffsetX = origin.x - (collectionView.frame.size.width * 0.5 - self.actualItemSize.width * 0.5);
        contentOffsetY = 0;
    } else {
        contentOffsetX = 0;
        contentOffsetY = origin.y - (collectionView.frame.size.height * 0.5 - self.actualItemSize.height * 0.5);
    }
    CGPoint contentOffset = CGPointMake(contentOffsetX, contentOffsetY);
    return contentOffset;
}

- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfItems = self.numberOfItems * indexPath.section + indexPath.item;
    CGFloat originX;
    CGFloat originY;
    if (self.scrollDirection == FSPagerViewScrollDirectionVertical) {
        originX = (self.collectionView.frame.size.width - self.actualItemSize.width) * 0.5;
        originY = self.leadingSpacing + numberOfItems * self.itemSpacing;
    } else {
        originX = self.leadingSpacing + numberOfItems * self.itemSpacing;
        originY = (self.collectionView.frame.size.height - self.actualItemSize.height) * 0.5;
    }
    CGRect frame = CGRectMake(originX, originY, self.actualItemSize.width, self.actualItemSize.height);
    return frame;
}

- (void)_applyTransformToAttribute:(FSPagerViewLayoutAttributes *)attributes withTransformer:(FSPagerViewTransformer *)transfomer {
    if (!self.collectionView || !transfomer) {
        return;
    }

    if (self.scrollDirection == FSPagerViewScrollDirectionHorizontal) {
        CGFloat ruler = CGRectGetMidX(self.collectionView.bounds);
        attributes.position = (attributes.center.x - ruler) / self.itemSpacing;
    } else {
        CGFloat ruler = CGRectGetMidY(self.collectionView.bounds);
        attributes.position = (attributes.center.y - ruler) / self.itemSpacing;
    }
    attributes.zIndex = (int)self.numberOfItems - (int)attributes.position;
    [transfomer applyTransformerToAttributes:attributes];
}

- (void)forceInvalidate {
    self.needsReprepare = YES;
    [self invalidateLayout];
}

#pragma mark Handle Notification
- (void)didReceiveNotification:(NSNotification *)notification {
    if (CGSizeEqualToSize(self.pagerView.itemSize, CGSizeZero)) {
        [self _adjustCollectionViewBounds];
    }
}

#pragma mark Set & Get
- (Class)layoutAttributesClass {
    return [FSPagerViewLayoutAttributes class];
}

- (FSPagerView *)pagerView {
    if ([self.collectionView.superview.superview isKindOfClass:[FSPagerView class]]) {
        return (FSPagerView *)self.collectionView.superview.superview;
    }
    return nil;
}

@end
