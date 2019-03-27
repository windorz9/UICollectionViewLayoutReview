//
//  SpinningWheelCollectionViewLayoutAttributes.h
//  Review-01-SpinningWheel
//
//  Created by windorz9 on 2019/3/27.
//  Copyright © 2019 windorz9. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpinningWheelCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) CGPoint anchorPoint;
@end

NS_ASSUME_NONNULL_END
