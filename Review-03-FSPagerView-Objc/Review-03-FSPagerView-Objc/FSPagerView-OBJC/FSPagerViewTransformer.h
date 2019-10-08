//
//  FSPagerViewTransformer.h
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/26.
//  Copyright © 2019 Q. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FSPagerView;
@class FSPagerViewLayoutAttributes;

typedef NS_ENUM (NSUInteger, FSPagerViewTransformerType) {
    FSPagerViewTransformerTypeCrossFading,
    FSPagerViewTransformerTypeZoomOut,
    FSPagerViewTransformerTypeDepth,
    FSPagerViewTransformerTypeOverLap,
    FSPagerViewTransformerTypeLinear,
    FSPagerViewTransformerTypeCoverFlow,
    FSPagerViewTransformerTypeFerrisWheel,
    FSPagerViewTransformerTypeInvertedFerrisWheel,
    FSPagerViewTransformerTypeCubic
};

@interface FSPagerViewTransformer : NSObject
/** pagerView */
@property (nonatomic, weak) FSPagerView *pagerView;
/** transformerType */
@property (nonatomic, assign, readonly) FSPagerViewTransformerType type;
/** minimumScale */
@property (nonatomic, assign) CGFloat minimumScale;
/** minimumAlpha */
@property (nonatomic, assign) CGFloat minimumAlpha;

/**
 初始化对于的 transformer 类型

 @param type 传入一个枚举值
 @return 返回一个 transformer 实例
 */
- (instancetype)initWithType:(FSPagerViewTransformerType)type;

/**
 对 Layout 中的 Attributes 应用当前的 transformer

 @param attributes attributes
 */
- (void)applyTransformerToAttributes:(FSPagerViewLayoutAttributes *)attributes;

/**
 返回当前的 InteritemSpacing

 @return InteritemSpacing
 */
- (CGFloat)proposedInteritemSpacing;

@end
