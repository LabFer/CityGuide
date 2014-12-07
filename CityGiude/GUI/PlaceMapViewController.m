//
//  ViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "PlaceMapViewController.h"
#import "UIUserSettings.h"


#import "AppDelegate.h"


//#import "UIViewController+MMDrawerController.h"
//#import "MMDrawerBarButtonItem.h"
//#import "LeftSideBarViewController.h"

@interface PlaceMapViewController (){
    UIUserSettings *_userSettings;
    CLLocationManager *locationManager;
}

@end

@implementation PlaceMapViewController

bool openedCallout = false;

- (void)viewDidLoad {
    
    _userSettings = [[UIUserSettings alloc] init];
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    [self setNavBarButtons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"mapbox" ofType:@"json"];
    NSError *error;
    NSString* tileJSON = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    self.mapView.tileSource = [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    RMAnnotation *annotation = [RMAnnotation  annotationWithMapView:self.mapView
                                                         coordinate:CLLocationCoordinate2DMake([self.mapPlace.lattitude doubleValue], [self.mapPlace.longitude doubleValue])
                                                           andTitle:self.mapPlace.name];
    annotation.userInfo = self.mapPlace;
    [self.mapView addAnnotation:annotation];
    CLLocationCoordinate2D centerCoordinate = annotation.coordinate;
    self.mapView.centerCoordinate = centerCoordinate;
    self.mapView.zoom = 15;
    self.mapView.showsUserLocation = YES;
    locationManager = [[CLLocationManager alloc] init];
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
    
    Places *place = annotation.userInfo;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    calloutViewController *callout    = [[calloutViewController alloc] init];
    callout = [storyboard instantiateViewControllerWithIdentifier:@"calloutViewController"];
    [self.view addSubview:callout.view];
    [callout.name setText:place.name];
    callout.address.text = place.address;
    callout.distance.text = [self getDistanceFromUserLocationTo:[[CLLocation alloc] initWithLatitude:[place.lattitude doubleValue] longitude:[place.longitude doubleValue]]];
    
    SMCalloutView *smcallout = [[SMCalloutView alloc] init];
    smcallout.contentView = callout.view;
    smcallout.contentView.frame = CGRectMake(0, 0, 300, 115);
    smcallout.calloutOffset = CGPointMake(9, -1);
    
    [smcallout presentCalloutFromRect:smcallout.bounds inLayer:annotation.layer constrainedToLayer:map.layer animated:YES];
    NSLog(@"annotation clicked: %@",annotation.layer);
    [annotation.layer setValue:@"customCallout" forKey:@"calloutTag"];
    [annotation.layer setValue:place forKey:@"place"];
    openedCallout = true;
}

- (void)deleteCustomAnnotation:(RMMapView *)map {
    for (RMAnnotation *annotation in map.annotations) {
        annotation.layer.sublayers = nil;
        openedCallout = false;
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

@end
