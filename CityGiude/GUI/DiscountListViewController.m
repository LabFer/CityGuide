//
//  DiscountListViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "DiscountListViewController.h"
#import "DiscountListCell.h"
#import "BannerHeaderCollectionView.h"
#import "BannerContentViewController.h"
#import "UIUserSettings.h"
#import "CategoryListFlowLayout.h"
#import "PlaceDetailViewController.h"
#import "DiscountDetailViewController.h"

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuTableViewController.h"

#import "DBWork.h"
#import "Discounts.h"
#import "UIImageView+AFNetworking.h"

@implementation DiscountListViewController{
    UIUserSettings *_userSettings;
    BannerHeaderCollectionView *_headerView;
    NSString *_sortKeys;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _userSettings = [[UIUserSettings alloc] init];
    
    CategoryListFlowLayout *layout = [[CategoryListFlowLayout alloc] init];
    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width;
    layout.itemSize = CGSizeMake(sizeOfItems, 115.0f); //size of each cell
    [self.discountListCollectionView setCollectionViewLayout:layout];
    self.discountListCollectionView.backgroundColor = [UIColor whiteColor];
    
    NSString *str = @"";
    NSPredicate *predicate = nil;
    if(self.aPlace){
        str = [NSString stringWithFormat:@"placeID == %@", self.aPlace.placeID];
        predicate = [NSPredicate predicateWithFormat:str];
    }
    
    _sortKeys = @"discountID";
    self.frcDiscounts = [[DBWork shared] fetchedResultsController:kCoreDataDiscountEntity sortKey:_sortKeys predicate:predicate sectionName:nil delegate:self];
    
    
    
    [self setNavBarButtons];
    
    // ====== SETUP BANNER PAGEVIEW CONTROLLER=====
    self.pageContent = [[DBWork shared] getArrayOfBanners];
    if(self.pageContent.count == 0)
        self.pageContent = @[@""];
    
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
    [self.bannerView addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightTextColor];
    [self.bannerView bringSubviewToFront:self.pageControl];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupPageIndicator];
    self.pageTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updatePage) userInfo:nil repeats:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.pageTimer invalidate];
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuDrawerButtonPress:)];
    leftDrawerButton.tintColor = kDefaultNavItemTintColor;//[UIColor blueColor];
    
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    self.navigationItem.title = kNavigationTitleDiscount;
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
 
}

-(void)menuDrawerButtonPress:(id)sender{

    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    Discounts *aDiscount = self.frcDiscounts.fetchedObjects[indexPath.row];
    [self performSegueWithIdentifier:@"segueFromDiscountListToDiscountDetail" sender:aDiscount];

}

#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return [[JournalData shared].books numberOfsections];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"self.frcDiscounts.fetchedObjects count: %lu", [self.frcDiscounts.fetchedObjects count]);
    return [self.frcDiscounts.fetchedObjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    DiscountListCell *cell = [self.discountListCollectionView dequeueReusableCellWithReuseIdentifier:[DiscountListCell reuseId] forIndexPath:indexPath];
    [self configureCell:(DiscountListCell *)cell atIndexPath:indexPath];
    
    //
    //    cell.layer.shouldRasterize = YES;
    //    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    return cell;
}

-(void)configureCell:(DiscountListCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Discounts *discount = self.frcDiscounts.fetchedObjects[indexPath.row];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, discount.image];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@\n%@", urlStr, imgUrl);
    //[cell.placeImage setImageWithURL:imgUrl];
    [cell.discountImage setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"photo"]];
    
    cell.discountImage.layer.cornerRadius = kImageViewCornerRadius;
    cell.discountImage.clipsToBounds = YES;
    
    cell.discountText.text = discount.text;
    cell.discountTitle.text = discount.name;
    cell.discountTime.text = [self timeDifferenceToString:discount.dateEnd];
}

-(NSString*)timeDifferenceToString:(NSNumber*)endTime{

    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *currentDate = [NSDate date];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endTime.doubleValue];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:currentDate  toDate:endDate  options:0];
    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
//    NSLog(@"currentDate: %@", [dateFormatter stringFromDate:currentDate]);
//    NSLog(@"endDate: %@", [dateFormatter stringFromDate:endDate]);
    
//    NSLog(@"Break down: %ld min : %ld hours : %ld days : %ld months", [breakdownInfo minute], [breakdownInfo hour], [breakdownInfo day], [breakdownInfo month]);
    
    NSString *resultString = @"";
    if([breakdownInfo month] != 0){
        resultString = [NSString stringWithFormat:@" Осталось %li месяца %li дней", (long)[breakdownInfo month], (long)[breakdownInfo day]];
    }
    else{
        if([breakdownInfo day] != 0){
            resultString = [NSString stringWithFormat:@"Осталось %li дней", (long)[breakdownInfo day]];
        }
        else{
            resultString = [NSString stringWithFormat:@"Осталось %li часов %li минут", (long)[breakdownInfo hour], (long)[breakdownInfo minute]];
        }
    }
    
    return resultString;
}

#pragma mark CollectionView Header
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"CollectionView Header: %@", indexPath);
    
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
    
    return headerView;
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
    pageContentViewController.dataObject = self.pageContent[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}


-(NSUInteger)indexOfViewController:(BannerContentViewController*)viewController{
    
    //NSLog(@"");
    return [_pageContent indexOfObject:viewController.dataObject];
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
    //NSLog(@"updatePage. currentIndex: %lu; count: %lu", currentIndex, [self.pageContent count]);
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

#pragma mark - Gesture recognizer
- (void)handleHeaderTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    BannerContentViewController* bannerVC = (BannerContentViewController *)self.pageController.viewControllers[0];
    
    if([bannerVC.dataObject isKindOfClass:[Banners class]]){
        Banners *aBanner = (Banners*)bannerVC.dataObject;
        NSLog(@"handleHeaderTap: %@", aBanner.bannerName);
    
        if([aBanner.type isEqualToString:@"place"]){ //goto place
            NSNumber *placeID = [[NSNumberFormatter alloc] numberFromString:aBanner.url];
            Places *aPlace = [[DBWork shared] getPlaceByplaceID:placeID];
            [self performSegueWithIdentifier:@"segueFromDiscountToPlaceDetail" sender:aPlace];
        
        }
        else if([aBanner.type isEqualToString:@"event"]){ //goto event
            [self performSegueWithIdentifier:@"segueFromDiscountListToDiscountDetail" sender:self];
        }
        else if([aBanner.type isEqualToString:@"url"]){ //goto external url
            NSString *web =  ([aBanner.url rangeOfString:@"http://"].location == NSNotFound) ? [NSString stringWithFormat:@"http://%@", aBanner.url] : [NSString stringWithFormat:@"%@", aBanner.url];
            NSLog(@"Banner. Open URL: %@", web);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:web]];
        }
        else if([aBanner.type isEqualToString:@"text"]){ //goto text
        
        }
    }
}

#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromDiscountListToDiscountDetail"]){
        DiscountDetailViewController *subVC = (DiscountDetailViewController*)[segue destinationViewController];
        subVC.aDiscount = (Discounts*)sender;        
    }
    else if([[segue identifier] isEqualToString:@"segueFromDiscountToPlaceDetail"]){
        PlaceDetailViewController *subVC = (PlaceDetailViewController*)[segue destinationViewController];
        subVC.aPlace = (Places*)sender;
    }
}




@end
