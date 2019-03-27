//
//  SpinningWheelCollectionViewLayoutAttributes.m
//  Review-01-SpinningWheel
//
//  Created by windorz9 on 2019/3/27.
//  Copyright © 2019 windorz9. All rights reserved.
//

#import "SpinningWheelCollectionViewLayoutAttributes.h"


@implementation SpinningWheelCollectionViewLayoutAttributes

- (instancetype)init {
    self = [super init];
    if (self) {
        self.angle = 0;
        self.anchorPoint = CGPointMake(0.5, 0.5);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SpinningWheelCollectionViewLayoutAttributes *attribute = [super copyWithZone:zone];
    attribute.anchorPoint = self.anchorPoint;
    attribute.angle = self.angle;
    return attribute;
}

- (void)setAngle:(CGFloat)angle {
    
    _angle = angle;
    self.transform = CGAffineTransformMakeRotation(angle);
    self.zIndex = (int)(_angle * 1000000);
}

@end
