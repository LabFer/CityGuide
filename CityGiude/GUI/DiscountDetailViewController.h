//
//  DiscountDetailViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Discounts.h"

@interface DiscountDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *discountDetailWebView;

@property (nonatomic, strong) Discounts *aDiscount;

@end
