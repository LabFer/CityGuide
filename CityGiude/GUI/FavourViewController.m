//
//  FavourViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 23/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "FavourViewController.h"
#import "UIUserSettings.h"

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuTableViewController.h"

#import "DBWork.h"
#import "Places.h"
#import "Categories.h"

#import "SubCategoryListFlowLayout.h"
#import "SubCategoryCollectionViewController.h"
#import "PlaceDetailViewController.h"
#import "PlaceViewController.h"
#import "UIImageView+AFNetworking.h"

@implementation FavourViewController{
    UIUserSettings *_userSettings;
    NSString *_sortCategory;
    NSString *_sortPlaces;
}



-(void)viewDidLoad{
    
    [super viewDidLoad];

    _userSettings = [[UIUserSettings alloc] init];
    
    // ===== UISegmentedControl ====
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [self.segmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    _sortCategory = @"sort,name";
    _sortPlaces = @"promoted,sort,name";
    
    [self setNavBarButtons];
    
    self.listCollectionView.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    [self setTableViewList];
    [self.listCollectionView reloadData];

    
}



#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    //    MenuTableViewController *lc =  (MenuTableViewController *)self.mm_drawerController.leftDrawerViewController;
    //    lc.previousDisplayMode = UICatalog;
    
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuDrawerButtonPress:)];
    leftDrawerButton.tintColor = kDefaultNavItemTintColor;//[UIColor blueColor];
    
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    //    self.navigationController.navigationBar.topItem.title = kAppMainTitle;
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.title = kNavigationTitleFavour;
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeBezelPanningCenterView];

    
}

-(void)menuDrawerButtonPress:(id)sender{

    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
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
    
    UICollectionViewCell *cell = nil;
    //NSLog(@"self.segmentControl.selectedSegmentIndex: %li", self.segmentControl.selectedSegmentIndex);
    
    if(self.segmentControl.selectedSegmentIndex == 0){
        cell = [self.listCollectionView dequeueReusableCellWithReuseIdentifier:[FavourCategoryCell reuseId] forIndexPath:indexPath];
        [self configureCategoryCell:(FavourCategoryCell*)cell atIndexPath:indexPath];
    }
    else{
        cell = [self.listCollectionView dequeueReusableCellWithReuseIdentifier:[FavourPlaceListCell reuseId] forIndexPath:indexPath];
        [self configurePlacesCell:(FavourPlaceListCell*)cell atIndexPath:indexPath];
    }
    
    return cell;
    //
    //    cell.layer.shouldRasterize = YES;
    //    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
}

- (void)configurePlacesCell:(FavourPlaceListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Places *place = self.frcPlaces.fetchedObjects[indexPath.row];
    [cell.titleLabel setText:place.name];
    [cell.subTitleLabel setText:place.address];
    //@property (weak, nonatomic) IBOutlet UIImageView *placeImage; FIXME: add image for place
    
    [cell.distanceLabel setText:[self radiantToMeters]]; //FIXME add distance for place
    
    if(place.promoted.boolValue){
        cell.cellContentView.backgroundColor = kPromotedPlaceCellColor;
    }
    else{
        cell.cellContentView.backgroundColor = [UIColor whiteColor];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, place.photo_small];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@\n%@", urlStr, imgUrl);
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
    
    //[self.listCollectionView.panGestureRecognizer requireGestureRecognizerToFail:cell.leftSwipe];
    
    cell.delegate = self;
    //[cell.btnDelete addTarget:self action:@selector(deletePlace:) forControlEvents:UIControlEventTouchUpInside];

}

-(NSString*)radiantToMeters{
    return @"10km";
}

- (void)configureCategoryCell:(FavourCategoryCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Categories *category = self.frcPlaces.fetchedObjects[indexPath.item];
    [cell.categoryTitleLabel setText:category.name];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, category.photo];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    //NSLog(@"%@\n%@", urlStr, imgUrl);
    //[cell.placeImage setImageWithURL:imgUrl];
    [cell.categoryImage setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"icons_category"]];
    cell.delegate = self;

}

//#pragma mark - CollectionViewDelegate
//-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if(self.segmentControl.selectedSegmentIndex == 0){
//        
//        Categories *category = self.frcPlaces.fetchedObjects[indexPath.item];
//        NSLog(@"Category: %lu", category.places.count);
//        if(category.places.count == 0){
//            NSLog(@"perform segueFromFavourToSubCategory");
//            [self performSegueWithIdentifier:@"segueFromFavourToSubCategory" sender:category];
//        }
//        else{
//            NSLog(@"perform segueFromFavourToPlaces");
//            [self performSegueWithIdentifier:@"segueFromFavourToPlaces" sender:category];
//        }
//    }
//    else{
//        
//        NSLog(@"perform segueFromFavourToPlaceDetail");
//        Places *place = self.frcPlaces.fetchedObjects[indexPath.item];
//        [self performSegueWithIdentifier:@"segueFromFavourToPlaceDetail" sender:place];
//    }
//    
//}

#pragma mark - UISegmentedControl
- (IBAction)segmentValueChanged:(id)sender {
    
    NSLog(@"segmentValueChanged: %li", self.segmentControl.selectedSegmentIndex);
    [self setTableViewList];
    [self.listCollectionView reloadData];
}

