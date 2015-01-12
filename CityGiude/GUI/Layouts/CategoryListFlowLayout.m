//
//  CatalogiPhoneFlowLayout.m
//  AppsPublisher
//
//  Created by Dmitry Kuznetsov on 17/06/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "CategoryListFlowLayout.h"
#import "BannerHeaderCollectionView.h"
#import "Constants.h"
#import "DiscountListViewController.h"
//#import "BookShelfiPadPortraitDecorationView.h"
//#import "CatalogHeaderView.h"

//static NSString * const catalogCellKind = @"CatalogCell"; //key for CatalogCells

@implementation CategoryListFlowLayout{
    NSDictionary *_layoutInfo; //store all layout information
    NSDictionary *_headerRect; //store info about header
    NSDictionary *_shelvesRect; //store shelf layout info
    CGSize _contensSize;
}

-(id)init{
    self = [super init];
    
    if(self){
        [self setDefaultValues]; // Specify Flow Layout properties
    }
    
    return self;
}

-(void)setDefaultValues{
    
    CGFloat scale = 185.0f / 320.0f; // H/W from initial design
    CGFloat screenSize = [UIScreen mainScreen].bounds.size.width;
    self.itemSize = CGSizeMake(screenSize, 80.0f); //size of each cell
    self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.itemInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.numberOfColumns = 1;
    self.interItemSpacingY = 0.0f;

    self.headerViewHeight = screenSize * scale;
    //self.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, self.headerViewHeight);
    
    //Register Decoration View Class
//    [self registerClass:[BookShelfiPadPortraitDecorationView class] forDecorationViewOfKind:[BookShelfiPadPortraitDecorationView kind]];
    
}


#pragma mark - Layout

-(void)prepareLayout{
    
    if(IS_IPAD){
        CGFloat scale = 185.0f / 320.0f; // H/W from initial design
        self.headerViewHeight = self.collectionView.frame.size.width * scale;
        
        if([self.delegate isKindOfClass:[DiscountListViewController class]])
            self.itemSize = CGSizeMake(self.collectionView.frame.size.width, self.itemSize.height);
        else
            self.itemSize = CGSizeMake(self.collectionView.frame.size.width/2, self.itemSize.height);
    }
    
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary]; //temp dict for attributes
    NSMutableDictionary *headerLayoutInfo = [NSMutableDictionary dictionary]; //temp dict for header view attributes
    
    CGFloat top = 0.0f;
    CGFloat contentHeight = 0.0f;
    UICollectionViewLayoutAttributes *lastItem;
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0]; //number of items in section. I have only 1 section
    //NSLog(@"List itemCount: %ld", itemCount);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0]; //default value for indexpath
    
    UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:[BannerHeaderCollectionView kind] withIndexPath:indexPath];
    headerAttributes.frame = [self frameForAlbumTitleAtIndexPath:indexPath];    
    headerLayoutInfo[indexPath] = headerAttributes;
    
    lastItem = headerAttributes;
    top += self.headerViewHeight;
    
    for(NSInteger item = 0; item < itemCount; item++){
        indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        
        UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        itemAttributes.frame = [self frameForCellAtIndexPath:indexPath];
        
        cellLayoutInfo[indexPath] = itemAttributes;
        lastItem = itemAttributes;
        //NSLog(@"itemAttributes = %@", itemAttributes);

    }
    
    CGFloat bottomSize = 0.0f;//(section == 0) ? 0.0f : attr.frame.size.height;
    //NSLog(@"last itemAttributes.frame: %f, %f, %f, %f", lastItem.frame.origin.x, lastItem.frame.origin.y, lastItem.frame.size.width, lastItem.frame.size.height);
    top = lastItem.frame.origin.y + lastItem.frame.size.height + bottomSize;
    contentHeight = top;
    
    _contensSize = CGSizeMake(self.collectionView.frame.size.width, contentHeight);
    _layoutInfo = [NSDictionary dictionaryWithDictionary:cellLayoutInfo];
    _headerRect = [NSDictionary dictionaryWithDictionary:headerLayoutInfo];
}

#pragma mark - Private

-(CGRect)frameForAlbumTitleAtIndexPath:(NSIndexPath*)indexPath{
    return CGRectMake(0, 0, self.collectionView.frame.size.width, self.headerViewHeight);
}

-(CGRect)frameForCellAtIndexPath:(NSIndexPath*)indexPath{
        
//    if(indexPath.item == 0) //hide first item because it is showed in headerView
//        return CGRectZero;
    
    NSInteger row = (indexPath.row) / self.numberOfColumns; //shift items to zero item
    NSInteger column = (indexPath.row) % self.numberOfColumns; //shift items to zero item
    
    CGFloat spacingX = self.collectionView.bounds.size.width -
                        self.itemInsets.left -
                        self.itemInsets.right -
                        (self.numberOfColumns * self.itemSize.width);
    
    if (self.numberOfColumns > 1) spacingX = spacingX / (self.numberOfColumns - 1);
    
    CGFloat originX = floorf(self.itemInsets.left + (self.itemSize.width + spacingX) * column);
    CGFloat originY = floor(self.headerViewHeight + self.itemInsets.top + self.sectionInset.top +
                        (self.itemSize.height + self.interItemSpacingY) * row);
    
    //NSLog(@"row = %i, column = %i, spacX = %f, {%f,%f}", row, column, spacingX, originX, originY);
    return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
}

#pragma mark - Attributes

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect{

    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:0];
    
    [_layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop){
        if(CGRectIntersectsRect(rect, attributes.frame)){
            attributes.zIndex = 1;
            [allAttributes addObject:attributes];
        }
    }];
    
    [_headerRect enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop){
        if(CGRectIntersectsRect(rect, attributes.frame)){
            [allAttributes addObject:attributes];
        }
    }];
    
    //add decoration view (shelves)
//    [_shelvesRect enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        if (CGRectIntersectsRect([obj CGRectValue], rect))
//        {
//            UICollectionViewLayoutAttributes *attributes;
//            attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:[BookShelfiPadPortraitDecorationView kind] withIndexPath:key];
//            
//            attributes.frame = [obj CGRectValue];
//            attributes.zIndex = 0;
//            [allAttributes addObject:attributes];
//        }
//    }];
    
    return allAttributes;
}

-(UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    return _layoutInfo[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind
                                                                     atIndexPath:(NSIndexPath *)indexPath
{
    return _headerRect[indexPath];
}

-(CGSize)collectionViewContentSize{
    
//    NSInteger rowCount = ([self.collectionView numberOfItemsInSection:0] - 0) / self.numberOfColumns;
//    
//    // make sure we count another row if one is only partially filled
//    if (([self.collectionView numberOfItemsInSection:0] - 0) % self.numberOfColumns) rowCount++;
//    //NSLog(@"Number of rows: %ld, %ld", [self.collectionView numberOfItemsInSection:0], rowCount);
//
//    
//    CGFloat height = self.headerViewHeight + self.itemInsets.top +
//                     rowCount * self.itemSize.height +
//                     rowCount * self.interItemSpacingY +
//                     self.sectionInset.bottom;
//    
//    
//    return CGSizeMake(self.collectionView.bounds.size.width, height);
    return _contensSize;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset{
    return CGPointMake(0.0f, 0.0f);
}

@end
