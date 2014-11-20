//
//  HouseViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 11/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "PlaceViewController.h"
#import "PlaceDetailViewController.h"
#import "UIUserSettings.h"
#import "AppDelegate.h"
#import "PlaceListCell.h"
#import "DBWork.h"
#import "Places.h"
#import "calloutViewController.h"
#define kMapboxMapID  @"bboytx.k5gobg2j"

@implementation PlaceViewController{
    UIUserSettings *_userSettings;
}

@synthesize mapView;
@synthesize tileCache;

-(void)viewDidLoad{

    [super viewDidLoad];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self in %@", self.aCategory.places];
    NSLog(@"Places predicate: %@", predicate);
    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:@"sort" predicate:predicate sectionName:nil delegate:self];

    self.placeTableView.backgroundColor = [UIColor whiteColor];
    self.placeTableView.delegate = self;
    self.placeTableView.dataSource = self;
    
    self.listMapButtonView.backgroundColor = kDefaultNavBarColor;
    
    _userSettings = [[UIUserSettings alloc] init];
    [self setNavBarButtons];
    
    self.mapView.hidden = YES;
    self.mapView.tileSource = [[RMMapboxSource alloc] initWithMapID:kMapboxMapID];
    [self.mapView.tileSource setCacheable:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
       double minLat = NAN, maxLat = NAN, minLong = NAN, maxLong = NAN;
    
    for (Places *place in self.frcPlaces.fetchedObjects) {
        
        if ((minLat == NAN) || (maxLat = NAN) || (minLong == NAN) || (maxLong == NAN)) {
            minLat = [place.lattitude doubleValue];
            maxLat = minLat;
            minLong = [place.longitude doubleValue];
            maxLong = minLong;
        }
        else {
            if (minLat > [place.lattitude doubleValue]) minLat = [place.lattitude doubleValue];
            if (maxLat < [place.lattitude doubleValue]) maxLat = [place.lattitude doubleValue];
            if (minLong > [place.longitude doubleValue]) minLat = [place.longitude doubleValue];
            if (maxLong < [place.longitude doubleValue]) maxLat = [place.longitude doubleValue];
        }
        
        RMAnnotation *annotation = [RMAnnotation annotationWithMapView:self.mapView
                                                            coordinate:CLLocationCoordinate2DMake([place.lattitude doubleValue], [place.longitude doubleValue])
                                                              andTitle:place.name];
        [self.mapView addAnnotation:annotation];
    }
    __weak RMMapView *weakMap = self.mapView; // avoid block-based memory leak
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
                   {
                       RMSphericalTrapezium zoomBounds = {
                           .southWest = {
                               .latitude  = minLat-0.1,
                               .longitude = minLong-0.1
                           },
                           .northEast = {
                               .latitude  = maxLat+0.1,
                               .longitude = maxLong+0.1
                           }
                       };
                       
                       [weakMap zoomWithLatitudeLongitudeBoundsSouthWest:zoomBounds.southWest
                                                               northEast:zoomBounds.northEast
                                                                animated:YES];
                   });
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
    
    //    LeftSideBarViewController *lc =  (LeftSideBarViewController *)self.mm_drawerController.leftDrawerViewController;
    //    lc.previousDisplayMode = UICatalog;
    //
    //    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_left_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(leftDrawerButtonPress:)];
    //    leftDrawerButton.tintColor = [UIColor grayColor];
    //
    //    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    //
    //    self.navigationController.navigationBar.topItem.title = kAppMainTitle;
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupFilterButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button =====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.title = self.aCategory.name;
    
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)filterButtonPressed{
    NSLog(@"filterButtonPressed");
}

- (IBAction)buttonListPressed:(id)sender {
    self.placeTableView.hidden = NO;
    self.mapView.hidden = YES;
    [self setupHousePresentationMode];
}

- (IBAction)buttonMappPressed:(id)sender {
    self.placeTableView.hidden = YES;
    self.mapView.hidden = NO;
    [self setupHousePresentationMode];
}

-(void)setupHousePresentationMode{
    
    if(self.placeTableView.hidden){
        //NSLog(@"self.houseListCollectionView.hidden = YES");
        [self.buttonMap setBackgroundImage:[UIImage imageNamed:@"house_white_btn_right"] forState:UIControlStateNormal];
        [self.buttonList setBackgroundImage:[UIImage imageNamed:@"house_blue_btn_left"] forState:UIControlStateNormal];
        [self.buttonList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.buttonMap setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else{
        //NSLog(@"self.houseListCollectionView.hidden = NO");
        [self.buttonMap setBackgroundImage:[UIImage imageNamed:@"house_blue_btn_right"] forState:UIControlStateNormal];
        [self.buttonList setBackgroundImage:[UIImage imageNamed:@"house_white_btn_left"] forState:UIControlStateNormal];
        [self.buttonList setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.buttonMap setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.frcPlaces.fetchedObjects count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 115.0f;
}
#pragma mark - TableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    PlaceListCell *cell = [self.placeTableView dequeueReusableCellWithIdentifier:[PlaceListCell reuseId]];
  
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(PlaceListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Places *place = self.frcPlaces.fetchedObjects[indexPath.row];
    [cell.titleLabel setText:place.name];
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.placeTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //NSLog(@"Item selected: %@", self.frcPlaces.fetchedObjects[indexPath.row]);
    [self performSegueWithIdentifier:@"segueFromHouseToHouseDetail" sender:indexPath];

}


#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
        if([[segue identifier] isEqualToString:@"segueFromHouseToHouseDetail"]){
            PlaceDetailViewController *placeVC = (PlaceDetailViewController*)[segue destinationViewController];
            //AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            NSIndexPath *idx = (NSIndexPath*)sender;
            placeVC.aPlace = self.frcPlaces.fetchedObjects[idx.row];
            
            //subVC.navigationItem.title = appDelegate.testArray[idx.item];
            
        }
}

@end
