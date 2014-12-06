//
//  AboutUserViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "VKSdk.h"

@interface AuthUserViewController : UIViewController <VKSdkDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;


- (IBAction)btnFBpressed:(id)sender;
- (IBAction)btnTWpressed:(id)sender;
- (IBAction)btnVKpressed:(id)sender;


@end
