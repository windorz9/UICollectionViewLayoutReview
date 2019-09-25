//
//  FSPagerViewCell.m
//  Review-03-FSPagerView-Objc
//
//  Created by windorz on 2019/9/25.
//  Copyright © 2019 Q. All rights reserved.
//

#import "FSPagerViewCell.h"

static void *kvoContext = &kvoContext;

@interface FSPagerViewCell ()
/** TextLabel */
@property (nonatomic, strong, readwrite) UILabel *textLabel;
/** ImageView */
@property (nonatomic, strong, readwrite) UIImageView *imageView;
/** selectionColor */
@property (nonatomic, strong) UIColor *selectionColor;
/** selectedForegroundView */
@property (nonatomic, strong) UIView *selectedForegroundView;

@end

@implementation FSPagerViewCell

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
    if (_imageView) {
        _imageView.frame = self.contentView.bounds;
    }
    if (_textLabel) {
        CGRect rect = self.contentView.bounds;
        CGFloat height = _textLabel.font.pointSize * 1.5;
        rect.size.height = height;
        rect.origin.y = self.contentView.frame.size.height - height;
        _textLabel.superview.frame = rect;

        CGRect superRect = _textLabel.superview.bounds;
        superRect = CGRectInset(superRect, 8, 0);
        superRect.size.height -= 1;
        superRect.origin.y += 1;
        _textLabel.frame = superRect;
    }
    if (_selectedForegroundView) {
        _selectedForegroundView.frame = self.contentView.bounds;
    }
}

- (void)dealloc {
    if (_textLabel) {
        [_textLabel removeObserver:self forKeyPath:@"font" context:kvoContext];
    }
}

- (void)_commonInit {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowRadius = 5;
    self.contentView.layer.shadowOpacity = 0.75;
    self.contentView.layer.shadowOffset = CGSizeZero;
    self.selectionColor = [UIColor colorWithWhite:0.2 alpha:0.2];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (kvoContext == context) {
        if ([keyPath isEqualToString:@"font"]) {
            [self setNeedsLayout];
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

#pragma mark Get & Set
- (UILabel *)textLabel {
    if (!_textLabel) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.userInteractionEnabled = NO;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        [self.contentView addSubview:view];
        [view addSubview:textLabel];
        [textLabel addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:kvoContext];
        _textLabel = textLabel;
    }
    return _textLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (UIView *)selectedForegroundView {
    if (!_imageView) {
        return nil;
    }
    if (!_selectedForegroundView) {
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        [_imageView addSubview:view];
        _selectedForegroundView = view;
    }
    return _selectedForegroundView;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.selectedForegroundView.layer.backgroundColor = self.selectionColor.CGColor;
    } else if (![super isSelected]) {
        self.selectedForegroundView.layer.backgroundColor = [UIColor clearColor].CGColor;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectedBackgroundView.layer.backgroundColor = selected ? self.selectionColor.CGColor : [UIColor clearColor].CGColor;
}

@end
