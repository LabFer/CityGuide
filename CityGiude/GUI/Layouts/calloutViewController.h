//
//  calloutViewController.h
//  CityGuide
//
//  Created by Timur Khazamov on 20.11.14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface calloutViewController : UIViewController

//@property (strong, nonatomic) IBOutlet UIView *calloutView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *distance;

@end
