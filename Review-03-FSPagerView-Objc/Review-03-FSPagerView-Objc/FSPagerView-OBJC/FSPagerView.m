//
//  FSPagerView.m
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/26.
//  Copyright © 2019 Q. All rights reserved.
//

#import "FSPagerView.h"
#import "FSPagerCollectionView.h"
#import "FSPagerViewCell.h"
#import "FSPagerViewLayoutAttributes.h"
#import "FSPagerViewTransformer.h"
#import "FSPagerViewLayout.h"

@interface FSPagerView ()
/** Layout */
@property (nonatomic, strong) FSPagerViewLayout *collectionViewLayout;
/** CollectionView */
@property (nonatomic, strong) FSPagerCollectionView *collectionView;
/** ContentView */
@property (nonatomic, strong) UIView *contentView;
/** Timer */
@property (nonatomic, strong) NSTimer *timer;
/** numberofItems */
@property (nonatomic, assign) NSInteger numberOfItems;
/** numberOfSections */
@property (nonatomic, assign) NSInteger numberOfSections;
/** dequeingSection */
@property (nonatomic, assign) NSInteger dequeingSection;
/** centermostIndexPath */
@property (nonatomic, strong) NSIndexPath *centermostIndexPath;
/** isPossiblyRotating */
@property (nonatomic, assign) BOOL isPossiblyRotating;
/** possibleTargetingIndexPath */
@property (nonatomic, strong) NSIndexPath *possibleTargetingIndexPath;

@property (nonatomic, assign, readwrite) NSInteger currentIndex;

@end

@implementation FSPagerView
@synthesize isScrollEnabled = _isScrollEnabled;
@synthesize bounces = _bounces;
@synthesize alwaysBounceHorizontal = _alwaysBounceHorizontal;
@synthesize alwaysBounceVertical = _alwaysBounceVertical;

#pragma mark Overriden
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = self.bounds;
    self.contentView.frame = self.bounds;
    self.collectionView.frame = self.contentView.bounds;
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self _startTimer];
    } else {
        [self _cancelTimer];
    }
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.frame = self.bounds;
    UILabel *label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:25];
    label.text = @"FSPagerView";
    [self.contentView addSubview:label];
}

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    id<FSPagerViewDataSource> dataSource = self.dataSource;
    if (!dataSource) {
        return 1;
    }
    self.numberOfItems = [dataSource numberOfItemsInPegerView:self];
    if (self.numberOfItems <= 0) {
        return 0;
    }
    self.numberOfSections = self.isInfinite && (self.numberOfItems > 1 || !self.removesInfiniteLoopForSingleItem) ? (int)(INT16_MAX) / self.numberOfItems : 1;
    return self.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.numberOfItems;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.item;
    self.dequeingSection = indexPath.section;
    FSPagerViewCell *cell = [self.dataSource pagerView:self cellForItemAtIndex:index];
    return cell;
}

