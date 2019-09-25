//
//  FSPagerControl.h
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/24.
//  Copyright © 2019 Q. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 继承自 UIControl 的 自定义 PagerControl
 */
@interface FSPagerControl : UIControl

/**
 The number of page indicators of the page control. Default is 0.
 指示器的页数 默认 0 页
 */
@property (nonatomic, assign) IBInspectable int numberOfPages;

/**
 The current page, highlighted by the page control. Default is 0.
 当前选中的页数, 默认 0 页
 */
@property (nonatomic, assign) IBInspectable int currentPage;

/**
 The spacing to use of page indicators in the page control.
 指示器 item 的大小
 */
@property (nonatomic, assign) IBInspectable CGFloat itemSpacing;

/**
 The spacing to use between page indicators in the page control.
 调节两个执行器之间的距离
 */
@property (nonatomic, assign) IBInspectable CGFloat interitemSpacing;

/**
 The distance that the page indicators is inset from the enclosing page control.
 页面指示器显示的 contentInsets
 */
@property (nonatomic, assign) IBInspectable UIEdgeInsets contentInsets;

/**
 The horizontal alignment of content within the control’s bounds. Default is center.
 控件在内容显示范围内的对齐方式 调用自身的属性即可 不需要进行声明
 */
//@property (nonatomic, assign) UIControlContentHorizontalAlignment contentHorizontalAlignment;

/**
 Hide the indicator if there is only one page. default is NO
 只有一页时是否隐藏指示器
 */
@property (nonatomic, assign) BOOL hidesForSinglePage;


- (void)setStrokeColor:(UIColor *)strokeColor forState:(UIControlState)state;
- (void)setFillColor:(UIColor *)fillColor forState:(UIControlState)state;
- (void)setImage:(UIImage *)image forState:(UIControlState)state;
- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)state;
- (void)setPath:(UIBezierPath *)path forState:(UIControlState)state;

@end

