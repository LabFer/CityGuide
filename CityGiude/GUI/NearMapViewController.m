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
#import "MapFilterViewController.h"
#import "AppDelegate.h"

#define MAX_RANGE 5000

@implementation NearMapViewController{
    UIUserSettings *_userSettings;
    CLLocationManager *locationManager;
    NSString *_sortKeys;
    BOOL opened;
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kReceiveRemoteNotification
                                               object:appDelegate];
    
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
    [self createPlaceList];
    
    // ====== mmdrawer swipe gesture =======
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveRemoteNotification object:nil];
}


-(void)viewDidLoad{
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    
    _sortKeys = @"promoted,sort,name";
    //self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:_sortKeys predicate:nil sectionName:nil delegate:self];
    
    self.filterDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    double minLat = NAN, maxLat = NAN, minLong = NAN, maxLong = NAN;
    
    NSLog(@"viewDidAppear. before delete map.annotations: %lu", (unsigned long)self.mapView.annotations.count);
    //[self deleteAllMarkersFrom:self.mapView];
    [self.mapView removeAllAnnotations];
    NSLog(@"viewDidAppear. after delete map.annotations: %lu", (unsigned long)self.mapView.annotations.count);
    //[self deleteCustomAnnotation:self.mapView];
    NSLog(@"viewDidAppear: %lu", (unsigned long)self.frcPlaces.count);
    for (Places *place in self.frcPlaces) {
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

- (void)deleteCustomAnnotation:(RMMapView *)map {
    for (RMAnnotation *annotation in map.annotations) {
        if (![annotation isUserLocationAnnotation])
            annotation.layer.sublayers = nil;
        opened = false;
    }
}

- (void)deleteAllMarkersFrom:(RMMapView *)map {
    NSLog(@"deleteAllMarkersFrom");
    for (RMAnnotation *annotation in map.annotations) {
        if (![annotation isUserLocationAnnotation]){
            //map removeA
            annotation.layer = nil;
            NSLog(@"annotation.layer = nil;");
        }
        opened = false;
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
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    
    
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
        //[self performSegueWithIdentifier:@"segueFromHouseToHouseDetail" sender:[target valueForKey:@"place"]];
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
        
        RateView *rateView = [[RateView alloc] initWithFrame:CGRectMake(106, 78, 80, 15)];
        rateView.notSelectedImage = [UIImage imageNamed:@"star_grey"];
        //self.rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
        rateView.fullSelectedImage = [UIImage imageNamed:@"star_yellow"];
        rateView.rating = place.rate.floatValue;
        rateView.editable = NO;
        rateView.maxRating = 5;
        [callout addSubview:rateView];

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
    else if([[segue identifier] isEqualToString:@"segueFromMapNearToFilterNear"]){
        MapFilterViewController *vc = (MapFilterViewController*)[segue destinationViewController];
        vc.delegate = self;
        vc.filterDictionary = self.filterDictionary;
    }
}

-(void)createPlaceList{
    
    NSFetchedResultsController *frc = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:_sortKeys predicate:nil sectionName:nil delegate:self];;
    
    _sortKeys = @"promoted,sort,name";
    
    NSSortDescriptor *sortDescriptorPromoted = [[NSSortDescriptor alloc] initWithKey:@"promoted" ascending:NO];
    NSSortDescriptor *sortDescriptorSort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray* sortKeys = @[sortDescriptorPromoted, sortDescriptorSort, sortDescriptorName];
    
    //if(self.aCategory){ //need to apply filters
        if(self.filterDictionary.count == 0){

            self.frcPlaces = [[frc fetchedObjects] sortedArrayUsingDescriptors:sortKeys];
        }
        else{
            NSMutableArray *subPredicates = [[NSMutableArray alloc] initWithCapacity:0];
            for(id key in self.filterDictionary) {
                id value = [self.filterDictionary objectForKey:key];
                
                if([value isKindOfClass:[NSNumber class]]){
                    NSNumber *filterValue = (NSNumber*)value;
                    if(filterValue.integerValue == 0){ // if YES
                        if([key isEqualToString:kFilterAllTime]){
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"work_time_end == 86400 AND work_time_start == 0"];
                            [subPredicates addObject:p];
                        }
                        else if([key isEqualToString:kFilterWebsiteExists]){
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"website != nil AND website != '' AND website != 'None'"];
                            [subPredicates addObject:p];
                        }
                        else if([key isEqualToString:kFilterWorkNow]){
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"work_time_end >= %@ AND work_time_start <= %@", [self getCurrentTimeInSeconds], [self getCurrentTimeInSeconds]];
                            [subPredicates addObject:p];
                        }
                        else{
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"SUBQUERY(attributes, $attr, $attr.name == %@).@count>0", key];
                            [subPredicates addObject:p];
                        }
                    } // end if YES
                    else if(filterValue.integerValue == 1){ // if NOT IMPORTANT
                        
                    }// end if NOT IMPORTANT
                    else if(filterValue.integerValue == 2){ // if NO
                        if([key isEqualToString:kFilterAllTime]){
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"NOT(work_time_end == 86400 AND work_time_start == 0)"];
                            [subPredicates addObject:p];
                            
                        }
                        else if([key isEqualToString:kFilterWebsiteExists]){
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"NOT(website != nil AND website != '' AND website != 'None')"];
                            [subPredicates addObject:p];
                        }
                        else if([key isEqualToString:kFilterWorkNow]){
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"NOT(work_time_end >= %@ AND work_time_start <= %@)", [self getCurrentTimeInSeconds], [self getCurrentTimeInSeconds]];
                            [subPredicates addObject:p];
                        }
                        else{
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"NOT(SUBQUERY(attributes, $attr, $attr.name != %@).@count>0)", key];
                            [subPredicates addObject:p];
                        }
                    }// end if NO
                    
                    
                } else if([key isEqualToString:@"searchTerms"]){
                    NSArray *searchTerms = value;//[value componentsSeparatedByString:@","];

                    for (NSString *term in searchTerms) {
                            
                        NSPredicate *p = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (decript contains[cd] %@) OR (SUBQUERY(keys, $key, $key.name contains[cd] %@).@count>0)", term, term, term];
                        [subPredicates addObject:p];
                    }
                }
                
                //NSLog(@"key: %@; value: %@", key, value);
                //[value doStuff];
            }
            
            NSPredicate *pred = [NSCompoundPredicate  andPredicateWithSubpredicates:subPredicates];
            NSLog(@"Filter predicate: %@", pred);
            
            self.frcPlaces = [[[frc fetchedObjects] filteredArrayUsingPredicate:pred] sortedArrayUsingDescriptors:sortKeys];
            
        }
