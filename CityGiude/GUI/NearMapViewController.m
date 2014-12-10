//
//  NearMapViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 23/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "NearMapViewController.h"
#import "PlaceDetailViewController.h"
#import "UIUserSettings.h"
#import "DBWork.h"
#import "Places.h"
#import "Constants.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuTableViewController.h"

#define MAX_RANGE 5000

@implementation NearMapViewController{
    UIUserSettings *_userSettings;
    CLLocationManager *locationManager;
    NSString *_sortKeys;
    BOOL opened;
}

-(void)viewWillAppear:(BOOL)animated {
    opened = false;
    locationManager = [[CLLocationManager alloc] init];
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"mapbox" ofType:@"json"];
    NSError *error;
    NSString* tileJSON = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    self.mapView.tileSource = [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    
    [self.mapView.tileSource setCacheable:YES];
    
    self.mapView.showsUserLocation = YES;
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate];
    __weak RMMapView *weakMap = self.mapView; // avoid block-based memory leak
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
                   {
                       weakMap.zoom = 15;
                       [weakMap setCenterCoordinate:self.mapView.userLocation.location.coordinate];
                   });
    
    NSLog(@"User location is %@",self.mapView.userLocation.location);
}

-(void)viewDidLoad{
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    
    _sortKeys = @"promoted,sort,name";
    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:_sortKeys predicate:nil sectionName:nil delegate:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    double minLat = NAN, maxLat = NAN, minLong = NAN, maxLong = NAN;
    
    for (Places *place in self.frcPlaces.fetchedObjects) {
        if ([locationManager.location distanceFromLocation:[[CLLocation alloc] initWithLatitude:[place.lattitude doubleValue] longitude:[place.longitude doubleValue]]] < MAX_RANGE) {
            //NSLog(@"Place from Coredata: %@",place);
            if ((minLat == NAN) || (maxLat = NAN) || (minLong == NAN) || (maxLong == NAN)) {
                minLat = [place.lattitude doubleValue];
                maxLat = minLat;
                minLong = [place.longitude doubleValue];
                maxLong = minLong;
            }
            else {
                if (minLat > [place.lattitude doubleValue]) {minLat = [place.lattitude doubleValue]; NSLog(@"minLat = %f",minLat);};
                if (maxLat < [place.lattitude doubleValue]) {maxLat = [place.lattitude doubleValue]; NSLog(@"maxLat = %f",maxLat);};
                if (minLong > [place.longitude doubleValue]) {minLong = [place.longitude doubleValue]; NSLog(@"minLat = %f",minLong);};
                if (maxLong < [place.longitude doubleValue]) {maxLong = [place.longitude doubleValue]; NSLog(@"maxLong = %f",maxLong);};
   
            
            }
            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:self.mapView
                                                                coordinate:CLLocationCoordinate2DMake([place.lattitude doubleValue], [place.longitude doubleValue])
                                                                  andTitle:place.name];
            annotation.userInfo = place;
            [self.mapView addAnnotation:annotation];
        }
    }
    
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupFilterButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuDrawerButtonPress:)];
    leftDrawerButton.tintColor = kDefaultNavItemTintColor;//[UIColor blueColor];
    
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    self.navigationItem.title = kNavigationTitleMapNear;
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    
}

-(void)menuDrawerButtonPress:(id)sender{
    
    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)filterButtonPressed{
    [self performSegueWithIdentifier:@"segueFromMapNearToFilterNear" sender:self];
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation) return nil;
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker" ]];
    marker.canShowCallout = NO;
    NSLog(@"Annotation marker is changed");
    return marker;
}

- (void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
    if (opened == false) {
        [self addCustomAnnotation:annotation onMap:map];
    }
    else {
        [self deleteCustomAnnotation:map];
        [self addCustomAnnotation:annotation onMap:map];
    }
}

