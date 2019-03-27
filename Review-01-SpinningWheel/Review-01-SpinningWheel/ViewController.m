//
//  ViewController.m
//  Review-01-SpinningWheel
//
//  Created by windorz9 on 2019/3/27.
//  Copyright © 2019 windorz9. All rights reserved.
//

#import "ViewController.h"
#import "SpinningWheelCollectionViewLayout.h"
#import "SpinningWheelCell.h"

@interface ViewController () <UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArrays;
@end

static NSString *SpinngingCellID = @"SpinngingCellID";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建一个集合视图
    SpinningWheelCollectionViewLayout *layout = [[SpinningWheelCollectionViewLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    [self.view addSubview:collectionView];
    [collectionView registerClass:[SpinningWheelCell class] forCellWithReuseIdentifier:SpinngingCellID];
    collectionView.dataSource = self;
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArrays.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SpinningWheelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SpinngingCellID forIndexPath:indexPath];
    cell.imageName = self.dataArrays[indexPath.item];
    return cell;
}



#pragma mark - Setter && Getter
- (NSMutableArray *)dataArrays {
    if (!_dataArrays) {
        _dataArrays = [NSMutableArray array];
        for (int i = 1; i < 15; i++) {
            [_dataArrays addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _dataArrays;
}

@end
