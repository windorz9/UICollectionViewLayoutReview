//
//  FSPagerViewTransformer.m
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/26.
//  Copyright © 2019 Q. All rights reserved.
//

#import "FSPagerViewTransformer.h"
#import "FSPagerView.h"
#import "FSPagerViewLayoutAttributes.h"

@interface FSPagerViewTransformer ()

/** Transformer 类型 */
@property (nonatomic, assign, readwrite) FSPagerViewTransformerType type;

@end

@implementation FSPagerViewTransformer

- (instancetype)initWithType:(FSPagerViewTransformerType)type {
    self = [super init];
    if (self) {
        self.type = type;
        self.minimumAlpha = 0.6;
        switch (type) {
            case FSPagerViewTransformerTypeZoomOut:
                self.minimumScale = 0.85;
                break;
            case FSPagerViewTransformerTypeDepth:
                self.minimumScale = 0.5;
                break;
            default:
                self.minimumScale = 0.65;
                break;
        }
    }
    return self;
}

- (void)applyTransformerToAttributes:(FSPagerViewLayoutAttributes *)attributes {
    FSPagerView *pagerView = self.pagerView;
    if (!pagerView) {
        return;
    }
    CGFloat position = attributes.position;
    FSPagerViewScrollDirection scrollDirection = pagerView.scrollDirection;
    CGFloat itemSpacing = scrollDirection == FSPagerViewScrollDirectionHorizontal ? attributes.bounds.size.width : (attributes.bounds.size.height + [self proposedInteritemSpacing]);
    switch (self.type) {
        case FSPagerViewTransformerTypeCrossFading: {
            NSInteger zIndex = 0;
            CGFloat alpha = 0;
            CGAffineTransform transform = CGAffineTransformIdentity;
            if (scrollDirection == FSPagerViewScrollDirectionHorizontal) {
                transform.tx = -itemSpacing * position;
            } else {
                transform.ty = -itemSpacing * position;
            }
            if (fabs(position) < 1) { // [-1 1]
                alpha = 1 - fabs(position);
                zIndex = 1;
            } else { // 位于屏幕外
                alpha = 0;
                zIndex = NSIntegerMin;
            }
            attributes.alpha = alpha;
            attributes.transform = transform;
            attributes.zIndex = zIndex;
        }
        break;
        case FSPagerViewTransformerTypeZoomOut: {
            CGFloat alpha = 0;
            CGAffineTransform transform = CGAffineTransformIdentity;
            if (-INFINITY <= position && position < -1) {  // [-INFINITY, -1)
                alpha = 0;
            } else if (-1 <= position && position <= 1) { // [-1, 1]
                CGFloat scaleFactor = MAX(self.minimumScale, 1 - fabs(position));
                transform.a = scaleFactor;
                transform.b = scaleFactor;
                if (scrollDirection == FSPagerViewScrollDirectionHorizontal) {
                    CGFloat verMargin = attributes.bounds.size.height * (1 - scaleFactor) / 2;
                    CGFloat horzMargin = itemSpacing * (1 - scaleFactor) / 2;
                    transform.tx = position < 0 ? (horzMargin - verMargin * 2) : (-horzMargin + verMargin * 2);
                } else {
                    CGFloat horzMargin = attributes.bounds.size.height * (1 - scaleFactor) / 2;
                    CGFloat verMargin = itemSpacing * (1 - scaleFactor) / 2;
                    transform.ty = position < 0 ? (verMargin - horzMargin * 2) : (-verMargin + horzMargin * 2);
                }
                alpha = self.minimumAlpha + (scaleFactor - self.minimumAlpha) / (1 - self.minimumScale) * (1 - self.minimumAlpha);
            } else if (1 < position && position <= INFINITY) { // (1, INFINITY]
                alpha = 0;
            }
            attributes.alpha = alpha;
            attributes.transform = transform;
        }
        break;
        case FSPagerViewTransformerTypeDepth: {
            CGAffineTransform transform = CGAffineTransformIdentity;
            NSInteger zIndex = 0;
            CGFloat alpha = 0;
            if (-INFINITY <= position && position < -1) {
                zIndex = 0;
                alpha = 0;
            } else if (-1 <= position && position <= 0) {
                alpha = 1;
                transform.tx = 0;
                transform.a = 1;
                transform.d = 1;
                zIndex = 1;
            } else if (0 < position && position < 1) {
                alpha = 1.0 - position;
                if (scrollDirection == FSPagerViewScrollDirectionHorizontal) {
                    transform.tx = itemSpacing * -position;
                } else {
                    transform.ty = itemSpacing * -position;
                }
                CGFloat scaleFactor = self.minimumScale + (1.0 - self.minimumScale) * (1.0 - fabs(position));
                transform.a = scaleFactor;
                transform.d = scaleFactor;
                zIndex = 0;
            } else if (1 <= position && position < INFINITY) {
                alpha = 0;
                zIndex = 0;
            }
            attributes.alpha = alpha;
            attributes.transform = transform;
            attributes.zIndex = zIndex;
        }
        break;
        case FSPagerViewTransformerTypeOverLap:
        case FSPagerViewTransformerTypeLinear: {
            if (scrollDirection == FSPagerViewScrollDirectionHorizontal) {
                return;
            }
            CGFloat scale = MAX(1 - (1 - self.minimumScale) * fabs(position), self.minimumScale);
            CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
            attributes.transform = transform;

            CGFloat alpha = (self.minimumAlpha + (1 - fabs(position)) * (1 - self.minimumAlpha));
            attributes.alpha = alpha;
            NSInteger zIndex = (1 - fabs(position)) * 10;
            attributes.zIndex = zIndex;
        }
        break;
        case FSPagerViewTransformerTypeCoverFlow: {
            if (scrollDirection != FSPagerViewScrollDirectionHorizontal) {
                return;
            }
            CGFloat position_sub = MIN(MAX(-position, -1), 1);
            CGFloat rotation = sin(position * M_PI_2) * M_PI_4 * 1.5;
            CGFloat translationZ = -itemSpacing * 0.5 * fabs(position_sub);
            CATransform3D transform3D = CATransform3DIdentity;
            transform3D.m34 = -0.002;
            transform3D = CATransform3DRotate(transform3D, rotation, 0, 1, 0);
            transform3D = CATransform3DTranslate(transform3D, 0, 0, translationZ);
            attributes.zIndex = 100 - (int)fabs(position_sub);
            attributes.transform3D = transform3D;
        }
        break;
        case FSPagerViewTransformerTypeInvertedFerrisWheel:
        case FSPagerViewTransformerTypeFerrisWheel:
            if (scrollDirection != FSPagerViewScrollDirectionHorizontal) {
                return;
            }
            NSInteger zIndex = 0;
            CGAffineTransform transform = CGAffineTransformIdentity;
            if (-5 <= position && position >= 5) {
                CGFloat itemSpacing = attributes.bounds.size.width + [self proposedInteritemSpacing];
                CGFloat count = 14;
                CGFloat circle = M_PI * 2;
                CGFloat radius = itemSpacing * count / circle;
                CGFloat ty = radius * (self.type == FSPagerViewTransformerTypeFerrisWheel ? 1 : -1);
                CGFloat theta = circle / count;
                CGFloat rotation = position * theta * (self.type == FSPagerViewTransformerTypeFerrisWheel ? 1 : -1);
                transform = CGAffineTransformTranslate(transform, -position * itemSpacing, ty);
                transform = CGAffineTransformRotate(transform, rotation);
                transform = CGAffineTransformTranslate(transform, 0, -ty);
                zIndex = (int)(4.0 - (int)fabs(position) * 10);
            }
            attributes.alpha = fabs(position) < 0.5 ? 1 : self.minimumAlpha;
            attributes.transform = transform;
            attributes.zIndex = zIndex;

            break;
        case FSPagerViewTransformerTypeCubic: {
            if (-INFINITY <= position && position < -1) {
                attributes.alpha = 0;
            } else if (-1 < position && position < 1) {
                attributes.alpha = 1;
                attributes.zIndex = (int)((1 - position) * 10.0);

                CGFloat direction = (position < 0) ? 1 : -1;
                CGFloat theta = position * M_PI_2 * (scrollDirection == FSPagerViewScrollDirectionHorizontal ? 1 : -1);
                CGFloat radius = (scrollDirection == FSPagerViewScrollDirectionHorizontal) ? attributes.bounds.size.width : attributes.bounds.size.height;

                CATransform3D transform3D = CATransform3DIdentity;
                transform3D.m34 = -0.002;
                if (scrollDirection == FSPagerViewScrollDirectionHorizontal) {
                    // ForwardX -> RotateY -> BackwardX
                    attributes.center = CGPointMake(direction * radius * 0.5 + attributes.center.x, attributes.center.y); // ForwardX
                    transform3D = CATransform3DRotate(transform3D, theta, 0, 1, 0);
                    transform3D = CATransform3DTranslate(transform3D, -direction * radius * 0.5, 0, 0); // BackwardX
                } else {
                    attributes.center = CGPointMake(attributes.center.x, direction * radius * 0.5 + attributes.center.y);
                    transform3D = CATransform3DRotate(transform3D, theta, 1, 0, 0);
                    transform3D = CATransform3DTranslate(transform3D, 0, -direction * radius * 0.5, 0); // BackwardY
                }
                attributes.transform3D = transform3D;
            } else if (1 <= position && position < INFINITY) {
                attributes.alpha = 0;
            }
        }
        break;
        default:
            attributes.alpha = 0;
            attributes.zIndex = 0;
            break;
    }
}

