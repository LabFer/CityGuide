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
#import "Mapbox.h"


@interface PlaceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>





@property (strong) NSObject <RMTileCacheBackgroundDelegate> *tileCache;

@property (strong) IBOutlet RMMapView *mapView;

@property (weak, nonatomic) IBOutlet UIButton *buttonList;
@property (weak, nonatomic) IBOutlet UIButton *buttonMap;

@property (weak, nonatomic) IBOutlet UITableView *placeTableView;

@property (weak, nonatomic) IBOutlet UIView *listMapButtonView;
@property (nonatomic, strong) NSFetchedResultsController *frcPlaces;
@property (nonatomic, strong) Categories *aCategory;

- (IBAction)buttonListPressed:(id)sender;
- (IBAction)buttonMappPressed:(id)sender;

@end
