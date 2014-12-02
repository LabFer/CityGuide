//
//  FavourViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 23/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FavourPlaceListCell.h"
#import "FavourCategoryCell.h"

@interface FavourViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, FavourPlaceListCellDelegate, FavourCategoryListCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *listCollectionView;
@property (nonatomic, strong) NSFetchedResultsController *frcPlaces;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)segmentValueChanged:(id)sender;

@end