- (CGFloat)proposedInteritemSpacing {
    FSPagerView *pagerView = self.pagerView;
    if (!pagerView) {
        return 0;
    }
    FSPagerViewScrollDirection scrollDirection = pagerView.scrollDirection;
    switch (self.type) {
        case FSPagerViewTransformerTypeOverLap: {
            if (scrollDirection != FSPagerViewScrollDirectionHorizontal) {
                return 0;
            }
            return pagerView.itemSize.width * (-self.minimumScale) * 0.6;
        }
        break;
        case FSPagerViewTransformerTypeLinear: {
            if (scrollDirection != FSPagerViewScrollDirectionHorizontal) {
                return 0;
            }
            return pagerView.itemSize.width * (-self.minimumScale) * 0.2;
        }
        break;
        case FSPagerViewTransformerTypeCoverFlow: {
            if (scrollDirection != FSPagerViewScrollDirectionHorizontal) {
                return 0;
            }
            return -pagerView.itemSize.width * sin(M_PI * 0.25 * 0.25 * 3.0);
        }
        break;
        case FSPagerViewTransformerTypeFerrisWheel:
        case FSPagerViewTransformerTypeInvertedFerrisWheel: {
            if (scrollDirection != FSPagerViewScrollDirectionHorizontal) {
                return 0;
            }
            return -pagerView.itemSize.width * 0.15;
        }
        break;
        case FSPagerViewTransformerTypeCubic: {
            return 0;
        }
        break;
        default:
            break;
    }

    return pagerView.interitemSpacing;
}

@end
