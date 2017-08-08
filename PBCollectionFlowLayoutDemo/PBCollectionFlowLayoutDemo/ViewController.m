//
//  ViewController.m
//  PBCollectionFlowLayoutDemo
//
//  Created by Jpache on 2017/8/4.
//  Copyright © 2017年 Jpache. All rights reserved.
//

#import "ViewController.h"
#import "PBCollectionViewFlowLayout.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, PBCollectionViewDelegateFlowLayout>

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _count = 10;
    PBCollectionViewFlowLayout *flowLayout = [PBCollectionViewFlowLayout new];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 20) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView setContentInset:UIEdgeInsetsMake([UIScreen mainScreen].bounds.size.width / (375.f / 200.f), 0, 0, 0)];
    _collectionView.backgroundColor = [UIColor blackColor];
    [_collectionView registerClass:[PBCell class] forCellWithReuseIdentifier:@"haha"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"hehe"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"hehe"];
//    collectionView.contentOffset = CGPointMake(0, 1000);
    [self.view addSubview:_collectionView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _collectionView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20);
    [_collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 1) {
        _count += 30;
        [collectionView reloadData];
    }else {
        collectionView.contentOffset = CGPointMake(0, 1000);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PBCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"haha" forIndexPath:indexPath];

    if (indexPath.section == 0) {
        cell.title = @"分类";
    }else if (indexPath.section == 1) {
        cell.title = @"新品";
    }else if (indexPath.section == 2) {
        cell.title = @"低价";
    }else if (indexPath.section == 3) {
        cell.title = @"专场";
    }else {
        cell.title = @"新品";
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"hehe" forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view.backgroundColor = [UIColor yellowColor];
    }else {
        view.backgroundColor = [UIColor cyanColor];
    }
    return view;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }else if (section == 1) {
        return 6;
    }else if (section == 2) {
        return 1;
    }else if (section == 3) {
        return 3;
    }else {
        return 10;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 5;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 5 * 3) / 2;
        return CGSizeMake(width, width / (180.f / 70.f));
    }else if (indexPath.section == 1) {
        if (indexPath.row % 6 == 0) {
            return CGSizeMake([UIScreen mainScreen].bounds.size.width / 2.f, [UIScreen mainScreen].bounds.size.width / 2.f);
        }else if (indexPath.row % 6 == 1 || indexPath.row % 6 == 2) {
            return CGSizeMake([UIScreen mainScreen].bounds.size.width / 2.f, [UIScreen mainScreen].bounds.size.width / 4.f);
        }else {
            return CGSizeMake([UIScreen mainScreen].bounds.size.width / 3.f, [UIScreen mainScreen].bounds.size.width / 3.f);
        }
    }else if (indexPath.section == 2) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 182.f * ([UIScreen mainScreen].bounds.size.width / 375.f));
    }else if (indexPath.section == 3) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width / (375.f / 184.f) + 182.f * ([UIScreen mainScreen].bounds.size.width / 375.f) + 5);
    }else {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 110.f / (750.f / 1034.f) + 20.f);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeZero;
    }else {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 68.f * ([UIScreen mainScreen].bounds.size.width / 375.f));
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (section == 0 || section == 2 || section == 4) {
        return CGSizeZero;
    }else {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 38.f * ([UIScreen mainScreen].bounds.size.width / 375.f));
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(6, 5, 6, 5);
    }else {
        return UIEdgeInsetsZero;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 6;
    }else {
        return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return 5;
    }else {
        return 0;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end








@interface PBCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation PBCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor redColor];
//        _label.layer.borderColor = [UIColor blackColor].CGColor;
//        _label.layer.borderWidth = 1.f;
        [self.contentView addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _label.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    _label.text = title;
}

@end
