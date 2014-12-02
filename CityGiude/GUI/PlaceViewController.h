//
//  HouseViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 11/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Categories.h"
#import "SMCalloutView.h"
#import "Mapbox.h"
#import "RateView.h"


@interface PlaceViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, SMCalloutViewDelegate>

@property (strong) NSObject <RMTileCacheBackgroundDelegate> *tileCache;

@property (strong) IBOutlet RMMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *buttonList;
@property (weak, nonatomic) IBOutlet UIButton *buttonMap;

@property (weak, nonatomic) IBOutlet UICollectionView *placeCollectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;

@property (weak, nonatomic) IBOutlet UIView *listMapButtonView;
@property (nonatomic, strong) NSFetchedResultsController *frcPlaces;
@property (nonatomic, strong) Categories *aCategory;
- (IBAction)segmentValueChanged:(id)sender;

- (IBAction)buttonListPressed:(id)sender;
- (IBAction)buttonMappPressed:(id)sender;

@end
