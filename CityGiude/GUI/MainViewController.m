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
#import "CategoryListDataSource.h"
#import "CategoryTileDataSource.h"

#import "SubCategoryCollectionViewController.h"

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuTableViewController.h"

#import "Categories.h"


#import "AppDelegate.h"


@interface MainViewController (){
    CategoryListDataSource *_listDataSource;
    CategoryTileDataSource *_tileDataSource;
    UIUserSettings *_userSettings;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    self.isCategory = YES;
    
    // ============== CollectionView Settings ===========
    _userSettings = [[UIUserSettings alloc] init];
    _tileDataSource = [[CategoryTileDataSource alloc] init];
    _tileDataSource.delegate = self;
    _listDataSource = [[CategoryListDataSource alloc] init];
    _listDataSource.delegate = self;
    
    if([_userSettings getPresentationMode] == UICatalogTile){
        [self.catalogCollectionView setDataSource:_tileDataSource];
        [self.catalogCollectionView setCollectionViewLayout:[[CategoryTileFlowLayout alloc] init]];
    }
    else{
        [self.catalogCollectionView setDataSource:_listDataSource];
        [self.catalogCollectionView setCollectionViewLayout:[[CategoryListFlowLayout alloc] init]];
    }
    
    [super viewDidLoad];
    
    self.catalogCollectionView.backgroundColor = [UIColor whiteColor];
    self.catalogCollectionView.delegate = self;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
   
    [self setNavBarButtons];
    
    // ====== SETUP BANNER PAGEVIEW CONTROLLER=====
    self.pageContent = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
    
    NSDictionary *options = [NSDictionary dictionaryWithObject: [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey: UIPageViewControllerOptionSpineLocationKey];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal options:options];
    //UIPageViewControllerTransitionStylePageCurl
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [[self.pageController view] setFrame:[self.view bounds]];
    
    BannerContentViewController *initialVC = [self viewControllerAtIndex:0];
    NSLog(@"initialVC: %@", initialVC);
    NSArray *vc = [NSArray arrayWithObject:initialVC];
    [self.pageController setViewControllers:vc direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.bannerView addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightTextColor];
    [self.bannerView bringSubviewToFront:self.pageControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [self setupPageIndicator];
    self.pageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePage) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.pageTimer invalidate];
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
    
    // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem = [_userSettings setupRightButtonItem:self];
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    

    
}

-(void)menuDrawerButtonPress:(id)sender{
//    if(_isSearchBarShown){
//        [_searchView resignFirstResponder];
//    }
    
//    LeftSideBarViewController *lc =  (LeftSideBarViewController *)self.mm_drawerController.leftDrawerViewController;
//    lc.delegate = self;
    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)rightBarButtonPressed{
    
    if([_userSettings getPresentationMode] == UICatalogList){
        [self.catalogCollectionView setDataSource:_tileDataSource];
        //_tileDataSource.delegate = self;
        [self.catalogCollectionView setCollectionViewLayout:[[CategoryTileFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogTile];
    }
    else{
        [self.catalogCollectionView setDataSource:_listDataSource];
        [self.catalogCollectionView setCollectionViewLayout:[[CategoryListFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogList];
    }
    
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
    pageContentViewController.titleText = self.pageContent[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}


-(NSUInteger)indexOfViewController:(BannerContentViewController*)viewController{
    
    //NSLog(@"");
    return [_pageContent indexOfObject:viewController.titleText];
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
    
    self.pageControl.numberOfPages = [self.pageContent count];
    [self setupCurrentPage];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    
    if(completed){
        [self setupCurrentPage];
    }
}

-(void)setupCurrentPage{
    NSUInteger newIndex = [self indexOfViewController:(BannerContentViewController *)self.pageController.viewControllers[0]];
    self.pageControl.currentPage =  newIndex;
}

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSLog(@"Item selected: %@", appDelegate.testArray[indexPath.item]);
    [self performSegueWithIdentifier:@"segueFromCategoryToSubcategory" sender:indexPath];
}

#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromCategoryToSubcategory"]){
        SubCategoryCollectionViewController *subVC = (SubCategoryCollectionViewController*)[segue destinationViewController];
        
        NSIndexPath *idx = (NSIndexPath*)sender;
        
        subVC.aCategory = ([_userSettings getPresentationMode] == UICatalogList) ? _listDataSource.itemsArray[idx.item] : _tileDataSource.itemsArray[idx.item];

    }
}





@end
