//
//  CatalogiPhoneFlowLayout.m
//  AppsPublisher
//
//  Created by Dmitry Kuznetsov on 17/06/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "SearchListFlowLayout.h"
#import "SearchHeaderCollectionView.h"
#import "Constants.h"
//#import "BookShelfiPadPortraitDecorationView.h"
//#import "CatalogHeaderView.h"

//static NSString * const catalogCellKind = @"CatalogCell"; //key for CatalogCells

@implementation SearchListFlowLayout{
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

    self.headerViewHeight = 50.0f;
    //self.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, self.headerViewHeight);
    
    //Register Decoration View Class
//    [self registerClass:[BookShelfiPadPortraitDecorationView class] forDecorationViewOfKind:[BookShelfiPadPortraitDecorationView kind]];
    
}


#pragma mark - Layout

-(void)prepareLayout{
    
    if(IS_IPAD){
        self.itemSize = CGSizeMake(self.collectionView.frame.size.width, self.itemSize.height);
    }
    
    NSMutableDictionary *cellLayoutInfo = [NSMutableDictionary dictionary]; //temp dict for attributes
    NSMutableDictionary *headerLayoutInfo = [NSMutableDictionary dictionary]; //temp dict for header view attributes
    
    CGFloat top = 0.0f;
    CGFloat contentHeight = 0.0f;
    UICollectionViewLayoutAttributes *lastItem;
    
    NSInteger sectionCount = [self.collectionView numberOfSections]; //here I have 2 sections
    
    for(NSInteger section = 0; section < sectionCount; section++){
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section]; //default value for indexpath
        
        UICollectionViewLayoutAttributes *headerAttributes = [UICollectionViewLayoutAttributes                                                              layoutAttributesForSupplementaryViewOfKind:[SearchHeaderCollectionView kind] withIndexPath:indexPath];
        
        //calculate frame of section header
        headerAttributes.frame = CGRectMake(0, top, self.collectionView.frame.size.width, self.headerViewHeight);
        
        //NSLog(@"headerAttributes.frame: %f, %f, %f, %f", headerAttributes.frame.origin.x, headerAttributes.frame.origin.y, headerAttributes.frame.size.width, headerAttributes.frame.size.height);
        
        headerLayoutInfo[indexPath] = headerAttributes;
        lastItem = headerAttributes;
        
        top += self.headerViewHeight;
        
        NSInteger itemCount = [self.collectionView numberOfItemsInSection:section]; //number of items in section.
    
        for(NSInteger item = 0; item < itemCount; item++){
            indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            
            UICollectionViewLayoutAttributes *itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            //calculate frame for cell
            itemAttributes.frame = [self frameForCellAtIndexPath:indexPath withCellTopPosition:top];
            
            //NSLog(@"itemAttributes.frame: %f, %f, %f, %f", itemAttributes.frame.origin.x, itemAttributes.frame.origin.y, itemAttributes.frame.size.width, itemAttributes.frame.size.height);
            
            cellLayoutInfo[indexPath] = itemAttributes;
            lastItem = itemAttributes;
        }
        
        CGFloat bottomSize = 0.0f;//(section == 0) ? 0.0f : attr.frame.size.height;
        //NSLog(@"last itemAttributes.frame: %f, %f, %f, %f", lastItem.frame.origin.x, lastItem.frame.origin.y, lastItem.frame.size.width, lastItem.frame.size.height);
        top = lastItem.frame.origin.y + lastItem.frame.size.height + bottomSize;
        contentHeight = top;
        //izeOfContent = CGSizeMake(self.collectionView.frame.size.width, top);
        //NSLog(@"contentHeight: %f", contentHeight);
    
    }
    
    _contensSize = CGSizeMake(self.collectionView.frame.size.width, contentHeight);
    _layoutInfo = [NSDictionary dictionaryWithDictionary:cellLayoutInfo];
    _headerRect = [NSDictionary dictionaryWithDictionary:headerLayoutInfo];
    
}

#pragma mark - Private

//-(CGRect)frameForAlbumTitleAtIndexPath:(NSIndexPath*)indexPath{
//    return CGRectMake(0, 0, self.collectionView.frame.size.width, self.headerViewHeight);
//}

-(CGRect)frameForCellAtIndexPath:(NSIndexPath*)indexPath withCellTopPosition:(CGFloat)topPosition{
        
//    if(indexPath.item == 0) //hide first item because it is showed in headerView
//        return CGRectZero;
    
    NSInteger numberOfColumns = self.numberOfColumns;
    CGFloat cellWidth = self.itemSize.width;
    CGFloat cellHeight = self.itemSize.height;
    
    if(IS_IPAD && indexPath.section == 1){
        numberOfColumns = 2;
        CGFloat screenSize = self.collectionView.frame.size.width;
        cellWidth = screenSize / 2;
    }
    
    NSInteger row = (indexPath.row) / numberOfColumns; //shift items to zero item
    NSInteger column = (indexPath.row) % numberOfColumns; //shift items to zero item
    
    CGFloat spacingX = self.collectionView.bounds.size.width -
                        self.itemInsets.left -
                        self.itemInsets.right -
                        (numberOfColumns * cellWidth);
    
    if (numberOfColumns > 1) spacingX = spacingX / (numberOfColumns - 1);
    
    CGFloat originX = floorf(self.itemInsets.left + (cellWidth + spacingX) * column);
    CGFloat originY = floor(topPosition + self.itemInsets.top + self.sectionInset.top +
                        (cellHeight + self.interItemSpacingY) * row);
    
    //NSLog(@"row = %i, column = %i, spacX = %f, {%f,%f}", row, column, spacingX, originX, originY);
    return CGRectMake(originX, originY, cellWidth, cellHeight);
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

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

-(CGSize)collectionViewContentSize{
    
//    NSInteger sectionCount = [self.collectionView numberOfSections];
//    CGFloat totalHeight = 0.0f;
//    
//    for(NSInteger section = 0; section < sectionCount; section++){
//    
//        NSInteger rowCount = ([self.collectionView numberOfItemsInSection:section] - 0) / self.numberOfColumns;
//    
//        // make sure we count another row if one is only partially filled
//        if (([self.collectionView numberOfItemsInSection:section] - 0) % self.numberOfColumns) rowCount++;
//        //NSLog(@"Number of rows: %ld, %ld", [self.collectionView numberOfItemsInSection:0], rowCount);
//
//    
//        CGFloat height = self.headerViewHeight + self.itemInsets.top +
//                     rowCount * self.itemSize.height +
//                     rowCount * self.interItemSpacingY +
//                     self.sectionInset.bottom;
//        
//        totalHeight += height;
//    
//    }
//    return CGSizeMake(self.collectionView.bounds.size.width, totalHeight);
    return _contensSize;
}

@end
