//
//  AboutUserViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AboutUserViewController : UIViewController <MFMailComposeViewControllerDelegate>
- (IBAction)btnResponcePressed:(id)sender;
- (IBAction)btnMailPressed:(id)sender;
- (IBAction)btnAboutProgrammPressed:(id)sender;


@end
