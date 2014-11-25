//
//  SubCategoryCollectionViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 11/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categories.h"
#import "SubCategoryListFlowLayout.h"
#import "SubCategoryTileFlowLayout.h"

@interface SubCategoryCollectionViewController : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) Categories *aCategory;
@property (nonatomic, strong) NSFetchedResultsController *frcCategories;

@end
