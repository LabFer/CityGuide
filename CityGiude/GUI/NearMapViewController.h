//
//  NearMapViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 23/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Categories.h"
#import "SMCalloutView.h"
#import "Mapbox.h"
#import "RateView.h"

@interface NearMapViewController : UIViewController <CLLocationManagerDelegate, SMCalloutViewDelegate, RMMapViewDelegate>

@property (strong) IBOutlet RMMapView *mapView;

@property (nonatomic, strong) NSFetchedResultsController *frcPlaces;
@property (nonatomic, strong) Categories *aCategory;

@end
