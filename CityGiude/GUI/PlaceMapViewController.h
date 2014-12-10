//
//  ViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mapbox.h"
#import "Places.h"
#import "calloutViewController.h"
#import "SMCalloutView.h"

@interface PlaceMapViewController : UIViewController <UICollectionViewDelegate, SMCalloutViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet RMMapView *mapView;
@property (strong, nonatomic) Places *mapPlace;


@end