#pragma mark - CoreData
-(void)setTableViewList{
    if(self.segmentControl.selectedSegmentIndex == 0){
        [self setCategoryList];
    }
    else{
        [self setPlacesList];
    }
}

-(void)setPlacesList{
    
    SubCategoryListFlowLayout *layout = [[SubCategoryListFlowLayout alloc] init];
    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width;
    layout.itemSize = CGSizeMake(sizeOfItems, 115.0f); //size of each cell
    [self.listCollectionView setCollectionViewLayout:layout];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favour == 1"];
//    self.frcPlaces = nil;
    NSArray *arr = [[DBWork shared] getFavourPlace];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id IN %@", arr];
    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:_sortPlaces predicate:predicate sectionName:nil delegate:self];
}

-(void)setCategoryList{
    
    SubCategoryListFlowLayout *layout = [[SubCategoryListFlowLayout alloc] init];
    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width;
    layout.itemSize = CGSizeMake(sizeOfItems, 80.0f); //size of each cell
    [self.listCollectionView setCollectionViewLayout:layout];
    
    NSArray *arr = [[DBWork shared] getFavourCategory];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id IN %@", arr];
//    self.frcPlaces = nil;
    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataCategoriesEntity sortKey:_sortCategory predicate:predicate sectionName:nil delegate:self];
}

#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromFavourToSubCategory"]){
        NSLog(@"prepare segueFromFavourToSubCategory");
        SubCategoryCollectionViewController *subVC = (SubCategoryCollectionViewController*)[segue destinationViewController];
        subVC.aCategory = (Categories*)sender;
        
    }
    else if ([[segue identifier] isEqualToString:@"segueFromFavourToPlaces"]){
        NSLog(@"prepare segueFromFavourToPlaces");
        PlaceViewController *placeVC = (PlaceViewController*)[segue destinationViewController];
        placeVC.aCategory = (Categories*)sender;
    }
    else if ([[segue identifier] isEqualToString:@"segueFromFavourToPlaceDetail"]){
        NSLog(@"prepare segueFromFavourToPlaceDetail");

        PlaceDetailViewController *placeVC = (PlaceDetailViewController*)[segue destinationViewController];
        placeVC.aPlace = (Places*)sender;
    }
}

#pragma mark - FavourPlaceListCellDelegate
-(void)btnDeletePressed:(id)sender forCell:(UICollectionViewCell *)cell{
    FavourPlaceListCell *aCell = (FavourPlaceListCell*)cell;
    NSIndexPath *indexPath = [self.listCollectionView indexPathForCell:aCell];
    
    Places *place = self.frcPlaces.fetchedObjects[indexPath.item];
//    place.favour = [NSNumber numberWithBool:NO];
//    [[DBWork shared] saveContext];
    [[DBWork shared] removePlaceFromFavour:place.id];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favour == 1"];
    //    NSLog(@"Places predicate: %@", predicate);
    //self.frcPlaces = nil;
    
    NSArray *arr = [[DBWork shared] getFavourPlace];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id IN %@", arr];
    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:_sortPlaces predicate:predicate sectionName:nil delegate:self];
    //[self.listCollectionView reloadData];
    [self.listCollectionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - FavourCategoryCellDelegate
-(void)btnDeleteCategoryPressed:(id)sender forCell:(UICollectionViewCell *)cell{
    FavourCategoryCell *aCell = (FavourCategoryCell*)cell;
    NSIndexPath *indexPath = [self.listCollectionView indexPathForCell:aCell];
    
    Categories *category = self.frcPlaces.fetchedObjects[indexPath.item];
    
    //category.favour = [NSNumber numberWithBool:NO];
    [[DBWork shared] removeCategoryFromFavour:category.id];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favour == 1"];
    //    NSLog(@"Places predicate: %@", predicate);
    //self.frcPlaces = nil;
    NSArray *arr = [[DBWork shared] getFavourCategory];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id IN %@", arr];

    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataCategoriesEntity sortKey:_sortCategory predicate:predicate sectionName:nil delegate:self];
    
    //[self.listCollectionView reloadData];
    [self.listCollectionView deleteItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - Gesture recognizer
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    NSIndexPath *indexPath = [self.listCollectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.listCollectionView]];
    
    if(indexPath){
        NSLog(@"handleTap didSelectImageAtIndexPath: %lu", indexPath.row);
        
        if(self.segmentControl.selectedSegmentIndex == 0){
            
            Categories *category = self.frcPlaces.fetchedObjects[indexPath.item];
            NSLog(@"Category: %lu", category.places.count);
            if(category.places.count == 0){
                NSLog(@"perform segueFromFavourToSubCategory");
                [self performSegueWithIdentifier:@"segueFromFavourToSubCategory" sender:category];
            }
            else{
                NSLog(@"perform segueFromFavourToPlaces");
                [self performSegueWithIdentifier:@"segueFromFavourToPlaces" sender:category];
            }
        }
        else{
//            FavourPlaceListCell *cell = (FavourPlaceListCell *)[self.listCollectionView cellForItemAtIndexPath:indexPath];
//            if(cell.isDelete) return;
            
            NSLog(@"perform segueFromFavourToPlaceDetail");
            Places *place = self.frcPlaces.fetchedObjects[indexPath.item];
            [self performSegueWithIdentifier:@"segueFromFavourToPlaceDetail" sender:place];
        }
    }
}


@end