- (void)singleTapOnMap:(RMMapView *)map at:(CGPoint)point {
    CALayer *target = [map.layer hitTest:point];
    // target is the layer that was tapped
    if ([target isKindOfClass:[CAScrollLayer class]]) { //if ta
        [self deleteCustomAnnotation:map];
    }
    else {
        while (![[target valueForKey:@"calloutTag"]  isEqual: @"customCallout"]) {
            target = target.superlayer;
        }
        NSLog(@"Place : %@",[target valueForKey:@"place"]);
        [self performSegueWithIdentifier:@"segueFromHouseToHouseDetail" sender:[target valueForKey:@"place"]];
    }
    
}

- (void)addCustomAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
    if (![annotation isUserLocationAnnotation]) {
        Places *place = annotation.userInfo;
        
        UIView *callout = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 306, 100)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 86, 86)];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, place.photo_small];
        NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [imageView setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"photo"]];
        [callout addSubview:imageView];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(106, 7, 138, 35)];
        name.adjustsFontSizeToFitWidth = NO;
        name.numberOfLines = 2;
        [name setText:place.name];
        [name setFont:[UIFont fontWithName:@"HelveticaNeue" size:15]];
        [callout addSubview:name];
        
        UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(106, 42, 138, 34)];
        address.adjustsFontSizeToFitWidth = NO;
        address.numberOfLines = 2;
        address.textColor = [UIColor darkGrayColor];
        [address setText:place.address];
        [address setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [callout addSubview:address];
        
        UIImageView *posMarkerView = [[UIImageView alloc] initWithFrame:CGRectMake(219, 78, 10, 15)];
        [posMarkerView setImage:[UIImage imageNamed:@"house_map_marker"]];
        [callout addSubview:posMarkerView];
        
        UIImageView *cellIndicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(284, 44, 8, 13)];
        [cellIndicatorView setImage:[UIImage imageNamed:@"cell_indicator"]];
        [callout addSubview:cellIndicatorView];
        
        UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(232, 76, 60, 17)];
        distance.adjustsFontSizeToFitWidth = NO;
        distance.numberOfLines = 1;
        [distance setText:[self getDistanceFromUserLocationTo:[[CLLocation alloc] initWithLatitude:[place.lattitude doubleValue] longitude:[place.longitude doubleValue]]]];
        [distance setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        [callout addSubview:distance];
        
        SMCalloutView *smcallout = [[SMCalloutView alloc] init];
        smcallout.contentView = callout;
        
        [smcallout presentCalloutFromRect:annotation.layer.bounds inLayer:annotation.layer constrainedToLayer:map.layer animated:YES];
        
        NSLog(@"annotation clicked: %@",annotation.layer);
        [annotation.layer setValue:@"customCallout" forKey:@"calloutTag"];
        [annotation.layer setValue:place forKey:@"place"];
        opened = true;
    }
}

- (void)deleteCustomAnnotation:(RMMapView *)map {
    for (RMAnnotation *annotation in map.annotations) {
        if (![annotation isUserLocationAnnotation])
            annotation.layer.sublayers = nil;
        opened = false;
    }
}

-(NSString *)getDistanceFromUserLocationTo:(CLLocation *)coordinate {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    CLLocationDistance distance = [locationManager.location distanceFromLocation:coordinate];
    NSString *stringDistance;
    if (distance<1000) {
        distance = ceil(distance/100)*100;
        stringDistance = [NSString stringWithFormat:@"%.0f м",distance];
    }
    else {
        distance = ceil(distance/100)/10;
        stringDistance = [NSString stringWithFormat:@"%.1f км",distance];
    }
    
    return stringDistance;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromHouseToHouseDetail"]){
        PlaceDetailViewController *placeVC = (PlaceDetailViewController*)[segue destinationViewController];
        //AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        //NSIndexPath *idx = (NSIndexPath*)sender;
        placeVC.aPlace = (Places*)sender;
        
        //subVC.navigationItem.title = appDelegate.testArray[idx.item];
        
    }
}

@end
