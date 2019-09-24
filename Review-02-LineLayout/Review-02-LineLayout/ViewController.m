//
//  ViewController.m
//  Review-02-LineLayout
//
//  Created by windorz on 2019/9/23.
//  Copyright © 2019 Q. All rights reserved.
//

#define CELL_LENGTH 50.0
#define DISTANCE    10.0
#define CELL_COUNT  100

#import "ViewController.h"
#import "CustomCell.h"
#import "LineLayout.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

/** CollectionView */
@property (nonatomic, strong) UICollectionView *collectionView;

@end

static NSString *const CellID = @"CellID";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    LineLayout *layout = [[LineLayout alloc] init];
    layout.itemSize = CGSizeMake(CELL_LENGTH, CELL_LENGTH);
    layout.sectionInset = UIEdgeInsetsMake(0, (self.view.bounds.size.width -  CELL_LENGTH) / 2, 0, (self.view.bounds.size.width - CELL_LENGTH) / 2);
    layout.minimumLineSpacing = DISTANCE;
    layout.minimumInteritemSpacing = DISTANCE;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 100) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView = collectionView;
    [collectionView registerClass:[CustomCell class] forCellWithReuseIdentifier:CellID];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
}

// 处理集合视图停止滚动
- (void)handleCollectionViewScrollEnd:(UIScrollView *)scrollView {
    NSIndexPath *indexPath;
    if (scrollView.contentOffset.x < CELL_LENGTH + DISTANCE / 2) {
        indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    } else if (scrollView.contentOffset.x > (CELL_COUNT - 1) * (CELL_COUNT + DISTANCE - DISTANCE / 2)) {
        indexPath = [NSIndexPath indexPathForItem:CELL_COUNT - 1 inSection:0];
    } else {
        CGFloat item = roundf((scrollView.contentOffset.x - CELL_LENGTH - DISTANCE / 2) / (CELL_LENGTH + DISTANCE));
        indexPath = [NSIndexPath indexPathForItem:(int)item + 1 inSection:0];
    }
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return CELL_COUNT;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellID forIndexPath:indexPath];
    cell.titleLabel.text = [NSString stringWithFormat:@"%d", (int)indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollEnd = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollEnd) {
        [self handleCollectionViewScrollEnd:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragScrollEnd = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragScrollEnd) {
            [self handleCollectionViewScrollEnd:scrollView];
        }
    }
}

@end
