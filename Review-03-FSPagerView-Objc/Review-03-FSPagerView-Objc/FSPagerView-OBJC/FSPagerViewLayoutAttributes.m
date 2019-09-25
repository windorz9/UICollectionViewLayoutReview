//
//  FSPagerViewLayoutAttributes.m
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/26.
//  Copyright © 2019 Q. All rights reserved.
//

#import "FSPagerViewLayoutAttributes.h"

@implementation FSPagerViewLayoutAttributes

- (BOOL)isEqual:(FSPagerViewLayoutAttributes *)object {
    if (![[object class] isKindOfClass:[FSPagerViewLayoutAttributes class]]) {
        return NO;
    }
    BOOL isEqual = [super isEqual:object];
    isEqual = isEqual && (self.position == object.position);
    return isEqual;
}

- (id)copyWithZone:(NSZone *)zone {
    FSPagerViewLayoutAttributes *copy = [super copyWithZone:zone];
    copy.position = self.position;
    return copy;
}

@end
