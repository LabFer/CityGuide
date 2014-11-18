//
//  BannerContentViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserContentViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@property(nonatomic, strong) id dataObject;

@end
