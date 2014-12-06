//
//  ViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "MainViewController.h"
#import "BannerContentViewController.h"
#import "UIUserSettings.h"
#import "CategoryListFlowLayout.h"
#import "CategoryTileFlowLayout.h"
#import "CategoryListCell.h"
#import "CategoryCell.h"
#import "BannerHeaderCollectionView.h"

#import "SubCategoryCollectionViewController.h"
#import "PlaceViewController.h"
#import "PlaceDetailViewController.h"

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuTableViewController.h"

#import "Categories.h"
#import "Places.h"
#import "DBWork.h"


#import "AppDelegate.h"


@interface MainViewController (){
    UIUserSettings *_userSettings;
    BannerHeaderCollectionView *_headerView;
    NSString *_sortKeys;
}

@end

@implementation MainViewController

- (void)viewDidLoad {

    _userSettings = [[UIUserSettings alloc] init];
    
    [super viewDidLoad];
    
    // ======== Set CoreData =======
    NSString *str = [NSString stringWithFormat:@"parent_id == %i", 0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
    _sortKeys = @"sort,name";
    self.frcCategories = [[DBWork shared] fetchedResultsController:kCoreDataCategoriesEntity sortKey:_sortKeys predicate:predicate sectionName:nil delegate:self];
    
    if([_userSettings getPresentationMode] == UICatalogTile){
        [self.catalogCollectionView setCollectionViewLayout:[[CategoryTileFlowLayout alloc] init]];
    }
    else{
        [self.catalogCollectionView setCollectionViewLayout:[[CategoryListFlowLayout alloc] init]];
    }
    
    
    self.catalogCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //[self.view setBackgroundColor:[UIColor clearColor]];
   
    [self setNavBarButtons];
    
    // ====== SETUP BANNER PAGEVIEW CONTROLLER=====
    self.pageContent = [[DBWork shared] getArrayOfBanners];
    
    NSDictionary *options = [NSDictionary dictionaryWithObject: [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey: UIPageViewControllerOptionSpineLocationKey];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal options:options];
    //UIPageViewControllerTransitionStylePageCurl
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [[self.pageController view] setFrame:[self.view bounds]];
    
    BannerContentViewController *initialVC = [self viewControllerAtIndex:0];
    //NSLog(@"initialVC: %@", initialVC);
    NSArray *vc = [NSArray arrayWithObject:initialVC];
    [self.pageController setViewControllers:vc direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
//    [self.bannerView addSubview:[self.pageController view]];
//    [self.pageController didMoveToParentViewController:self];
//    
//    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
//    self.pageControl.pageIndicatorTintColor = [UIColor lightTextColor];
//    [self.bannerView bringSubviewToFront:self.pageControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupPageIndicator];
    self.pageTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updatePage) userInfo:nil repeats:YES];
    
    [self.catalogCollectionView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.pageTimer invalidate];
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuDrawerButtonPress:)];
    leftDrawerButton.tintColor = kDefaultNavItemTintColor;//[UIColor blueColor];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem = [_userSettings setupRightButtonItem:self];
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.title = kNavigationTitle;
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // ====== mmdrawer swipe gesture =======
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

