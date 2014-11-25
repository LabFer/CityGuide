//
//  UIUserSettings.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 10/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "UIUserSettings.h"


@implementation UIUserSettings

-(UIPresentationMode)getPresentationMode{
    
    UIPresentationMode mode = UICatalogList;
    
    NSString *modeStr = [[NSUserDefaults standardUserDefaults] objectForKey:kPresentationMode];
    if(modeStr){
        if([modeStr isEqualToString:kPresentationModeList]){
            mode = UICatalogList;
        }
        else if([modeStr isEqualToString:kPresentationModeTile]){
            mode = UICatalogTile;
        }
    }
    
    return mode;
}

-(void)setPresentationMode:(UIPresentationMode)presentationMode{
    
    if(presentationMode == UICatalogTile)
        [[NSUserDefaults standardUserDefaults] setObject:kPresentationModeTile forKey:kPresentationMode];
    else
        [[NSUserDefaults standardUserDefaults] setObject:kPresentationModeList forKey:kPresentationMode];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(UIBarButtonItem*)setupRightButtonItem:(UIViewController*)viewController{
    
    UIPresentationMode mode = [self getPresentationMode];
    UIImage *btnImg = (mode == UICatalogList) ? [UIImage imageNamed:@"navbar_tiles"] : [UIImage imageNamed:@"navbar_list"];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithImage:btnImg style:UIBarButtonItemStylePlain target:viewController action:@selector(rightBarButtonPressed)];
    
    return rightBtn;
}

-(UIBarButtonItem*)setupBackButtonItem:(UIViewController*)viewController{
    UIImage *btnImg = [UIImage imageNamed:@"navbar_back"];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:btnImg style:UIBarButtonItemStylePlain target:viewController action:@selector(goBack)];
    
    return backBtn;
}

-(UIBarButtonItem*)setupFilterButtonItem:(UIViewController*)viewController{
    UIImage *btnImg = [UIImage imageNamed:@"navbar_filter"];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:btnImg style:UIBarButtonItemStylePlain target:viewController action:@selector(filterButtonPressed)];
    
    return backBtn;
}

-(UIBarButtonItem*)setupMapMarkerButtonItem:(UIViewController*)viewController{
    UIImage *btnImg = [UIImage imageNamed:@"navbar_mapmarker"];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:btnImg style:UIBarButtonItemStylePlain target:viewController action:@selector(mapButtonPressed)];
    
    return backBtn;
}

-(UIBarButtonItem*)setupCancelButtonItem:(UIViewController*)viewController{
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:viewController action:@selector(cancelButtonPressed)];
    
    return cancelBtn;
}

-(UIBarButtonItem*)setupConfirmButtonItem:(UIViewController*)viewController{
    
    UIBarButtonItem *confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"ОК" style:UIBarButtonItemStylePlain target:viewController action:@selector(confirmButtonPressed)];
    
    return confirmBtn;
}

-(UIBarButtonItem*)setupResponseButtonItem:(UIViewController*)viewController{
    
    UIImage *btnImg = [UIImage imageNamed:@"navbar_response"];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:btnImg style:UIBarButtonItemStylePlain target:viewController action:@selector(responseButtonPressed)];
    
    return backBtn;
}



@end