#pragma mark UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:shouldHighlightItemAtIndex:)]) {
        return [self.delegate pagerView:self shouldHighlightItemAtIndex:indexPath.item % self.numberOfItems];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:didHighLightItemAtIndex:)]) {
        [self.delegate pagerView:self didHighLightItemAtIndex:indexPath.item % self.numberOfItems];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:shouldSelectItemAtIndex:)]) {
        return [self.delegate pagerView:self shouldSelectItemAtIndex:indexPath.item % self.numberOfItems];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:didSelectItemAtIndex:)]) {
        self.possibleTargetingIndexPath = indexPath;

        [self.delegate pagerView:self didSelectItemAtIndex:indexPath.item % self.numberOfItems];
        self.possibleTargetingIndexPath = nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:willDisplayCell:forItemAtIndex:)]) {
        [self.delegate pagerView:self willDisplayCell:(FSPagerViewCell *)cell forItemAtIndex:indexPath.item % self.numberOfItems];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(pagerView:didEndDisplayingCell:forItemAtIndex:)]) {
        [self.delegate pagerView:self didEndDisplayingCell:(FSPagerViewCell *)cell forItemAtIndex:indexPath.item % self.numberOfItems];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isPossiblyRotating && self.numberOfItems > 0) {
        NSInteger currentIndex = lround(self.scrollOffset) % self.numberOfItems;
        if (currentIndex != self.currentIndex) {
            self.currentIndex = currentIndex;
        }
    }
    if ([self.delegate respondsToSelector:@selector(pagerViewDidScroll:)]) {
        [self.delegate pagerViewDidScroll:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewWillBeginDragging:)]) {
        [self.delegate pagerViewWillBeginDragging:self];
    }
    if (self.automaticSlidingInterval > 0) {
        [self _cancelTimer];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ([self.delegate respondsToSelector:@selector(pagerViewWillEndDragging:targetIndex:)]) {
        CGFloat contentOffset = (self.scrollDirection == FSPagerViewScrollDirectionHorizontal) ? (targetContentOffset->x) : (targetContentOffset->y);
        NSInteger targetItem = lround(contentOffset / self.collectionViewLayout.itemSpacing);
        [self.delegate pagerViewWillEndDragging:self targetIndex:targetItem];
    }
    if (self.automaticSlidingInterval > 0) {
        [self _startTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewDidEndDeceleration:)]) {
        [self.delegate pagerViewDidEndDeceleration:self];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(pagerViewDidEndScrollAnimation:)]) {
        [self.delegate pagerViewDidEndScrollAnimation:self];
    }
}

#pragma mark Private Method
- (void)_commonInit {
    
    self.decelerationDistance = 1;
    self.currentIndex = 0;
    // ContentView
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:contentView];
    self.contentView = contentView;

    // UICollectionView
    FSPagerViewLayout *collectionViewLayout = [[FSPagerViewLayout alloc] init];
    FSPagerCollectionView *collectionView = [[FSPagerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:collectionView];
    self.collectionView = collectionView;
    self.collectionViewLayout = collectionViewLayout;
}

- (void)_startTimer {
    if (self.automaticSlidingInterval <= 0 || self.timer) {
        return;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.automaticSlidingInterval target:self selector:@selector(_flipNextSender:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)_flipNextSender:(NSTimer *)timer {

    if (!self.superview || !self.window || self.numberOfItems <= 0 || self.isTracking) {
        return;
    }
    NSIndexPath *indexPath = self.centermostIndexPath;
    NSInteger section = (self.numberOfSections > 1) ? (indexPath.section + (indexPath.item + 1) / self.numberOfItems) : 0;
    NSInteger item = (indexPath.item + 1) % self.numberOfItems;
    CGPoint contentOffset = [self.collectionViewLayout contentOffsetForIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
    [self.collectionView setContentOffset:contentOffset animated:YES];
}

- (void)_cancelTimer {
    if (!self.timer) {
        return;
    }
    [self.timer invalidate];
    self.timer = nil;
}

- (NSIndexPath *)_nearbyIndexPathForIndex:(NSInteger)index {

    NSInteger currentIndex = self.currentIndex;
    NSInteger currentSection = self.centermostIndexPath.section;
    if (labs(currentIndex-index) <= self.numberOfItems/2) {
        return [NSIndexPath indexPathForItem:index inSection:currentSection];
    } else if (index-currentIndex >= 0) {
        return [NSIndexPath indexPathForItem:index inSection:currentSection-1];
    } else {
        return [NSIndexPath indexPathForItem:index inSection:currentSection+1];
    }
}


#pragma mark Public Method
- (void)registerClass:(Class)class forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerClass:class forCellWithReuseIdentifier:identifier];
    
}

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier {
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    
}

- (__kindof FSPagerViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier atIndex:(NSInteger)index {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:self.dequeingSection];
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (![cell isKindOfClass:[FSPagerViewCell class]]) {
        @throw [NSException exceptionWithName:@"" reason:@"Cell class must be subclass of LKPagerViewCell" userInfo:nil];
    }
    return (FSPagerViewCell *)cell;
}

- (void)reloadData {
    
    self.collectionViewLayout.needsReprepare = YES;
    [self.collectionView reloadData];
    
}

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSIndexPath *indexPath = [self _nearbyIndexPathForIndex:index];
    UICollectionViewScrollPosition scrollPosition = (self.scrollDirection == FSPagerViewScrollDirectionHorizontal) ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
    [self.collectionView selectItemAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
    
}

- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    
    NSIndexPath *indexPath = [self _nearbyIndexPathForIndex:index];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:animated];
    
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {

    if (index > self.numberOfItems) {
        @throw [NSException exceptionWithName:@"" reason:[NSString stringWithFormat:@"index %@ is out of range [0...\(self.numberOfItems-1)]", @(index)] userInfo:nil];
    }
    NSIndexPath *indexPath = [self.possibleTargetingIndexPath copy];
    if (indexPath && indexPath.item == index) {
        self.possibleTargetingIndexPath = nil;
    } else if (self.numberOfItems > 1) {
        indexPath = [self _nearbyIndexPathForIndex:index];
    } else {
        indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    }
    CGPoint contentOffset = [self.collectionViewLayout contentOffsetForIndexPath:indexPath];
    [self.collectionView setContentOffset:contentOffset animated:animated];
    
}

