//
//  BannerViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "BannerViewController.h"
#import "BannerContentViewController.h"

@interface BannerViewController ()

@end

@implementation BannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    [self.view addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.pageIndicatorTintColor = [UIColor redColor];
    [self.view bringSubviewToFront:self.pageControl];
    //[self setupPageIndicator];
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


//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
//{
//    return [self.pageContent count];
//}
//
//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
//{
//    return 0;
//}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
