//
//  ViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "PlaceMapViewController.h"
#import "UIUserSettings.h"
#import "RateView.h"
#import "SingletonMap.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "AppDelegate.h"


//#import "UIViewController+MMDrawerController.h"
//#import "MMDrawerBarButtonItem.h"
//#import "LeftSideBarViewController.h"

@interface PlaceMapViewController (){
    UIUserSettings *_userSettings;
    CLLocationManager *locationManager;
    RMMapView* _map;
    BOOL opened;
}

@end

@implementation PlaceMapViewController

bool openedCallout = false;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kReceiveRemoteNotification
                                               object:appDelegate];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveRemoteNotification object:nil];
}
- (void)viewDidLoad {
    
    _userSettings = [[UIUserSettings alloc] init];
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self setNavBarButtons];
    
    locationManager = [[CLLocationManager alloc] init];
    _map = [SingletonMap instance].map;
    _map.frame = self.view.frame;
    [self.mapView addSubview:_map];
    if ([[_map.tileSource shortName]  isEqual: @"Mapbox iOS Example"]) {
        _map.tileSource = [[RMMBTilesSource alloc] initWithTileSetResource:@"tiles" ofType:@"mbtiles"];
    }
    _map.delegate = self;
    [self deleteAllMarkersFrom:_map];
    
    RMAnnotation *annotation = [RMAnnotation  annotationWithMapView:_map
                                                         coordinate:CLLocationCoordinate2DMake([self.mapPlace.lattitude doubleValue], [self.mapPlace.longitude doubleValue])
                                                           andTitle:self.mapPlace.name];
    annotation.userInfo = self.mapPlace;
    [_map addAnnotation:annotation];
    NSLog(@"annotation = %@",annotation);
    _map.zoom = 15;
    _map.centerCoordinate = annotation.coordinate;
    
    _map.showsUserLocation = YES;
    
    NSLog(@"self.mapPlace = %@", self.mapPlace);

}

- (void)viewDidAppear:(BOOL)animated {

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
    if (openedCallout == false) {
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
    }
    
}

- (void)addCustomAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map {
    if (![annotation isUserLocationAnnotation]) {
        Places *place = annotation.userInfo;
        
        UIView *callout = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 306, 100)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 86, 86)];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, place.photo_small];
        NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [imageView setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"no_photo"]];
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
        openedCallout = true;
    }
}

- (void)deleteCustomAnnotation:(RMMapView *)map {
    for (RMAnnotation *annotation in map.annotations) {
        if (![annotation isUserLocationAnnotation])
            annotation.layer.sublayers = nil;
        openedCallout = false;
    }
}

- (void)deleteAllMarkersFrom:(RMMapView *)map {
    for (RMAnnotation *annotation in map.annotations) {
        if (![annotation isUserLocationAnnotation])
            annotation.layer = nil;
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
        stringDistance =@"500 м";
    }
    else {
        distance = ceil(distance/100)/10;
        stringDistance = [NSString stringWithFormat:@"%.1f км",distance];
    }
    
    return stringDistance;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    // ====== setup right nav button ======
    //self.navigationItem.rightBarButtonItem = [_userSettings setupRightButtonItem:self];
    
    // ====== setup navbar color ===========
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button =====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    self.navigationItem.title = self.mapPlace.name;
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //    if([[segue identifier] isEqualToString:@"segueFromCategoryToSubcategory"]){
    //        SubCategoryCollectionViewController *subVC = (SubCategoryCollectionViewController*)[segue destinationViewController];
    //        AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    //        NSIndexPath *idx = (NSIndexPath*)sender;
    //        subVC.navigationItem.title = appDelegate.testArray[idx.item];
    //
    //    }
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