- (NSInteger)indexForCell:(FSPagerViewCell *)cell {

    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    if (!indexPath) {
        return NSNotFound;
    }
    return indexPath.item;
    
}

- (__kindof FSPagerViewCell *)cellForItemAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self _nearbyIndexPathForIndex:index];
    
    return (FSPagerViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
}

#pragma mark Set & Get
- (void)setScrollDirection:(FSPagerViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    [self.collectionViewLayout forceInvalidate];
}

- (void)setAutomaticSlidingInterval:(CGFloat)automaticSlidingInterval {
    _automaticSlidingInterval = automaticSlidingInterval;
    [self _cancelTimer];
    if (_automaticSlidingInterval > 0) {
        [self _startTimer];
    }
    
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    
    _interitemSpacing = interitemSpacing;
    [self.collectionViewLayout forceInvalidate];
}

- (void)setItemSize:(CGSize)itemSize {
    
    _itemSize = itemSize;
    [self.collectionViewLayout forceInvalidate];
    
}

- (void)setIsInfinite:(BOOL)isInfinite {
    _isInfinite = isInfinite;
    self.collectionViewLayout.needsReprepare = YES;
    [self.collectionView reloadData];
    
}

- (void)setIsScrollEnabled:(BOOL)isScrollEnabled {
    _isScrollEnabled = isScrollEnabled;
    [self.collectionView setScrollEnabled:isScrollEnabled];
}

- (BOOL)isScrollEnabled {
    return self.collectionView.isScrollEnabled;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    self.collectionView.bounces = bounces;
}

- (BOOL)bounces {
    return self.collectionView.bounces;
}

- (void)setAlwaysBounceVertical:(BOOL)alwaysBounceVertical {
    _alwaysBounceVertical = alwaysBounceVertical;
    self.collectionView.alwaysBounceVertical = alwaysBounceVertical;
}

- (BOOL)alwaysBounceVertical {
    return self.collectionView.alwaysBounceVertical;
}

- (void)setAlwaysBounceHorizontal:(BOOL)alwaysBounceHorizontal {
    _alwaysBounceHorizontal = alwaysBounceHorizontal;
    self.collectionView.alwaysBounceHorizontal = alwaysBounceHorizontal;
}
- (BOOL)alwaysBounceHorizontal {
    return self.collectionView.alwaysBounceHorizontal;
}

