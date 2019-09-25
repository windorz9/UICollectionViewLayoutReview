//
//  FSPagerControl.m
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/24.
//  Copyright © 2019 Q. All rights reserved.
//

#import "FSPagerControl.h"

@interface FSPagerControl ()
/** UIControlState : UIColor */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *strokeColors;
/** UIControlState : UIColor */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *fillColors;
/** UIControlState : UIBezierPath */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIBezierPath *> *paths;
/** UIControlState : UIImage */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *images;
/** UIControlState : alpha */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *alphas;
/** UIControlState : CGAffineTransform */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSValue *> *transforms;
/** ContentView */
@property (nonatomic, strong) UIView *contentView;
/** Need update Indicators */
@property (nonatomic, assign) BOOL needsUpdateIndicators;
/** Need Create Indicators */
@property (nonatomic, assign) BOOL needsCreateIndicators;
/** CAShaperLayers */
@property (nonatomic, strong) NSMutableArray<CAShapeLayer *> *indicatorLayers;

@end

@implementation FSPagerControl

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
    // 确定 contentView 的大小
    // 根据 self.frame - contentInsets 计算得来
    self.contentView.frame = CGRectMake(self.contentInsets.left, self.contentInsets.top, self.frame.size.width - self.contentInsets.left - self.contentInsets.right, self.frame.size.height - self.contentInsets.top - self.contentInsets.bottom);
    
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];

    CGFloat diameter = self.itemSpacing;
    CGFloat spacing = self.interitemSpacing;
    __block CGFloat x = 0;

    /**
     UIControlContentHorizontalAlignmentCenter = 0,
     UIControlContentHorizontalAlignmentLeft   = 1,
     UIControlContentHorizontalAlignmentRight  = 2,
     UIControlContentHorizontalAlignmentFill   = 3,
     UIControlContentHorizontalAlignmentLeading  API_AVAILABLE(ios(11.0), tvos(11.0)) = 4,
     UIControlContentHorizontalAlignmentTrailing API_AVAILABLE(ios(11.0), tvos(11.0)) = 5,
     */
    switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentLeft:
        case UIControlContentHorizontalAlignmentLeading:
            x = 0;
            break;
        case UIControlContentHorizontalAlignmentRight:
        case UIControlContentHorizontalAlignmentTrailing: {
            CGFloat contentWidth = diameter * self.numberOfPages + (self.numberOfPages-1)*spacing;
            x = self.contentView.frame.size.width - contentWidth;
            break;
        }
        case UIControlContentHorizontalAlignmentCenter:
        case UIControlContentHorizontalAlignmentFill: {
            CGFloat contentMidX = CGRectGetMidX(self.contentView.bounds);
            CGFloat amplitude = self.numberOfPages/2 * diameter + spacing*((self.numberOfPages-1)/2);
            x = contentMidX - amplitude;
            break;
        }
        default:
            x = 0;
            break;
    }

    // 遍历所有的 layer 计算出所有 subLayer 的 frame
    [self.indicatorLayers enumerateObjectsUsingBlock:^(CAShapeLayer *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        UIControlState state = (self.currentPage == idx) ? UIControlStateSelected : UIControlStateNormal;
        UIImage *image = self.images[@(state)];
        CGSize imageSize = image ? image.size : CGSizeMake(diameter, diameter);
        CGPoint origin = CGPointMake(x - (imageSize.width - diameter * 0.5), CGRectGetMidY(self.contentView.frame) - -imageSize.height * 0.5);
        obj.frame = CGRectMake(origin.x, origin.y, imageSize.width, imageSize.height);
        x = x + diameter + spacing;
    }];
}

#pragma mark Publick Method
- (void)setStrokeColor:(UIColor *)strokeColor forState:(UIControlState)state {
    if (self.strokeColors[@(state)] == strokeColor) {
        return;
    }
    self.strokeColors[@(state)] = strokeColor;
    [self _setNeedsUpdateIndicators];
}

- (void)setFillColor:(UIColor *)fillColor forState:(UIControlState)state {
    if (self.fillColors[@(state)] == fillColor) {
        return;
    }
    self.fillColors[@(state)] = fillColor;
    [self _setNeedsUpdateIndicators];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.images[@(state)] == image) {
        return;
    }
    self.images[@(state)] = image;
    [self _setNeedsUpdateIndicators];
}

- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state {
    if (self.alphas[@(state)].floatValue == alpha) {
        return;
    }
    self.alphas[@(state)] = @(alpha);
    [self _setNeedsUpdateIndicators];
}

- (void)setPath:(UIBezierPath *)path forState:(UIControlState)state {
    if (self.paths[@(state)] == path) {
        return;
    }
    self.paths[@(state)] = path;
    [self _setNeedsUpdateIndicators];
}

