//
//  DiscountListViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Places.h"

@interface DiscountListViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *discountListCollectionView;
@property (nonatomic, assign) id delegate;

@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *discountView;

@property (nonatomic, retain) NSArray *pageContent;
@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, retain) NSTimer *pageTimer;

@property (nonatomic, strong) Places *aPlace;
@property (nonatomic, strong) NSFetchedResultsController *frcDiscounts;

@end