-(void)menuDrawerButtonPress:(id)sender{

    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightBarButtonPressed{
    
    if([_userSettings getPresentationMode] == UICatalogList){
//        [self.catalogCollectionView setDataSource:_tileDataSource];
        //_tileDataSource.delegate = self;
        [self.catalogCollectionView setCollectionViewLayout:[[CategoryTileFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogTile];
    }
    else{
//        [self.catalogCollectionView setDataSource:_listDataSource];
        [self.catalogCollectionView setCollectionViewLayout:[[CategoryListFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogList];
    }
    
    [self.catalogCollectionView reloadData];
    self.navigationItem.rightBarButtonItem = [_userSettings setupRightButtonItem:self];
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
}

#pragma mark - Page View Controller

-(BannerContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageContent count] == 0) || (index >= [self.pageContent count])) {
        NSLog(@"viewControllerAtIndex return Nil");
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    BannerContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BannerContentViewController"];
    //    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.aBanner = self.pageContent[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}


-(NSUInteger)indexOfViewController:(BannerContentViewController*)viewController{
    
    //NSLog(@"");
    return [_pageContent indexOfObject:viewController.aBanner];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((BannerContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((BannerContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageContent count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

-(void)updatePage{
    NSUInteger currentIndex = [self indexOfViewController:(BannerContentViewController *)self.pageController.viewControllers[0]];
    
    BOOL forward = true;
    NSLog(@"updatePage. currentIndex: %lu; count: %lu", currentIndex, [self.pageContent count]);
    if((currentIndex + 1) >= [self.pageContent count]){
        currentIndex = 0;
        forward = false;
    }
    else{
        currentIndex++;
        forward = true;
    }
    
    BannerContentViewController *initialVC = [self viewControllerAtIndex:currentIndex];
    NSArray *vc = [NSArray arrayWithObject:initialVC];
    
    UIPageViewControllerNavigationDirection direction = forward ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self.pageController setViewControllers:vc direction:direction animated:YES completion:nil];
    [self setupCurrentPage];
    
}

#pragma mark - Page Indicator
-(void)setupPageIndicator{
    
    if(_headerView){
        _headerView.pageControl.numberOfPages = [self.pageContent count];
        [self setupCurrentPage];
    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    
    if(completed){
        [self setupCurrentPage];
    }
}

-(void)setupCurrentPage{
    
    if(_headerView){
        NSUInteger newIndex = [self indexOfViewController:(BannerContentViewController *)self.pageController.viewControllers[0]];
        _headerView.pageControl.currentPage =  newIndex;
    }
}

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

//    NSLog(@"didSelectItemAtIndexPath = %li", indexPath.item);
    Categories *category = self.frcCategories.fetchedObjects[indexPath.item];
    
//    NSLog(@"category.places.count = %lu", category.places.count);
    if(category.places.count == 0)
        [self performSegueWithIdentifier:@"segueFromCategoryToSubcategory" sender:category];
    else
        [self performSegueWithIdentifier:@"segueFromCategoryToPlaces" sender:category];
}


#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return [[JournalData shared].books numberOfsections];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [self.frcCategories.fetchedObjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = nil;
    
    //NSLog(@"MainViewController indexPath: %li", indexPath.item);
    
    if([_userSettings getPresentationMode] == UICatalogList){
        cell = [self.catalogCollectionView dequeueReusableCellWithReuseIdentifier:[CategoryListCell reuseId] forIndexPath:indexPath];
        [self configureCategoryListCell:(CategoryListCell *)cell atIndexPath:indexPath];
    }
    else{
        cell = [self.catalogCollectionView dequeueReusableCellWithReuseIdentifier:[CategoryTileCell reuseId] forIndexPath:indexPath];
        [self configureCategoryTileCell:(CategoryTileCell *)cell atIndexPath:indexPath];
    }

    //
    //    cell.layer.shouldRasterize = YES;
    //    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    return cell;
}

-(void)configureCategoryListCell:(CategoryListCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Categories *category = self.frcCategories.fetchedObjects[indexPath.item];
    [cell.labelCategoryName setText:category.name];
    [cell.btnCellHeart addTarget:self action:@selector(collectionViewCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if(category.favour.boolValue)
        [cell.btnCellHeart setImage:[UIImage imageNamed:@"active_heart"] forState:UIControlStateNormal];
    else
        [cell.btnCellHeart setImage:[UIImage imageNamed:@"inactive_heart"] forState:UIControlStateNormal];
}

-(void)configureCategoryTileCell:(CategoryTileCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Categories *category = self.frcCategories.fetchedObjects[indexPath.item];
    [cell.labelCategoryName setText:category.name];
    [cell.btnCellHeart addTarget:self action:@selector(collectionViewCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if(category.favour.boolValue)
       [cell.btnCellHeart setImage:[UIImage imageNamed:@"active_heart"] forState:UIControlStateNormal];
    else
        [cell.btnCellHeart setImage:[UIImage imageNamed:@"inactive_heart"] forState:UIControlStateNormal];
}

#pragma mark CollectionView Header
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"CollectionView Header: %@", indexPath);
    
    UICollectionReusableView *reusableView = nil;
    
    BannerHeaderCollectionView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"BannerHeaderCollectionView" forIndexPath:indexPath];
    
    [headerView setBackgroundColor:[UIColor clearColor]];
    [headerView configurePageViewController];
    [headerView addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    [headerView bringSubviewToFront:headerView.pageControl];
    headerView.pageControl.numberOfPages = [self.pageContent count];
    [self setupCurrentPage];
    
    _headerView = headerView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleHeaderTap:)];
    [headerView addGestureRecognizer:tap];
    
    

    reusableView = headerView;
    
    return headerView;
}


#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromCategoryToSubcategory"]){
        SubCategoryCollectionViewController *subVC = (SubCategoryCollectionViewController*)[segue destinationViewController];        
        subVC.aCategory = (Categories*)sender;
        subVC.delegate = self;

    }
    else if ([[segue identifier] isEqualToString:@"segueFromCategoryToPlaces"]){
        PlaceViewController *placeVC = (PlaceViewController*)[segue destinationViewController];
        placeVC.aCategory = (Categories*)sender;
    }
    else if([[segue identifier] isEqualToString:@"segueFromCategoryToPlaceDetail"]){
        PlaceDetailViewController *subVC = (PlaceDetailViewController*)[segue destinationViewController];
        subVC.aPlace = (Places*)sender;
    }
}


#pragma mark - Button Handlers

- (IBAction)collectionViewCellButtonPressed:(UIButton *)button{
    
    //Acccess the cell
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview;
    
    NSIndexPath *indexPath = [self.catalogCollectionView indexPathForCell:cell];
    Categories *category = self.frcCategories.fetchedObjects[indexPath.item];
    //NSLog(@"button pressed: %@, %@", indexPath, category.name);
    
    //if(category.favour.boolValue)
    category.favour = [NSNumber numberWithBool:!category.favour.boolValue];
    [[DBWork shared] saveContext];
    
    [self.catalogCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
    
    //NSString *title = self.strings[indexPath.row];
    
    //self.someLabel.text = title;
    
}


#pragma mark - Gesture recognizer
- (void)handleHeaderTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    BannerContentViewController* bannerVC = (BannerContentViewController *)self.pageController.viewControllers[0];
    Banners *aBanner = bannerVC.aBanner;
    NSLog(@"handleHeaderTap: %@", aBanner.bannerName);
    
    if([aBanner.type isEqualToString:@"place"]){ //goto place
        NSNumber *placeID = [[NSNumberFormatter alloc] numberFromString:aBanner.url];
        Places *aPlace = [[DBWork shared] getPlaceByplaceID:placeID];
        [self performSegueWithIdentifier:@"segueFromCategoryToPlaceDetail" sender:aPlace];//segueFromCategoryToPlaceDetail
    
    }
    else if([aBanner.type isEqualToString:@"event"]){ //goto event
        //segueFromCategoryToDiscountDetail
    }
    else if([aBanner.type isEqualToString:@"url"]){ //goto external url
        NSString *web =  ([aBanner.url rangeOfString:@"http://"].location == NSNotFound) ? [NSString stringWithFormat:@"http://%@", aBanner.url] : [NSString stringWithFormat:@"%@", aBanner.url];
        NSLog(@"Banner. Open URL: %@", web);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:web]];
    }
    else if([aBanner.type isEqualToString:@"text"]){ //goto text
    
    }
}




@end