#pragma mark Private Method
/**
 Common Init
 */
- (void)_commonInit {
    self.strokeColors = [NSMutableDictionary dictionary];
    self.fillColors = [NSMutableDictionary dictionary];
    self.paths = [NSMutableDictionary dictionary];
    self.images = [NSMutableDictionary dictionary];
    self.alphas = [NSMutableDictionary dictionary];
    self.transforms = [NSMutableDictionary dictionary];
    self.indicatorLayers = [NSMutableArray array];

    self.itemSpacing = 6;
    self.interitemSpacing = 6;
    self.contentInsets = UIEdgeInsetsZero;
    self.numberOfPages = 0;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    [self addSubview:view];
    self.contentView = view;
    self.userInteractionEnabled = NO;
}

// 更新指示器
- (void)_setNeedsUpdateIndicators {
    self.needsUpdateIndicators = YES;
    [self setNeedsLayout];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _updateIndicatorsIfNecessary];
    });
}

- (void)_updateIndicatorsIfNecessary {
    if (!self.needsUpdateIndicators || self.indicatorLayers.count <= 0) {
        return;
    }
    self.needsUpdateIndicators = NO;
    self.contentView.hidden = self.hidesForSinglePage && self.numberOfPages <= 1;
    if (!self.contentView.isHidden) {
        for (CAShapeLayer *layer in self.indicatorLayers) {
            layer.hidden = NO;
            [self _updateIndicatorAttributesForLayer:layer];
        }
    }
}

- (void)_updateIndicatorAttributesForLayer:(CAShapeLayer *)layer {
    NSInteger index = [self.indicatorLayers indexOfObject:layer];
    UIControlState state = (self.currentPage == index) ? UIControlStateSelected : UIControlStateNormal;
    UIImage *image = self.images[@(state)];
    if (image) {
        // 设置指示器为 图片
        layer.strokeColor = nil;
        layer.fillColor = nil;
        layer.path = nil;
        layer.contents = (__bridge id _Nullable)(image.CGImage);
    } else {
        layer.contents = nil;
        UIColor *strokeColor = self.strokeColors[@(state)];
        UIColor *fillColor = self.fillColors[@(state)];
        if (strokeColor == nil && fillColor == nil) {
            // 设置默认颜色
            layer.strokeColor = nil;
            layer.fillColor = (state == UIControlStateSelected) ? [[UIColor whiteColor] CGColor] : [[UIColor grayColor] CGColor];
        } else {
            layer.strokeColor = strokeColor.CGColor;
            layer.fillColor = fillColor.CGColor;
        }

        layer.path = self.paths[@(state)].CGPath ? self.paths[@(state)].CGPath : [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, self.itemSpacing, self.itemSpacing)].CGPath;

        NSValue *transform = self.transforms[@(state)];
        if (transform) {
            layer.transform = CATransform3DMakeAffineTransform([transform CGAffineTransformValue]);
        }
        layer.opacity = self.alphas[@(state)] ? self.alphas[@(state)].floatValue : 1.0;
    }
}

// 创建指示器
- (void)_setNeedsCreateIndicators {
    self.needsCreateIndicators = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _createIndicatorsIfNecessary];
    });
}

- (void)_createIndicatorsIfNecessary {
    if (!self.needsCreateIndicators) {
        return;
    }
    self.needsCreateIndicators = NO;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self.currentPage >= self.numberOfPages) {
        self.currentPage = self.numberOfPages - 1;
    }
    for (CAShapeLayer *layer in self.indicatorLayers) {
        [layer removeFromSuperlayer];
    }
    [self.indicatorLayers removeAllObjects];
    // 添加新创建的 layer
    for (int i = 0; i < self.numberOfPages; i++) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.actions = @{ @"bounds": [NSNull null] };
        [self.contentView.layer addSublayer:layer];
        [self.indicatorLayers addObject:layer];
    }
    [self _setNeedsUpdateIndicators];
    [self _updateIndicatorsIfNecessary];
    [CATransaction commit];
}

#pragma mark Set & Get
- (void)setNumberOfPages:(int)numberOfPages {
    _numberOfPages = numberOfPages;
    [self _setNeedsCreateIndicators];
}

- (void)setCurrentPage:(int)currentPage {
    _currentPage = currentPage;
    [self _setNeedsUpdateIndicators];
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
    _itemSpacing = itemSpacing;
    [self _setNeedsUpdateIndicators];
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing {
    _interitemSpacing = interitemSpacing;
    [self setNeedsLayout];
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    _contentInsets = contentInsets;
    [self setNeedsLayout];
}

- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
    [super setContentHorizontalAlignment:contentHorizontalAlignment];
    [self setNeedsLayout];
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage {
    _hidesForSinglePage = hidesForSinglePage;
    [self _setNeedsUpdateIndicators];
}

@end
