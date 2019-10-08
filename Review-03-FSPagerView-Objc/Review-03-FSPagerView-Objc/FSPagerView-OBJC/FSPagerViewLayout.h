//
//  FSPagerViewLayout.h
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/26.
//  Copyright © 2019 Q. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPagerView.h"

@interface FSPagerViewLayout : UICollectionViewLayout
/** contentSize */
@property (nonatomic, assign) CGSize contentSize;
/** leadingSpaceing */
@property (nonatomic, assign) CGFloat leadingSpacing;
/** itemSpacing */
@property (nonatomic, assign) CGFloat itemSpacing;
/** needsReprepare */
@property (nonatomic, assign) BOOL needsReprepare;
/** scrollDirection */
@property (nonatomic, assign) FSPagerViewScrollDirection scrollDirection;

- (void)forceInvalidate;
- (CGPoint)contentOffsetForIndexPath:(NSIndexPath *)indexPath;
- (CGRect)frameForIndexPath:(NSIndexPath *)indexPath;

@end

