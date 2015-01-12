//
//  BannerHeaderCollectionView.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 24/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "SearchHeaderCollectionView.h"
#import "Constants.h"

@implementation SearchHeaderCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configurePageViewController];
        
    }
    return self;
}

-(void)configurePageViewController{
    //NSLog(@"configurePageViewController");
    //self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
   // self.pageControl.pageIndicatorTintColor = [UIColor lightTextColor];
}

+ (NSString *)kind
{
    return kReuseSearchHeaderCollectionViewKind;
}

@end
