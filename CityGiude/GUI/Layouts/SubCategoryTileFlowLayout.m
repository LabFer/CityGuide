//
//  CatalogiPhoneFlowLayout.m
//  AppsPublisher
//
//  Created by Dmitry Kuznetsov on 17/06/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "SubCategoryTileFlowLayout.h"
#import "BannerHeaderCollectionView.h"
#import "Constants.h"
//#import "BookShelfiPadLandscapeDecorationView.h"
//#import "CatalogHeaderView.h"


static NSString * const catalogCellKind = @"CatalogCell"; //key for CatalogCells

@implementation SubCategoryTileFlowLayout{
    NSDictionary *_layoutInfo; //store all layout information
    //NSDictionary *_headerRect; //store info about header
    //NSDictionary *_shelvesRect; //store shelf layout info
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
    
    //CGFloat scale = 185.0f / 320.0f; // H/W from initial design
    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width / 2;
    self.itemSize = CGSizeMake(sizeOfItems, sizeOfItems); //size of each cell
    self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 160.0f, 0.0f);
    self.itemInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.numberOfColumns = 2;
    self.interItemSpacingY = 0.0f;
    
    self.headerViewHeight = 0.0f;
    
    //Register Decoration View Class
//    [self registerClass:[BookShelfiPadLandscapeDecorationView class] forDecorationViewOfKind:[BookShelfiPadLandscapeDecorationView kind]];

}


#pragma mark - Layout

-(void)prepareLayout{

    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary]; //temp dict for attributes
    
    CGFloat top = 0.0f;
    CGFloat contentHeight = 0.0f;
    UICollectionViewLayoutAttributes *lastItem;
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0]; //number of items in section. I have only 1 section
    
//    NSLog(@"Tile itemCount: %ld", itemCount);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0]; //default value for indexpath
    
    for(NSInteger item = 0; item < itemCount; item++){
        indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        
        UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        itemAttributes.frame = [self frameForCellAtIndexPath:indexPath];
        
        cellLayoutInfo[indexPath] = itemAttributes;
        //NSLog(@"itemAttributes = %@", itemAttributes);
        lastItem = itemAttributes;

    }
    
    CGFloat bottomSize = 0.0f;//(section == 0) ? 0.0f : attr.frame.size.height;
    //NSLog(@"last itemAttributes.frame: %f, %f, %f, %f", lastItem.frame.origin.x, lastItem.frame.origin.y, lastItem.frame.size.width, lastItem.frame.size.height);
    top = lastItem.frame.origin.y + lastItem.frame.size.height + bottomSize;
    contentHeight = top;
    
    _contensSize = CGSizeMake(self.collectionView.frame.size.width, contentHeight);
    _layoutInfo = [NSDictionary dictionaryWithDictionary:cellLayoutInfo];
}

#pragma mark - Private

-(CGRect)frameForCellAtIndexPath:(NSIndexPath*)indexPath{
    
//    if(indexPath.item == 0) //hide first item because it is showed in headerView
//        return CGRectZero;
    
    NSInteger row = (indexPath.row) / self.numberOfColumns;
    NSInteger column = (indexPath.row) % self.numberOfColumns;
    
    CGFloat spacingX = self.collectionView.bounds.size.width -
                        self.itemInsets.left -
                        self.itemInsets.right -
                        (self.numberOfColumns * self.itemSize.width);
    
    if (self.numberOfColumns > 1) spacingX = spacingX / (self.numberOfColumns - 1);
    
    CGFloat originX = floorf(self.itemInsets.left + (self.itemSize.width + spacingX) * column);
    CGFloat originY = floor(self.headerViewHeight + self.itemInsets.top + self.sectionInset.top +
                        (self.itemSize.height + self.interItemSpacingY) * row);
    
    //NSLog(@"tile frameForCellAtIndexPath: row = %i, column = %i, spacX = %f, {%f,%f}", row, column, spacingX, originX, originY);
    return CGRectMake(originX, originY, self.itemSize.width, self.itemSize.height);
}

#pragma mark - Attributes

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:_layoutInfo.count]; //return store of all attributes
    
    [_layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop){
        if(CGRectIntersectsRect(rect, attributes.frame)){
            attributes.zIndex = 1;
            [allAttributes addObject:attributes];
        }
    }];
    
    return allAttributes;
}

-(UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    return _layoutInfo[indexPath];
}

-(CGSize)collectionViewContentSize{
    
    return _contensSize;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset{
    return CGPointMake(0.0f, 0.0f);
}

@end
