//
//  SpinningWheelCell.m
//  Review-01-SpinningWheel
//
//  Created by windorz9 on 2019/3/27.
//  Copyright © 2019 windorz9. All rights reserved.
//

#import "SpinningWheelCell.h"
#import "SpinningWheelCollectionViewLayoutAttributes.h"

@interface SpinningWheelCell ()
@property (nonatomic, strong) UIImageView *bookImageView;
@end

@implementation SpinningWheelCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.bookImageView];
        self.bookImageView.frame = self.contentView.bounds;
        self.bookImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}


- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    
    [super applyLayoutAttributes:layoutAttributes];
    
    SpinningWheelCollectionViewLayoutAttributes *spinngingWheelAttributes = (SpinningWheelCollectionViewLayoutAttributes *)layoutAttributes;
    
    self.layer.anchorPoint = spinngingWheelAttributes.anchorPoint;
    
    CGFloat num1 = spinngingWheelAttributes.anchorPoint.y - 0.5;
    CGFloat num2 = self.bounds.size.height;
    
    CGPoint center = self.center;
    center.y += num1 * num2;
    self.center = center;
}


#pragma mark - Setter && Getter
- (UIImageView *)bookImageView {
    if (!_bookImageView) {
        _bookImageView = [[UIImageView alloc] init];
        _bookImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bookImageView.layer.masksToBounds = YES;
        _bookImageView.layer.cornerRadius = 6.0;
        _bookImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _bookImageView.layer.borderWidth = 1.0;
        _bookImageView.layer.allowsEdgeAntialiasing = YES;
    }
    return _bookImageView;
    
}

- (void)setImageName:(NSString *)imageName {
    self.bookImageView.image = [UIImage imageNamed:imageName];
}


@end
