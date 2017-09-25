//
//  PBCollectionViewFlowLayout.m
//  PBCollectionFlowLayoutDemo
//
//  Created by Jpache on 2017/8/4.
//  Copyright © 2017年 Jpache. All rights reserved.
//

#import "PBCollectionViewFlowLayout.h"

@interface PBCollectionViewFlowLayout ()
/**
 所有布局方式
 */
@property (nonatomic, strong) NSMutableArray *layoutAttributes;
@property (nonatomic, strong) NSMutableDictionary *layoutAttributesDic;
/**
 所有可以放置cell的起点, 字典内容为CGRect
 */
@property (nonatomic, strong) NSMutableArray <NSValue *>*everyLayoutPositions;
@property (nonatomic, assign) CGFloat collectionViewContentWidth;

@end

@implementation PBCollectionViewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _layoutAttributes = [NSMutableArray array];
        _layoutAttributesDic = [NSMutableDictionary dictionary];
        _everyLayoutPositions = [NSMutableArray array];
        _collectionViewContentWidth = 0.f;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    [_layoutAttributes removeAllObjects];
    [_everyLayoutPositions removeAllObjects];
    [_layoutAttributesDic removeAllObjects];
    [_everyLayoutPositions addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, self.collectionView.frame.size.width, MAXFLOAT)]];
    
    NSInteger sectionCount = self.collectionView.numberOfSections;
    for (NSUInteger itemSection = 0; itemSection < sectionCount; itemSection++) {
        
        // 计算header布局
        UICollectionViewLayoutAttributes *sectionHeaderAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:itemSection]];
        if (!CGSizeEqualToSize(sectionHeaderAttributes.size, CGSizeZero)) {
            [_layoutAttributes addObject:sectionHeaderAttributes];
            [_layoutAttributesDic setObject:sectionHeaderAttributes forKey:[NSString stringWithFormat:@"section%ziheader", itemSection]];
        }
        
        // 计算item布局
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:itemSection];
        for (NSUInteger itemRow = 0; itemRow < itemCount; itemRow++) {
            // 生成位置信息
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:itemRow inSection:itemSection];
            // 生成布局信息
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (!CGSizeEqualToSize(attributes.size, CGSizeZero)) {
                [_layoutAttributes addObject:attributes];
                [_layoutAttributesDic setObject:attributes forKey:indexPath];
            }
        }
        
        // 计算footer布局
        UICollectionViewLayoutAttributes *sectionFooterAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForRow:0 inSection:itemSection]];
        if (!CGSizeEqualToSize(sectionFooterAttributes.size, CGSizeZero)) {
            [_layoutAttributes addObject:sectionFooterAttributes];
            [_layoutAttributesDic setObject:sectionHeaderAttributes forKey:[NSString stringWithFormat:@"section%zifooter", itemSection]];
        }
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes;
    attributes = [_layoutAttributesDic objectForKey:indexPath];
    if (attributes) {
        return attributes;
    }
    
    attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGSize itemSize = CGSizeZero;
    CGFloat itemLineSpace = 0.f;
    CGFloat itemColumnSpace = 0.f;
    // 获取item大小
    if ((id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate && [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        itemSize = [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
    }
    // 获取最小行间距
    if ((id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate && [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        itemLineSpace = [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:indexPath.section];
    }
    // 获取最小列间距
    if ((id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate && [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        itemColumnSpace = [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:indexPath.section];
    }
    
    // 查询当前空缺位置是否可以放得下当前item
    for (NSInteger positionIndex = _everyLayoutPositions.count - 1; positionIndex >= 0; positionIndex--) {
        CGRect rect = [_everyLayoutPositions[positionIndex] CGRectValue];
        // 放得下当前item
        if (rect.size.width >= itemSize.width && rect.size.height >= itemSize.height) {
            attributes.frame = CGRectMake(rect.origin.x, rect.origin.y, itemSize.width, itemSize.height);
            // 大小相等
            if (itemSize.width == rect.size.width && itemSize.height == rect.size.height) {
                // 放下之后当前行填满
                // ┏━━━━┳━━━━━━━━━━━━━━━┓
                // ┃    ┃               ┃
                // ┃    ┃               ┃
                // ┃    ┣━━━━━━━━━━━━━━━┫
                // ┃    ┃               ┃
                // ┃    ┃ current       ┃
                // ┃    ┃               ┃
                // ┣━━━━┻━━━━━━━━━━━━━━━┫
                // ┃                    ┃
                // ┃                    ┃
                // ┃                    ┃
                // ┗━━━━━━━━━━━━━━━━━━━━┛
                if (rect.origin.x + rect.size.width != _collectionViewContentWidth) {
                    // 如果当前点不是记录的点中最后一个点
                    if (positionIndex != _everyLayoutPositions.count - 1) {
                        CGRect next = [_everyLayoutPositions[positionIndex + 1] CGRectValue];
                        next.size.height = rect.origin.y + rect.size.height + itemLineSpace;
                        [_everyLayoutPositions replaceObjectAtIndex:positionIndex + 1 withObject:[NSValue valueWithCGRect:next]];
                    }
                    
                    [_everyLayoutPositions removeObject:[NSValue valueWithCGRect:rect]];
                }
                // 放下之后当前行未填满
                // ┏━━━━┳━━━━━━━━━━┳━━━━┓      ┏━━━━┳━━━━━━━━━━┳━━━━┓
                // ┃    ┃          ┃    ┃      ┃    ┃          ┃    ┃
                // ┃    ┣━━━━━━━━━━┫    ┃      ┃    ┣━━┳━━━━━━━┫    ┃
                // ┃    ┃ current  ┃    ┃      ┃    ┃  ┃current┃    ┃
                // ┃    ┃          ┃    ┃      ┃    ┣━━┻━━━━━━━┛    ┃
                // ┣━━━━┻━━━━━━━━━━┛    ┃      ┣━━━━┛               ┃
                // ┃                    ┃      ┃                    ┃
                // ┃                    ┃      ┃                    ┃
                // ┃                    ┃      ┃                    ┃
                // ┗━━━━━━━━━━━━━━━━━━━━┛      ┗━━━━━━━━━━━━━━━━━━━━┛
                else {
                    // 判断是否需要更新x == 0时的宽度, 也就是图一的情况
                    if (rect.origin.y + rect.size.height == [_everyLayoutPositions[0] CGRectValue].origin.y) {
                        CGRect front = [_everyLayoutPositions[positionIndex - 1] CGRectValue];
                        front.size.width = rect.origin.x + rect.size.width + itemColumnSpace;
                        [_everyLayoutPositions replaceObjectAtIndex:positionIndex - 1 withObject:[NSValue valueWithCGRect:front]];
                    }
                    [_everyLayoutPositions removeObject:[NSValue valueWithCGRect:rect]];
                }
            }
            // 高相等, 宽不等
            // ┏━━━━┳━━━━━━━━━━┳━━━━┓
            // ┃    ┃          ┃    ┃
            // ┃    ┣━━━━━━━┳━━┛    ┃
            // ┃    ┃current┃       ┃
            // ┣━━━━┻━━━━━━━┛       ┃
            // ┃                    ┃
            // ┃                    ┃
            // ┃                    ┃
            // ┗━━━━━━━━━━━━━━━━━━━━┛
            else if (itemSize.width != rect.size.width && itemSize.height == rect.size.height) {
                CGRect current = CGRectMake(rect.origin.x + itemSize.width + itemColumnSpace,
                                            rect.origin.y,
                                            rect.size.width - itemSize.width - itemColumnSpace,
                                            itemSize.height);
                // 更新前一个点的宽度
                CGRect front = [_everyLayoutPositions[positionIndex - 1] CGRectValue];
                front.size.width = rect.origin.x + rect.size.width;
                
                [_everyLayoutPositions replaceObjectAtIndex:positionIndex - 1 withObject:[NSValue valueWithCGRect:front]];
                [_everyLayoutPositions replaceObjectAtIndex:positionIndex withObject:[NSValue valueWithCGRect:current]];
            }
            // 宽相等, 高不等
            // ┏━━━━┳━━━━━━━━━━┳━━━━┓
            // ┃    ┃          ┃    ┃
            // ┃    ┣━━━━━━━━━━┫    ┃
            // ┃    ┃current   ┃    ┃
            // ┃    ┣━━━━━━━━━━┛    ┃
            // ┣━━━━┛               ┃
            // ┃                    ┃
            // ┃                    ┃
            // ┃                    ┃
            // ┃                    ┃
            // ┗━━━━━━━━━━━━━━━━━━━━┛
            else if (itemSize.width == rect.size.width && itemSize.height != rect.size.height) {
                CGRect current = CGRectMake(rect.origin.x,
                                            rect.origin.y + itemSize.height + itemLineSpace,
                                            itemSize.width,
                                            rect.size.height - itemSize.height - itemLineSpace);
                if (positionIndex != _everyLayoutPositions.count - 1) {
                    CGRect next = [_everyLayoutPositions[positionIndex + 1] CGRectValue];
                    next.size.height = rect.origin.y + rect.size.height + itemLineSpace;
                    [_everyLayoutPositions replaceObjectAtIndex:positionIndex + 1 withObject:[NSValue valueWithCGRect:next]];
                }
                [_everyLayoutPositions replaceObjectAtIndex:positionIndex withObject:[NSValue valueWithCGRect:current]];
            }
            // 常规状态
            // ┏━━━━┳━━━━━━━━━━┳━━━━┓
            // ┃    ┃          ┃    ┃
            // ┃    ┣━━━━━━━┳━━┛    ┃
            // ┃    ┃current┃       ┃
            // ┃    ┣━━━━━━━┛       ┃
            // ┣━━━━┛               ┃
            // ┃                    ┃
            // ┃                    ┃
            // ┃                    ┃
            // ┃                    ┃
            // ┗━━━━━━━━━━━━━━━━━━━━┛
            else {
                CGRect current;
                if (positionIndex == 0) {
                    current = CGRectMake(rect.origin.x,
                                         rect.origin.y + itemSize.height + itemLineSpace,
                                         _collectionViewContentWidth,
                                         rect.size.height - itemSize.height - itemLineSpace);
                }
                else {
                    current = CGRectMake(rect.origin.x,
                                         rect.origin.y + itemSize.height + itemLineSpace,
                                         itemSize.width,
                                         rect.size.height - itemSize.height - itemLineSpace);
                }
                CGRect next = CGRectMake(rect.origin.x + itemSize.width + itemLineSpace,
                                         rect.origin.y,
                                         rect.size.width - itemSize.width - itemColumnSpace,
                                         itemSize.height);
                [_everyLayoutPositions replaceObjectAtIndex:positionIndex withObject:[NSValue valueWithCGRect:current]];
                
                if (positionIndex + 1 < _everyLayoutPositions.count && next.origin.x == [_everyLayoutPositions[positionIndex + 1] CGRectValue].origin.x && next.size.width == [_everyLayoutPositions[positionIndex + 1] CGRectValue].size.width) {
                    next.size.height += next.origin.y + itemLineSpace;
                    next.origin.y = [_everyLayoutPositions[positionIndex + 1] CGRectValue].origin.y;
                    [_everyLayoutPositions replaceObjectAtIndex:positionIndex + 1 withObject:[NSValue valueWithCGRect:next]];
                }
                else {
                    [_everyLayoutPositions insertObject:[NSValue valueWithCGRect:next] atIndex:positionIndex + 1];
                }
            }
            break;
        }
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attributes;
    
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        attributes = [_layoutAttributesDic objectForKey:[NSString stringWithFormat:@"section%ziheader", indexPath.section]];
    }else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter])  {
        attributes = [_layoutAttributesDic objectForKey:[NSString stringWithFormat:@"section%zifooter", indexPath.section]];
    }
    
    if (attributes) {
        return attributes;
    }
    
    attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    
    CGSize itemSize = CGSizeZero;
    UIEdgeInsets itemEdgeInsets = UIEdgeInsetsZero;
    CGRect tempRect = [self getMaxYRect];
    
    if ((id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate && [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        itemEdgeInsets = [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:indexPath.section];
    }
    
    
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        if ((id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate && [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
            itemSize = [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:indexPath.section];
        }
        
        attributes.frame = CGRectMake(0, tempRect.origin.y, itemSize.width, itemSize.height);
        tempRect.origin.y = tempRect.origin.y + itemSize.height + itemEdgeInsets.top;
        tempRect.origin.x = itemEdgeInsets.left;
        tempRect.size.width = self.collectionView.frame.size.width - itemEdgeInsets.left - itemEdgeInsets.right;
        _collectionViewContentWidth = tempRect.size.width;
    }
    else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        if ((id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate && [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
            itemSize = [(id<PBCollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:indexPath.section];
        }
        
        attributes.frame = CGRectMake(0, tempRect.origin.y + itemEdgeInsets.bottom, itemSize.width, itemSize.height);
        tempRect.origin.y = tempRect.origin.y + itemSize.height;
    }
    
    [_everyLayoutPositions removeAllObjects];
    [_everyLayoutPositions addObject:[NSValue valueWithCGRect:tempRect]];
    
    return attributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributesArr = [NSMutableArray array];
    
    [_layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(CGRectIntersectsRect(obj.frame, rect)) {
            [layoutAttributesArr addObject:obj];
        }
    }];
    return layoutAttributesArr;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetMinX(newBounds) != CGRectGetMinX(oldBounds)) {
        return YES;
    }
    return NO;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width, [self getMaxYRect].origin.y);
}

#pragma mark - Helper

- (CGRect)getMaxYRect {
    CGRect maxYRect = CGRectZero;
    CGFloat maxY = -1;
    for (NSValue *rectValue in _everyLayoutPositions) {
        CGRect tempRect = [rectValue CGRectValue];
        if (maxY < tempRect.origin.y) {
            maxYRect = [rectValue CGRectValue];
            maxY = maxYRect.origin.y;
        }
    }
    return maxYRect;
}

@end
