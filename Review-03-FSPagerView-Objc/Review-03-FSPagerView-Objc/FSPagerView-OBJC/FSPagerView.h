//
//  FSPagerView.h
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/26.
//  Copyright © 2019 Q. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSPagerView;
@class FSPagerViewCell;
@class FSPagerViewTransformer;

@protocol FSPagerViewDataSource <NSObject>

- (int)numberOfItemsInPegerView:(FSPagerView *)pagerView;

- (FSPagerViewCell *)pagerView:(FSPagerView *)pagerView cellForItemAtIndex:(NSInteger)index;

@end

@protocol FSPagerViewDelegate <NSObject>
@optional
// 指定的 index 单元格是否需要高亮
- (BOOL)pagerView:(FSPagerView *)pagerView shouldHighlightItemAtIndex:(NSInteger)index;
// 高亮 item
- (void)pagerView:(FSPagerView *)pagerView didHighLightItemAtIndex:(NSInteger)index;
// 指定的 index 单元格是否选中
- (BOOL)pagerView:(FSPagerView *)pagerView shouldSelectItemAtIndex:(NSInteger)index;
// 选中 item
- (void)pagerView:(FSPagerView *)pagerView didSelectItemAtIndex:(NSInteger)index;
// 将要展示某个单元格
- (void)pagerView:(FSPagerView *)pagerView willDisplayCell:(FSPagerViewCell *)cell forItemAtIndex:(NSInteger)index;
// 结束展示某个单元格
- (void)pagerView:(FSPagerView *)pagerView didEndDisplayingCell:(FSPagerViewCell *)cell forItemAtIndex:(NSInteger)index;
// 即将拖拽
- (void)pagerViewWillBeginDragging:(FSPagerView *)pagerView;
// 将要停止拖拽
- (void)pagerViewWillEndDragging:(FSPagerView *)pagerView targetIndex:(NSInteger)targetIndex;
// 滑动
- (void)pagerViewDidScroll:(FSPagerView *)pagerView;
// 结束滑动动画
- (void)pagerViewDidEndScrollAnimation:(FSPagerView *)pagerView;
// 开始减速
- (void)pagerViewDidEndDeceleration:(FSPagerView *)pagerView;




@end

typedef NS_ENUM(NSUInteger, FSPagerViewScrollDirection) {
    FSPagerViewScrollDirectionHorizontal,
    FSPagerViewScrollDirectionVertical
};

IB_DESIGNABLE
@interface FSPagerView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet id<FSPagerViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<FSPagerViewDelegate> delegate;

/** ScrollDirection */
@property (nonatomic, assign) FSPagerViewScrollDirection scrollDirection;

/** 开启自动滑动的时间间隔 */
@property (nonatomic, assign) IBInspectable CGFloat automaticSlidingInterval;
/** interitemSpacing */
@property (nonatomic, assign) IBInspectable CGFloat interitemSpacing;

/** ItemSize */
@property (nonatomic, assign) IBInspectable CGSize itemSize;
/** infinite */
@property (nonatomic, assign) IBInspectable BOOL isInfinite;
/** decelerationDistance */
@property (nonatomic, assign) IBInspectable NSInteger decelerationDistance;
/** ScrollEnable */
@property (nonatomic, assign) IBInspectable BOOL isScrollEnabled;
/** Bounces */
@property (nonatomic, assign) IBInspectable BOOL bounces;
/** Horizontal bounces */
@property (nonatomic, assign) IBInspectable BOOL alwaysBounceHorizontal;
/** Vertical bounces */
@property (nonatomic, assign) IBInspectable BOOL alwaysBounceVertical;
/** 单个移除循环 */
@property (nonatomic, assign) IBInspectable BOOL removesInfiniteLoopForSingleItem;
/** backgroundView */
@property (nonatomic, strong) IBInspectable UIView *backgroundView;
/** CustomTransform */
@property (nonatomic, strong) FSPagerViewTransformer *transformer;
/** isTracking */
@property (nonatomic, assign, readonly) BOOL isTracking;
/** scrollOffset */
@property (nonatomic, assign, readonly) CGFloat scrollOffset;
/** UIPangestureRecognizer */
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *panGestureRecognizer;
/** currentIndex */
@property (nonatomic, assign, readonly) NSInteger currentIndex;

- (void)registerClass:(Class)class forCellWithReuseIdentifier:(NSString *)identifier;

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

- (__kindof FSPagerViewCell *)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier atIndex:(NSInteger)index;

- (void)reloadData;

- (void)selectItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)deselectItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (NSInteger)indexForCell:(FSPagerViewCell *)cell;

- (__kindof FSPagerViewCell *)cellForItemAtIndex:(NSInteger)index;

@end