- (void)setRemovesInfiniteLoopForSingleItem:(BOOL)removesInfiniteLoopForSingleItem {
    _removesInfiniteLoopForSingleItem = removesInfiniteLoopForSingleItem;
    [self.collectionView reloadData];
}

- (void)setBackgroundView:(UIView *)backgroundView {
    _backgroundView = backgroundView;
    if (backgroundView) {
        if (backgroundView.superview) {
            [backgroundView removeFromSuperview];
        }
        [self insertSubview:backgroundView atIndex:0];
        [self setNeedsLayout];
    }

}

- (void)setTransformer:(FSPagerViewTransformer *)transformer {
    _transformer = transformer;
    _transformer.pagerView = self;
    [self.collectionViewLayout forceInvalidate];
}

- (BOOL)isTracking {
    return self.collectionView.isTracking;
}

- (CGFloat)scrollOffset {
    CGFloat contentOffset = MAX(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
    CGFloat scrollOffset = (contentOffset / self.collectionViewLayout.itemSpacing);
    return fmod(scrollOffset, self.numberOfItems);
    
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return self.collectionView.panGestureRecognizer;
}

- (NSIndexPath *)centermostIndexPath {

//    guard self.numberOfItems > 0, self.collectionView.contentSize != .zero else {
//        return IndexPath(item: 0, section: 0)
//    }
//    let sortedIndexPaths = self.collectionView.indexPathsForVisibleItems.sorted { (l, r) -> Bool in
//        let leftFrame = self.collectionViewLayout.frame(for: l)
//        let rightFrame = self.collectionViewLayout.frame(for: r)
//        var leftCenter: CGFloat,rightCenter: CGFloat,ruler: CGFloat
//        switch self.scrollDirection {
//        case .horizontal:
//            leftCenter = leftFrame.midX
//            rightCenter = rightFrame.midX
//            ruler = self.collectionView.bounds.midX
//        case .vertical:
//            leftCenter = leftFrame.midY
//            rightCenter = rightFrame.midY
//            ruler = self.collectionView.bounds.midY
//        }
//        return abs(ruler-leftCenter) < abs(ruler-rightCenter)
//    }
//    let indexPath = sortedIndexPaths.first
//    if let indexPath = indexPath {
//        return indexPath
//    }
//    return IndexPath(item: 0, section: 0)

    if (self.numberOfItems == 0 || CGSizeEqualToSize(self.collectionView.contentSize, CGSizeZero)) {
        
        return [NSIndexPath indexPathForItem:0 inSection:0];
    }
    NSArray *sortedIndexPaths = [self.collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull l, id  _Nonnull r) {
        CGRect leftFrame = [self.collectionViewLayout frameForIndexPath:l];
        CGRect rightFrame = [self.collectionViewLayout frameForIndexPath:r];
        CGFloat leftCenter;
        CGFloat rightCenter;
        CGFloat ruler;
        if (self.scrollDirection == FSPagerViewScrollDirectionHorizontal) {
            leftCenter = CGRectGetMidX(leftFrame);
            rightCenter = CGRectGetMidX(rightFrame);
            ruler = CGRectGetMidX(self.collectionView.bounds);
        } else {
            leftCenter = CGRectGetMidY(leftFrame);
            rightCenter = CGRectGetMidY(rightFrame);
            ruler = CGRectGetMidY(self.collectionView.bounds);
            
        }
        if (fabs(ruler - leftCenter) < fabs(ruler - rightCenter)) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    if (sortedIndexPaths.firstObject) {
        return sortedIndexPaths.firstObject;
    }
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

- (BOOL)isPossiblyRotating {
    
    NSArray *animationKeys = self.contentView.layer.animationKeys;
    if (!animationKeys) {
        return NO;
    }
    NSArray *rotationAnimationKeys = @[@"position", @"bounds.origin", @"bounds.size"];

    for (NSString *animationKey in rotationAnimationKeys) {
        if ([animationKeys containsObject:animationKey]) {
            return YES;
        }
    }
    return NO;

}

@end
