//
//  PBCollectionViewFlowLayout.h
//  PBCollectionFlowLayoutDemo
//
//  Created by Jpache on 2017/8/4.
//  Copyright © 2017年 Jpache. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PBCollectionViewDelegateFlowLayout <UICollectionViewDelegate>
@required

/**
 获取collectionView的itemSize
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
@optional
/**
 获取collectionView每行间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
/**
 获取collectionView每列间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
/**
 获取collectionView每个section的item的边距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
/**
 获取collectionView每个section的header的size
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
/**
 获取collectionView每个section的footer的size
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;


@end

@interface PBCollectionViewFlowLayout : UICollectionViewLayout

@end
