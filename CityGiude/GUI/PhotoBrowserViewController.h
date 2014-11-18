//
//  ViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, retain) NSArray *pageContent;
@property (nonatomic, strong) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIView *photoBrowserView;

@end

