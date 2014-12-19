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
#import "SubCategoryListFlowLayout.h"
#import "FilterViewController.h"

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"

@implementation PlaceViewController{
    UIUserSettings *_userSettings;
    NSString *_sortKeys;
    CLLocationManager *locationManager;
}

bool opened = false;

-(void)viewWillAppear:(BOOL)animated {
    
    [self createMap];
    [self.placeCollectionView reloadData];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    SubCategoryListFlowLayout *layout = [[SubCategoryListFlowLayout alloc] init];
    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width;
    layout.itemSize = CGSizeMake(sizeOfItems, 115.0f); //size of each cell
    layout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 115.0f, 0.0f);
    [self.placeCollectionView setCollectionViewLayout:layout];
    
    
//    NSPredicate *predicate = nil;
//    if(self.aCategory)
//        predicate = [NSPredicate predicateWithFormat:@"self in %@", self.aCategory.places];
//    _sortKeys = @"promoted,sort,name";
//    //NSLog(@"Places predicate: %@", predicate);
//    
//    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:_sortKeys predicate:predicate sectionName:nil delegate:self];
    self.filterDictionary = [NSDictionary dictionary];
    [self createPlaceList];
    self.placeCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.listMapButtonView.backgroundColor = kDefaultButtonBarColor;
    
    _userSettings = [[UIUserSettings alloc] init];
    
    // ===== UISegmentedControl ====
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [self.segmentController setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    [self setupHousePresentationMode];
    
    [self setNavBarButtons];
    
   
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");
    
    double minLat = NAN, maxLat = NAN, minLong = NAN, maxLong = NAN;
    
    for (Places *place in self.frcPlaces) { //self.frcPlaces.fetchedObjects
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

#pragma mark - RMMapBox

-(void)createMap{
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
    
    //NSLog(@"User location is %@",self.mapView.userLocation.location);
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    if (annotation.isUserLocationAnnotation) return nil;
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker" ]];
    marker.canShowCallout = NO;
    //NSLog(@"Annotation marker is changed");
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupFilterButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    if(self.aCategory){
    
        self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button =====
        self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    }
    else{
        MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuDrawerButtonPress:)];
        leftDrawerButton.tintColor = kDefaultNavItemTintColor;//[UIColor blueColor];
        self.navigationItem.leftBarButtonItem = leftDrawerButton;
    }
    
    self.navigationItem.title = (self.aCategory) ? self.aCategory.name : kNavigationTitlePlace;
    
    // ===== remove shadow =====
}

-(void)menuDrawerButtonPress:(id)sender{

    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];

}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)filterButtonPressed{
    if(self.aCategory){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        FilterViewController* auth = [storyboard instantiateViewControllerWithIdentifier:@"FilterViewController"];
        auth.delegate = self;
        auth.aCategory = self.aCategory;
        
        auth.filterDictionary = [[NSMutableDictionary alloc] initWithDictionary:self.filterDictionary];
        [self presentViewController:auth animated:YES completion:nil];
        //[self performSegueWithIdentifier:@"segueFromPlaceViewToFilterView" sender:self];
    }
}

#pragma mark - Button Handlers

- (IBAction)segmentValueChanged:(id)sender {
    
    [self setupHousePresentationMode];
}

- (IBAction)buttonListPressed:(id)sender {
    self.placeCollectionView.hidden = NO;
    self.mapView.hidden = YES;
    [self setupHousePresentationMode];
}

- (IBAction)buttonMappPressed:(id)sender {
    self.placeCollectionView.hidden = YES;
    self.mapView.hidden = NO;
    [self setupHousePresentationMode];
}

-(void)setupHousePresentationMode{
    
    if(self.segmentController.selectedSegmentIndex == 0){
        self.placeCollectionView.hidden = NO;
        self.mapView.hidden = YES;
    }
    else{
        self.placeCollectionView.hidden = YES;
        self.mapView.hidden = NO;
    }
}

#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return [[JournalData shared].books numberOfsections];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [self.frcPlaces count];//[self.frcPlaces.fetchedObjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PlaceListCell *cell = [self.placeCollectionView dequeueReusableCellWithReuseIdentifier:[PlaceListCell reuseId] forIndexPath:indexPath];
    
    [self configurePlaceListCell:(PlaceListCell *)cell atIndexPath:indexPath];
    
    //NSLog(@"MainViewController indexPath: %li", indexPath.item);
    //    cell.layer.shouldRasterize = YES;
    //    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    return cell;
}

