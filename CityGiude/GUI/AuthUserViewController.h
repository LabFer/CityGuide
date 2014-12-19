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
#import "Places.h"

@interface AuthUserViewController : UIViewController <VKSdkDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) Places *aPlace;
@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (nonatomic) BOOL needToSetFavour;

- (IBAction)btnFBpressed:(id)sender;
- (IBAction)btnTWpressed:(id)sender;
- (IBAction)btnVKpressed:(id)sender;

- (IBAction)btnCancelPressed:(id)sender;

@end
