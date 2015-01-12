//
//  UIUserSettings.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 10/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface UIUserSettings : NSObject

-(UIPresentationMode)getPresentationMode;
-(void)setPresentationMode:(UIPresentationMode)presentationMode;

-(UIBarButtonItem*)setupRightButtonItem:(UIViewController*)viewController;
-(UIBarButtonItem*)setupBackButtonItem:(UIViewController*)viewController;
-(UIBarButtonItem*)setupFilterButtonItem:(UIViewController*)viewController;
-(UIBarButtonItem*)setupMapMarkerButtonItem:(UIViewController*)viewController;
-(UIBarButtonItem*)setupCancelButtonItem:(UIViewController*)viewController;
-(UIBarButtonItem*)setupConfirmButtonItem:(UIViewController*)viewController;
-(UIBarButtonItem*)setupResponseButtonItem:(UIViewController*)viewController;

-(BOOL)isUserAuthorized;
-(void)showPushView:(NSDictionary *)userInfo inViewController:(UIViewController*)vc;
-(void)showOfflinePushView:(NSDictionary *)userInfo inViewController:(UIViewController *)vc;

@end
