//
//  CustomCell.m
//  Review-02-LineLayout
//
//  Created by windorz on 2019/9/23.
//  Copyright © 2019 Q. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

@end
