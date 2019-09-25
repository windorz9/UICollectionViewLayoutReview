//
//  FSPagerCollectionView.m
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/25.
//  Copyright © 2019 Q. All rights reserved.
//

#import "FSPagerCollectionView.h"

@implementation FSPagerCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:frame collectionViewLayout:layout];
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

- (BOOL)scrollsToTop {
    return NO;
}

- (void)setScrollsToTop:(BOOL)scrollsToTop {
    [super setScrollsToTop:NO];
}

- (UIEdgeInsets)contentInset {
    return [super contentInset];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    [super setContentInset:UIEdgeInsetsZero];
    if (contentInset.top > 0) {
        self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + contentInset.top);
    }
}

#pragma mark Private Method
- (void)_commonInit {
    self.contentInset = UIEdgeInsetsZero;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 10.0, *)) {
        self.prefetchingEnabled = NO;
    }
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.scrollsToTop = NO;
    self.pagingEnabled = NO;
}

@end
