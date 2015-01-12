//
//  UIUserSettings.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 10/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "UIUserSettings.h"
#import "DBWork.h"
#import "EstimateView.h"
#import "SyncEngine.h"
#import "PlaceDetailViewController.h"
#import "DiscountDetailViewController.h"


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

-(BOOL)isUserAuthorized{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
    //NSLog(@"isUserAuthorized: %@", userProfile);
    if(userProfile && ![[userProfile objectForKey:kSocialUserToken] isEqualToString:@""]){ // user has authorized
        //NSLog(@"isUserAuthorized: YES (%d)", YES);
        return YES;
    }
    
    //NSLog(@"isUserAuthorized: NO (%d)", NO);
    return NO;
}

-(void)showPushView:(NSDictionary *)userInfo inViewController:(UIViewController*)vc{
    NSLog(@"userInfo: %@", userInfo);
    NSLog(@"userInfo[alert]: %@", [userInfo objectForKey:@"alert"]);
    EstimateView *pushView = [[EstimateView alloc] initWithFrame:CGRectMake(0, 0, 320, 130)];
    [pushView setAlertText:[userInfo objectForKey:@"alert"]];
    
    NSString *type = [userInfo objectForKey:@"type"];
    NSNumber *parentID = [userInfo objectForKey:@"id"];
    [pushView setParentType:type];
    [pushView setParentID:parentID];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    if([type isEqualToString:@"event"]){
        Discounts *aCategory = [[DBWork shared] getDiscountByID:parentID];
        if(!aCategory){
            NSLog(@"Discount exists: %@, %@", parentID, aCategory);
            [[DBWork shared] getDiscountByID:parentID];
        }
        else{
            NSLog(@"No such discount: %@", parentID);
            [[SyncEngine sharedEngine] downloadDiscountItemFromServer:parentID];
        }
        
        NSNumber *value = [userDefaults objectForKey:kSettingsNotification];
        if(value.boolValue)
            [pushView showInView:vc animated:YES];
    }
    else if([type isEqualToString:@"place"]){
        Places *aPlace = [[DBWork shared] getPlaceByplaceID:parentID];
        if(!aPlace){
            NSLog(@"Place exists: %@, %@", parentID, aPlace);
            [[DBWork shared] getPlaceByplaceID:parentID];
        }
        else{
            NSLog(@"No such place: %@", parentID);
            [[SyncEngine sharedEngine] downloadPlaceItemFromServer:parentID];
        }
        
        NSNumber *value = [userDefaults objectForKey:kSettingsDiscount];
        if(value.boolValue)
            [pushView showInView:vc animated:YES];
    }

}

-(void)showOfflinePushView:(NSDictionary *)userInfo inViewController:(UIViewController *)vc{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    
    
    
    NSString *type = [userInfo objectForKey:@"type"];
    NSNumber *parentID = [userInfo objectForKey:@"id"];
    
    if([type isEqualToString:kAttributeParentPlace]){
        if(![vc isKindOfClass:[PlaceDetailViewController class]]){//если я на детальном экране, то просто закрываю PushView
            
            PlaceDetailViewController *pd = [storyboard instantiateViewControllerWithIdentifier:@"PlaceDetailViewController"];
            Places *aPlace = [[DBWork shared] getPlaceByplaceID:parentID];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Places: %@", aPlace] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [av show];
            
            if(aPlace){
                pd.aPlace = aPlace;
                [vc.navigationController pushViewController:pd animated:YES];
            }
        }
    }
    else{
        if(![vc isKindOfClass:[DiscountDetailViewController class]]){//если я на детальном экране, то просто закрываю PushView
            DiscountDetailViewController *pd = [storyboard instantiateViewControllerWithIdentifier:@"DiscountDetailViewController"];
            Discounts *aDiscount = [[DBWork shared] getDiscountByID:parentID];
            
            if(aDiscount){
                pd.aDiscount = aDiscount;
//                [pd setDetailImage];
//                UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Discounts: %@", aDiscount] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//                [av show];
                [vc.navigationController pushViewController:pd animated:YES];
            }
        }
    }
}



@end
