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

#import "PlaceListCell.h"
#import "CategoryListCell.h"
#import "DBWork.h"
#import "Places.h"
#import "Categories.h"

#import "SubCategoryListFlowLayout.h"
#import "SubCategoryCollectionViewController.h"
#import "PlaceDetailViewController.h"
#import "PlaceViewController.h"

@implementation FavourViewController{
    UIUserSettings *_userSettings;
}



-(void)viewDidLoad{
    
    [super viewDidLoad];

    _userSettings = [[UIUserSettings alloc] init];
    
    // ===== UISegmentedControl ====
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [self.segmentControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    [self setTableViewList];

    
    [self setNavBarButtons];
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
    NSLog(@"self.segmentControl.selectedSegmentIndex: %li", self.segmentControl.selectedSegmentIndex);
    
    if(self.segmentControl.selectedSegmentIndex == 0){
        cell = [self.listCollectionView dequeueReusableCellWithReuseIdentifier:[CategoryListCell reuseId] forIndexPath:indexPath];
        [self configureCategoryCell:(CategoryListCell*)cell atIndexPath:indexPath];
    }
    else{
        cell = [self.listCollectionView dequeueReusableCellWithReuseIdentifier:[PlaceListCell reuseId] forIndexPath:indexPath];
        [self configurePlacesCell:(PlaceListCell*)cell atIndexPath:indexPath];
    }
    
    return cell;
    //
    //    cell.layer.shouldRasterize = YES;
    //    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
}

- (void)configurePlacesCell:(PlaceListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Places *place = self.frcPlaces.fetchedObjects[indexPath.row];
    [cell.titleLabel setText:place.name];
}

- (void)configureCategoryCell:(CategoryListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Categories *category = self.frcPlaces.fetchedObjects[indexPath.row];
    [cell.labelCategoryName setText:category.name];
}

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if(self.segmentControl.selectedSegmentIndex == 0){
        Categories *category = self.frcPlaces.fetchedObjects[indexPath.item];
        if(category.places.count == 0)
            [self performSegueWithIdentifier:@"segueFromFavourToSubCategory" sender:category];
        else
            [self performSegueWithIdentifier:@"segueFromFavourToPlaces" sender:category];
    }
    else{
        Places *place = self.frcPlaces.fetchedObjects[indexPath.item];
        [self performSegueWithIdentifier:@"segueFromFavourToPlaceDetail" sender:place];
    }
    
}

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
    
    NSPredicate *predicate = nil; //[NSPredicate predicateWithFormat:@"self in %@", self.aCategory.places];
    //    NSLog(@"Places predicate: %@", predicate);
    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:@"sort" predicate:predicate sectionName:nil delegate:self];
}

-(void)setCategoryList{
    
    SubCategoryListFlowLayout *layout = [[SubCategoryListFlowLayout alloc] init];
    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width;
    layout.itemSize = CGSizeMake(sizeOfItems, 80.0f); //size of each cell
    [self.listCollectionView setCollectionViewLayout:layout];
    
    NSPredicate *predicate = nil; //[NSPredicate predicateWithFormat:@"self in %@", self.aCategory.places];
    //    NSLog(@"Places predicate: %@", predicate);
    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataCategoriesEntity sortKey:@"sort" predicate:predicate sectionName:nil delegate:self];
}

#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromFavourToSubCategory"]){
        SubCategoryCollectionViewController *subVC = (SubCategoryCollectionViewController*)[segue destinationViewController];
        subVC.aCategory = (Categories*)sender;
        
    }
    else if ([[segue identifier] isEqualToString:@"segueFromFavourToPlaces"]){
        PlaceViewController *placeVC = (PlaceViewController*)[segue destinationViewController];
        placeVC.aCategory = (Categories*)sender;
    }
    else if ([[segue identifier] isEqualToString:@"segueFromFavourToPlaceDetail"]){
        PlaceDetailViewController *placeVC = (PlaceDetailViewController*)[segue destinationViewController];
        placeVC.aPlace = (Places*)sender;
    }
}

@end
