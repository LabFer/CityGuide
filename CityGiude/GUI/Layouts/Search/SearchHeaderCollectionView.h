//
//  BannerHeaderCollectionView.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 24/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchHeaderCollectionView : UICollectionReusableView

//@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

//@property (nonatomic, retain) NSArray *pageContent;
//@property (nonatomic, strong) UIPageViewController *pageController;
//@property (nonatomic, retain) NSTimer *pageTimer;
//
//-(void)configurePageViewController;
+ (NSString *)kind;
@property (weak, nonatomic) IBOutlet UIButton *btnShowMore;
@property (weak, nonatomic) IBOutlet UILabel *sectionTitleLabel;

@end
