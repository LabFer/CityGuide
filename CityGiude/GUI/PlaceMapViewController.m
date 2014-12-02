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
}

@end

@implementation PlaceMapViewController

@synthesize mapView;

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
    [self.mapView addAnnotation:annotation];
    
//    __weak RMMapView *weakMap = self.mapView; // avoid block-based memory leak
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
//                   {
                       float degreeRadius = 9000.f / 110000.f; // (9000m / 110km per degree latitude)
                       
                       CLLocationCoordinate2D centerCoordinate = annotation.coordinate;
                       
                       RMSphericalTrapezium zoomBounds = {
                           .southWest = {
                               .latitude  = centerCoordinate.latitude  - degreeRadius,
                               .longitude = centerCoordinate.longitude - degreeRadius
                           },
                           .northEast = {
                               .latitude  = centerCoordinate.latitude  + degreeRadius,
                               .longitude = centerCoordinate.longitude + degreeRadius
                           }
                       };
                       
                       [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:zoomBounds.southWest
                                                                    northEast:zoomBounds.northEast
                                                                     animated:YES];
//                   });
    
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    
    if (annotation.isUserLocationAnnotation)
        return nil;
    
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker" ]];
    
    marker.canShowCallout = YES;
    
    //    NSLog(@"Annotation marker is changed");
    //
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    calloutViewController* callout = [storyboard instantiateViewControllerWithIdentifier:@"calloutViewController"];
    //
    //    NSLog(@"callout: %@",callout.view);
    //
    //
    //    marker.leftCalloutAccessoryView = callout.view;
    
    return marker;
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
