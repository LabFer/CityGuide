//
//  SubCategoryCollectionViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 11/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categories.h"

@interface SubCategoryCollectionViewController : UICollectionViewController <UICollectionViewDelegate>

@property (nonatomic, strong) Categories *aCategory;

@end
