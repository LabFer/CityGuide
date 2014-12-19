//
//  MenuTableViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 13/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "MenuTableViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "UIImageView+AFNetworking.h"

#import "FavourViewController.h"
#import "Constants.h"
#import "UIUserSettings.h"

#import <FacebookSDK/FacebookSDK.h>
#import <TwitterKit/TwitterKit.h>
#import "VKSdk.h"

#import "AuthUserViewController.h"

@implementation MenuTableViewController{
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{

    [super viewDidLoad];
    
    self.navigationControllerArray = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",nil];
    _userSettings = [[UIUserSettings alloc] init];
    
    self.userPhotoImage.layer.cornerRadius = kImageViewCornerRadius;
    self.userPhotoImage.clipsToBounds = YES;
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if([_userSettings isUserAuthorized]){
        [self setAuthInformation];
        
    }
   
     [self.menuTableView reloadData];
}

#pragma mark - Authoruzation
-(void)setAuthInformation{

    
    if([_userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        [self.userPhotoImage setImageWithURL:[NSURL URLWithString:[userProfile objectForKey:kSocialUserPhoto]]];
        self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [userProfile objectForKey:kSocialUserFirstName], [userProfile objectForKey:kSocialUserLastName]];
        
        NSLog(@"User profile: %@", [userProfile objectForKey:kSocialType]);
    }
    else{
        NSLog(@"User profile does not exist!");
    }
    
    return;
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 1;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    // Return the number of rows in the section.
//    return 11;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
//    //NSLog(@"cellForRowAtIndexPath: %@", CellIdentifier);
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    return cell;
//}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 2){
        if([_userSettings isUserAuthorized]){
            self.userPhoto.hidden = NO;
            self.userNameLabel.hidden = NO;
            [self.authImage setImage:[UIImage imageNamed:@"menu_exit"]];
            self.authLabel.text = kAuthLogOut;
        }
        else{
            self.userPhoto.hidden = YES;
            self.userNameLabel.hidden = YES;
            [self.authImage setImage:[UIImage imageNamed:@"menu_login"]];
            self.authLabel.text = kAuthLogIn;
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0)
        return 20.0f;
    
    if(indexPath.row == 2){
        CGFloat userCellHeight = ([_userSettings isUserAuthorized]) ? 44.0f : 0.0f;
        return userCellHeight;
    }
    
    if(indexPath.row == 9){
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        //NSLog(@"cell Height = %f; screenHeihgt = %f", screenHeight - 9 * 44.0f - 20.0f, screenHeight);
        NSInteger showRows = ([_userSettings isUserAuthorized]) ? 9 : 8;
        return screenHeight - showRows * 44.0f - 20.0f;
    }
    
    return 44.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"didSelectRowAtIndexPath: %li", indexPath.row);
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //NSObject *navigationController = [self.navigationControllerArray objectAtIndex:indexPath.row];
    
    //if (![navigationController isKindOfClass:[UINavigationController class]]) {
    
        UIViewController *newViewController;
        
        switch (indexPath.row) {
            case 2:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AboutUserViewController"];
                break;
            case 3: //goto catalog screen
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                break;
            case 4: //goto catalog screen
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlaceViewController"];
                break;
            case 5:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DiscountListViewController"];
                break;
            case 6:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NearMapViewController"];
                break;
            case 7:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"FavourViewController"];
                break;
            case 8:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
                break; 
            case 10:
                if([_userSettings isUserAuthorized]){
                    [self userLogOut];
                    newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                }
                else{
                    newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                    AuthUserViewController* auth = [storyboard instantiateViewControllerWithIdentifier:@"AuthUserViewController"];
                    auth.delegate = self;
                    [self presentViewController:auth animated:YES completion:nil];

                    
                }
                break;
            default:
                break;
        }
        
        UINavigationController *navigationController = (UINavigationController *)[[UINavigationController alloc] initWithRootViewController:(UIViewController *)newViewController];
        
    //    [self.navigationControllerArray replaceObjectAtIndex:indexPath.row withObject:navigationController];
    //}
    //else{

    //}
    
    [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
}

#pragma mark - User Log Out
-(void)userLogOut{
    
    if([_userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *profile = [userDefaults objectForKey:kSocialUserProfile];
        
        if([[profile objectForKey:kSocialType] isEqualToString:kSocialFacebookProfile]){
            [self facebookLogOut];
            [userDefaults removeObjectForKey:kSocialUserProfile];
            [userDefaults synchronize];
        }
        else if([[profile objectForKey:kSocialType] isEqualToString:kSocialTwitterProfile]){
            [self twitterLogOut];
            [userDefaults removeObjectForKey:kSocialUserProfile];
            [userDefaults synchronize];
        }
        else if([[profile objectForKey:kSocialType] isEqualToString:kSocialVKontakteProfile]){
            [self vkontakteLogOut];
            [userDefaults removeObjectForKey:kSocialUserProfile];
            [userDefaults synchronize];
        }
        
    }
    
    [self.menuTableView reloadData];

}

-(void)facebookLogOut{
    NSLog(@"facebookLogOut");
    if ([FBSession activeSession].state == FBSessionStateOpen ||
        [FBSession activeSession].state == FBSessionStateOpenTokenExtended) {
        
        // Close an existing session.
        [[FBSession activeSession] closeAndClearTokenInformation];
        NSLog(@"User logged out facebook!");
        
        
    }
}

-(void)twitterLogOut{
    
     NSLog(@"twitterLogOut");
    [[Twitter sharedInstance] logOut];

}

-(void)vkontakteLogOut{
    
    NSLog(@"vkontakteLogOut");
    [VKSdk forceLogout];
}

-(void)openMainViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    UINavigationController *navigationController = (UINavigationController *)[[UINavigationController alloc] initWithRootViewController:(UIViewController *)newViewController];
    [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
//    [self.mm_drawerController setCenterViewController:navigationController withFullCloseAnimation:YES completion:nil];
}

@end
