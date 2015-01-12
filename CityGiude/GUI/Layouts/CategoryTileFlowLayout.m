//
//  CatalogiPhoneFlowLayout.m
//  AppsPublisher
//
//  Created by Dmitry Kuznetsov on 17/06/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "CategoryTileFlowLayout.h"
#import "BannerHeaderCollectionView.h"
#import "Constants.h"
//#import "BookShelfiPadLandscapeDecorationView.h"
//#import "CatalogHeaderView.h"

//static NSString * const catalogCellKind = @"CatalogCell"; //key for CatalogCells

@implementation CategoryTileFlowLayout{
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
    self.itemSize = CGSizeMake(screenSize/2, screenSize/2); //size of each cell
    self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.itemInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    self.numberOfColumns = 2;
    self.interItemSpacingY = 0.0f;
    
    
    
    self.headerViewHeight = 185.0f;//screenSize * scale;
    
    //Register Decoration View Class
//    [self registerClass:[BookShelfiPadLandscapeDecorationView class] forDecorationViewOfKind:[BookShelfiPadLandscapeDecorationView kind]];

}


#pragma mark - Layout

-(void)prepareLayout{
    
    if(IS_IPAD){
        
        self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        CGFloat scale = 185.0f / 320.0f; // H/W from initial design
        self.headerViewHeight = 440.0f;//self.collectionView.frame.size.width * scale;
        
    }
    
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary]; //temp dict for attributes
    NSMutableDictionary *headerLayoutInfo = [NSMutableDictionary dictionary]; //temp dict for header view attributes
    
    CGFloat top = 0.0f;
    CGFloat contentHeight = 0.0f;
    UICollectionViewLayoutAttributes *lastItem;
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0]; //number of items in section. I have only 1 section
    
    //NSLog(@"Tile itemCount: %ld", itemCount);
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
        //NSLog(@"itemAttributes = %@", itemAttributes);
        lastItem = itemAttributes;
        
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
    
    NSInteger row = (indexPath.row) / self.numberOfColumns;
    NSInteger column = (indexPath.row) % self.numberOfColumns;
    
    CGFloat spacingX = self.collectionView.bounds.size.width - (self.sectionInset.left + self.sectionInset.right) -
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
    
    [_headerRect enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *innerStop){
        if(CGRectIntersectsRect(rect, attributes.frame)){
            [allAttributes addObject:attributes];
        }
    }];
    
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
    
    return _contensSize;
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset{
    return CGPointMake(0.0f, 0.0f);
}

@end