//    }
//    else{ // show all places
//        frc = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:_sortKeys predicate:nil sectionName:nil delegate:self];
//        self.frcPlaces = [[frc fetchedObjects] sortedArrayUsingDescriptors:sortKeys];
//    }
    
    NSLog(@"NearMapController. filterDiscionary: %@", self.filterDictionary);
    NSLog(@"self.frcPlaces count: %lu", (unsigned long)self.frcPlaces.count);
    
}

#pragma mark - Time Converter
-(NSNumber*)getMinutes:(NSNumber*)totalSeconds{
    int minutes = (totalSeconds.intValue / 60) % 60;
    return [NSNumber numberWithInt:minutes];
}

-(NSNumber*)getHours:(NSNumber*)totalSeconds{
    //    int seconds = totalSeconds.intValue % 60;
    //    int minutes = (totalSeconds.intValue / 60) % 60;
    int hours = totalSeconds.intValue / 3600;
    return [NSNumber numberWithInt:hours];
}

-(NSNumber*)getCurrentMinutes{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *time = [NSNumber numberWithDouble:currentTime];
    int minutes = (time.intValue / 60) % 60;
    return [NSNumber numberWithInt:minutes];
    
}

-(NSNumber*)getCurrentHour{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970]; //number of seconds
    NSNumber *time = [NSNumber numberWithDouble:currentTime];
    int hours = time.intValue / 3600;
    return [NSNumber numberWithInt:hours];
}

-(NSNumber*)getCurrentTimeInSeconds{
    
    // In practice, these calls can be combined
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *hourComponents = [calendar components:NSHourCalendarUnit fromDate:now];
    NSDateComponents *minuteComponents = [calendar components:NSMinuteCalendarUnit fromDate:now];
    
    NSInteger currentTimeInSeconds = [minuteComponents minute]*60 + [hourComponents hour]*60*60;
    //NSLog(@"currentTimeInSeconds: %ld", (long)currentTimeInSeconds);
    return [NSNumber numberWithInteger:currentTimeInSeconds];
}

#pragma mark - Push Notification
-(void)didReceiveRemoteNotification:(NSNotification *)notification {
    // see http://stackoverflow.com/a/2777460/305149
    if (self.isViewLoaded && self.view.window) {
        // handle the notification
        [_userSettings showPushView:notification.userInfo inViewController:self];
    }
}

@end