-(void)configurePlaceListCell:(PlaceListCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Places *place = self.frcPlaces[indexPath.item];//self.frcPlaces.fetchedObjects[indexPath.item];
    [cell.titleLabel setText:place.name];
    [cell.subTitleLabel setText:place.address];
    //@property (weak, nonatomic) IBOutlet UIImageView *placeImage; FIXME: add image for place
    
    CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[place.lattitude doubleValue] longitude:[place.longitude doubleValue]];
    NSLog(@"Place location is %@",placeLocation);
    
    NSString *distance = [self getDistanceFromUserLocationTo:placeLocation];
    
    [cell.distanceLabel setText:distance]; //FIXME add distance for place
    
    if(place.promoted.boolValue){
        cell.backgroundColor = kPromotedPlaceCellColor;
    }
    else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, place.photo_small];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"Promoted: %@", place.promoted);
    //[cell.placeImage setImageWithURL:imgUrl];
    [cell.placeImage setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"photo"]];
    
    cell.placeImage.layer.cornerRadius = kImageViewCornerRadius;
    cell.placeImage.clipsToBounds = YES;
    
    
    // ======= rate view =====
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"star_grey"];
    //self.rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"star_yellow"];
    cell.rateView.rating = place.rate.floatValue;
    cell.rateView.editable = NO;
    cell.rateView.maxRating = 5;
}

-(void)createPlaceList{
    
    NSFetchedResultsController *frc = nil;
    
    _sortKeys = @"promoted,sort,name";
    
    NSSortDescriptor *sortDescriptorPromoted = [[NSSortDescriptor alloc] initWithKey:@"promoted" ascending:NO];
    NSSortDescriptor *sortDescriptorSort = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortDescriptorName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray* sortKeys = @[sortDescriptorPromoted, sortDescriptorSort, sortDescriptorName];
    
    if(self.aCategory){ //need to apply filters
        if(self.filterDictionary.count == 0){
            self.frcPlaces = [[self.aCategory.places allObjects] sortedArrayUsingDescriptors:sortKeys];
        }
        else{
            NSMutableArray *subPredicates = [[NSMutableArray alloc] initWithCapacity:0];
            for(id key in self.filterDictionary) {
                id value = [self.filterDictionary objectForKey:key];
            
                if([value isKindOfClass:[NSNumber class]]){
                    NSNumber *filterValue = (NSNumber*)value;
                    if(filterValue.integerValue == 0){ // if YES
                        if([key isEqualToString:kFilterAllTime]){
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"work_time_end == 0 AND work_time_start == 0"];
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
                            NSPredicate *p = [NSPredicate predicateWithFormat:@"NOT(work_time_end >= 0 AND work_time_start <= 0)"];
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
                    
                
                } else if([value isKindOfClass:[NSString class]]){
                    NSArray *searchTerms = [value componentsSeparatedByString:@","];
                    for (NSString *term in searchTerms) {
                        NSPredicate *p = [NSPredicate predicateWithFormat:@"SUBQUERY(attributes, $attr, $attr.name == %@ AND SUBQUERY($attr.values, $val, $val.valueName == %@).@count>0).@count>0", key, term];
                        [subPredicates addObject:p];
                    }
                }
            
                //NSLog(@"key: %@; value: %@", key, value);
                //[value doStuff];
            }
            
            NSPredicate *pred = [NSCompoundPredicate  andPredicateWithSubpredicates:subPredicates];
            //NSLog(@"Filter predicate: %@", pred);
            self.frcPlaces = [[[self.aCategory.places allObjects] filteredArrayUsingPredicate:pred] sortedArrayUsingDescriptors:sortKeys];
        
        }
    }
    else{ // show all places
        frc = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:_sortKeys predicate:nil sectionName:nil delegate:self];
        self.frcPlaces = [[frc fetchedObjects] sortedArrayUsingDescriptors:sortKeys];
    }

    NSLog(@"PlaceController. filterDiscionary: %@", self.filterDictionary);

}

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Places *aPlace = self.frcPlaces[indexPath.item];//self.frcPlaces.fetchedObjects[indexPath.item];
    [self performSegueWithIdentifier:@"segueFromHouseToHouseDetail" sender:aPlace];
}


#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromHouseToHouseDetail"]){
        PlaceDetailViewController *placeVC = (PlaceDetailViewController*)[segue destinationViewController];
        //AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        //NSIndexPath *idx = (NSIndexPath*)sender;
        placeVC.aPlace = (Places*)sender;
        
        //subVC.navigationItem.title = appDelegate.testArray[idx.item];
        
    }
//    else if([[segue identifier] isEqualToString:@"segueFromPlaceViewToFilterView"]){
//        FilterViewController *filter = (FilterViewController*)[segue destinationViewController];
//        filter.aCategory = self.aCategory;
//        filter.delegate = self;
//    }
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
    NSLog(@"currentTimeInSeconds: %ld", (long)currentTimeInSeconds);
    return [NSNumber numberWithInteger:currentTimeInSeconds];
}

@end