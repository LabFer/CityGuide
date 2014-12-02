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

#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

@implementation PlaceViewController{
    UIUserSettings *_userSettings;
    NSString *_sortKeys;
}

@synthesize mapView;
@synthesize tileCache;

-(void)viewDidLoad{

    [super viewDidLoad];
    
    SubCategoryListFlowLayout *layout = [[SubCategoryListFlowLayout alloc] init];
    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width;
    layout.itemSize = CGSizeMake(sizeOfItems, 115.0f); //size of each cell
    [self.placeCollectionView setCollectionViewLayout:layout];

    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self in %@", self.aCategory.places];
    _sortKeys = @"promoted,sort,name";
    //NSLog(@"Places predicate: %@", predicate);
    
    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:_sortKeys predicate:predicate sectionName:nil delegate:self];

    self.placeCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.listMapButtonView.backgroundColor = kDefaultButtonBarColor;
    
    _userSettings = [[UIUserSettings alloc] init];
    
    // ===== UISegmentedControl ====
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [self.segmentController setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    [self setupHousePresentationMode];
    
    [self setNavBarButtons];

    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"mapbox" ofType:@"json"];
    NSError *error;
    NSString* tileJSON = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    self.mapView.tileSource = [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    
    [self.mapView.tileSource setCacheable:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    double minLat = NAN, maxLat = NAN, minLong = NAN, maxLong = NAN;
    
    for (Places *place in self.frcPlaces.fetchedObjects) {
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
        [self.mapView addAnnotation:annotation];
    }
    __weak RMMapView *weakMap = self.mapView; // avoid block-based memory leak
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
                   {
                       float degreeRadius = 9000.f / 110000.f; // (9000m / 110km per degree latitude)
                       
                       CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((minLat+maxLat)/2, (minLong+maxLong)/2);
                       
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
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupFilterButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button =====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.title = self.aCategory.name;
    
    // ===== remove shadow =====

    
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)filterButtonPressed{
    [self performSegueWithIdentifier:@"segueFromPlaceViewToFilterView" sender:self];
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
    
    return [self.frcPlaces.fetchedObjects count];
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
    Places *place = self.frcPlaces.fetchedObjects[indexPath.row];
    [cell.titleLabel setText:place.name];
    [cell.subTitleLabel setText:place.address];
    //@property (weak, nonatomic) IBOutlet UIImageView *placeImage; FIXME: add image for place

    [cell.distanceLabel setText:@"10 км"]; //FIXME add distance for place

    if(place.promoted.boolValue){
        cell.backgroundColor = kPromotedPlaceCellColor;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, place.photo_small];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@\n%@", urlStr, imgUrl);
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

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"segueFromHouseToHouseDetail" sender:indexPath];
}


#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
        if([[segue identifier] isEqualToString:@"segueFromHouseToHouseDetail"]){
            PlaceDetailViewController *placeVC = (PlaceDetailViewController*)[segue destinationViewController];
            //AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            NSIndexPath *idx = (NSIndexPath*)sender;
            placeVC.aPlace = self.frcPlaces.fetchedObjects[idx.item];
            
            //subVC.navigationItem.title = appDelegate.testArray[idx.item];
            
        }
}

@end
