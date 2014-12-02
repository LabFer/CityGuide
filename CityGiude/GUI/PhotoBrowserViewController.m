//
//  ViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "PhotoBrowserContentViewController.h"
#import "UIUserSettings.h"
#import "Gallery.h"


#import "AppDelegate.h"

//#import "UIViewController+MMDrawerController.h"
//#import "MMDrawerBarButtonItem.h"
//#import "LeftSideBarViewController.h"

@interface PhotoBrowserViewController (){
    UIUserSettings *_userSettings;
}

@end

@implementation PhotoBrowserViewController

- (void)viewDidLoad {
    
    _userSettings = [[UIUserSettings alloc] init];
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
   
    [self setNavBarButtons];

    // ====== SETUP BANNER PAGEVIEW CONTROLLER=====
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for(Gallery *item in [self.aPlace.gallery allObjects]){
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, item.photo_big];
        NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [array addObject:imgUrl];
    }
    
    self.pageContent = [[NSArray alloc] initWithArray:array];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"1/%lu", [self.pageContent count]]];

    
    NSDictionary *options = [NSDictionary dictionaryWithObject: [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin] forKey: UIPageViewControllerOptionSpineLocationKey];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation: UIPageViewControllerNavigationOrientationHorizontal options:options];
    //UIPageViewControllerTransitionStylePageCurl
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [[self.pageController view] setFrame:[self.photoBrowserView bounds]];
    
    PhotoBrowserContentViewController *initialVC = [self viewControllerAtIndex:0];
    NSLog(@" PhotoBrowserVC initialVC: %@", initialVC);
    NSArray *vc = [NSArray arrayWithObject:initialVC];
    [self.pageController setViewControllers:vc direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.photoBrowserView addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
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

-(void)rightBarButtonPressed{
    
    //self.navigationItem.rightBarButtonItem = [_userSettings setupRightButtonItem:self];
}

#pragma mark - Page View Controller

-(PhotoBrowserContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageContent count] == 0) || (index >= [self.pageContent count])) {
        NSLog(@"viewControllerAtIndex return Nil");
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PhotoBrowserContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoBrowserContentViewController"];
    //    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageContent[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}


-(NSUInteger)indexOfViewController:(PhotoBrowserContentViewController*)viewController{
    
    //NSLog(@"");
    return [_pageContent indexOfObject:viewController.titleText];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PhotoBrowserContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PhotoBrowserContentViewController*) viewController).pageIndex;
    
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
    NSUInteger currentIndex = [self indexOfViewController:(PhotoBrowserContentViewController *)self.pageController.viewControllers[0]];
    
    BOOL forward = true;
    
    if((currentIndex + 1) >= [self.pageContent count]){
        currentIndex = 0;
        forward = false;
    }
    else{
        currentIndex++;
        forward = true;
    }
    
    PhotoBrowserContentViewController *initialVC = [self viewControllerAtIndex:currentIndex];
    NSArray *vc = [NSArray arrayWithObject:initialVC];
    
    UIPageViewControllerNavigationDirection direction = forward ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self.pageController setViewControllers:vc direction:direction animated:YES completion:nil];
    [self setupCurrentPage];
    
}

#pragma mark - Page Indicator

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    
    
    if(completed){
        [self setupCurrentPage];
    }
}

-(void)setupCurrentPage{
    NSUInteger newIndex = [self indexOfViewController:(PhotoBrowserContentViewController *)self.pageController.viewControllers[0]];
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%lu/%lu", newIndex + 1, [self.pageContent count]]];
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
