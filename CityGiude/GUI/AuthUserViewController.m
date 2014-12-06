//
//  AboutUserViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "AuthUserViewController.h"
#import "UIUserSettings.h"
#import "Constants.h"

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuTableViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <TwitterKit/TwitterKit.h>

static NSArray  * SCOPE = nil;
static NSString *const ALL_USER_FIELDS = @"id,first_name,last_name,photo_max";

@implementation AuthUserViewController{
    UIUserSettings *_userSettings;
}



-(void)viewDidLoad{
    
    _userSettings = [[UIUserSettings alloc] init];
    SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES];
    
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFBSessionStateChangeWithNotification:) name:kFacebookNotification object:nil];
    
    [self setNavBarButtons];
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuDrawerButtonPress:)];
    leftDrawerButton.tintColor = kDefaultNavItemTintColor;//[UIColor blueColor];
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupCancelButtonItem:self];// ====== setup back nav button =====
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.title = kNavigationTitleAuth;
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    
}

-(void)menuDrawerButtonPress:(id)sender{

    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

-(void)cancelButtonPressed{
    NSLog(@"cancelButtonPressed");
    //[self goBack];
    
    [self menuDrawerButtonPress:self];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Button Handlers


- (IBAction)btnFBpressed:(id)sender {
    
    NSLog(@"btnFBpressed");
    if([FBSession activeSession].state == FBSessionStateOpen) NSLog(@"FBSessionStateOpen");
    if([FBSession activeSession].state == FBSessionStateOpenTokenExtended) NSLog(@"FBSessionStateOpenTokenExtended");
    
    if ([FBSession activeSession].state != FBSessionStateOpen ||
        [FBSession activeSession].state != FBSessionStateOpenTokenExtended) {
        
        [self.appDelegate openActiveSessionWithPermissions:@[@"public_profile", @"email"] allowLoginUI:YES];
        
    }
    else{
        
    }
}

- (IBAction)btnTWpressed:(id)sender {
    NSLog(@"btnTWpressed");
    
    [[Twitter sharedInstance] logInWithCompletion:^
     (TWTRSession *session, NSError *error) {
         if (session) {
             [[[Twitter sharedInstance] APIClient] loadUserWithID:session.userID
                                                       completion:^(TWTRUser *user,
                                                                    NSError *error)
             {
                 // handle the response or error
                 if(error){
                     NSLog(@"Twitter get user error: %@", [error localizedDescription]);
                 }
                 else{
                     NSLog(@"Twitter user: %@", user.profileImageURL);
                     NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:0];
                     
                     [userProfile setObject:kSocialTwitterProfile forKey:kSocialType];
                     [userProfile setObject:user.name forKey:kSocialUserFirstName];
                     [userProfile setObject:@"" forKey:kSocialUserLastName];
                     [userProfile setObject:user.userID forKey:kSocialUserID];
                     [userProfile setObject:@"" forKey:kSocialUserEmail];
                     [userProfile setObject:user.profileImageURL forKey:kSocialUserPhoto];
                     
                     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                     [userDefaults setObject:userProfile forKey:kSocialUserProfile];
                     [userDefaults synchronize];
                     
                 }
             }];
             NSLog(@"Twitter signed in as %@", [session userName]);
         } else {
             NSLog(@"Twitter error: %@", [error localizedDescription]);
         }
     }];
    
}

- (IBAction)btnVKpressed:(id)sender {
    NSLog(@"btnVKpressed");
    [VKSdk initializeWithDelegate:self andAppId:kVkontakteID];
    if(![VKSdk wakeUpSession]){
        [self authorizeVK];
    }
    else{
        [self requestVkontakeUserProfile];
    }
}

#pragma mark - VK SDK Delegate
-(void)authorizeVK{
    [VKSdk authorize:SCOPE revokeAccess:YES];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
     [self authorizeVK];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    //[self startWorking];
    NSLog(@"vkSdkReceivedNewToken: %@", newToken);
    [self requestVkontakeUserProfile];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    NSLog(@"vkSdkShouldPresentViewController: %@", controller);
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    NSLog(@"vkSdkAcceptedUserToken: %@", token);
    
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
//    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)requestVkontakeUserProfile{
    VKRequest *request = [[VKApi users] get:@{ VK_API_FIELDS : ALL_USER_FIELDS }];
    [request executeWithResultBlock: ^(VKResponse *response) {
        NSDictionary *profile = (NSDictionary*)response.json[0];
        NSLog(@"requestVkontakeUserProfile Result: %@", profile);
        
        NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        [userProfile setObject:kSocialVKontakteProfile forKey:kSocialType];
        [userProfile setObject:[profile objectForKey:@"first_name"] forKey:kSocialUserFirstName];
        [userProfile setObject:[profile objectForKey:@"last_name"] forKey:kSocialUserLastName];
        [userProfile setObject:[profile objectForKey:@"id"] forKey:kSocialUserID];
        [userProfile setObject:@"" forKey:kSocialUserEmail];
        [userProfile setObject:[profile objectForKey:@"photo_max"] forKey:kSocialUserPhoto];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userProfile forKey:kSocialUserProfile];
        [userDefaults synchronize];
        
        
        
    } errorBlock: ^(NSError *error) {
        NSLog(@"requestVkontakeUserProfile Error: %@", error);
    }];
}

#pragma mark - Facebook Handlers
-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification{
    // Get the session, state and error values from the notification's userInfo dictionary.
    NSDictionary *userInfo = [notification userInfo];
    
    FBSessionState sessionState = [[userInfo objectForKey:@"state"] integerValue];
    NSError *error = [userInfo objectForKey:@"error"];
    
    // Handle the session state.
    // Usually, the only interesting states are the opened session, the closed session and the failed login.
    if (!error) {
        // In case that there's not any error, then check if the session opened or closed.
        if (sessionState == FBSessionStateOpen) {
            // The session is open. Get the user information and update the UI.
            [FBRequestConnection startWithGraphPath:@"me"
                                         parameters:@{@"fields": @"first_name, last_name, picture, email", @"redirect": @"0"}
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error) {
                                          NSLog(@"Facebookr data: %@", result);
                                          
                                          NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:0];
                                          
                                          [userProfile setObject:kSocialFacebookProfile forKey:kSocialType];
                                          [userProfile setObject:[result objectForKey:@"first_name"] forKey:kSocialUserFirstName];
                                          [userProfile setObject:[result objectForKey:@"last_name"] forKey:kSocialUserLastName];
                                          [userProfile setObject:[result objectForKey:@"id"] forKey:kSocialUserID];
                                          [userProfile setObject:[result objectForKey:@"email"] forKey:kSocialUserEmail];
                                          [userProfile setObject:[[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"] forKey:kSocialUserPhoto];
                                          
                                          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                          [userDefaults setObject:userProfile forKey:kSocialUserProfile];
                                          [userDefaults synchronize];

                                      }
                                      else{
                                          NSLog(@"%@", [error localizedDescription]);
                                      }
                                  }];
            
        }
        else if (sessionState == FBSessionStateClosed || sessionState == FBSessionStateClosedLoginFailed){
            // A session was closed or the login was failed or canceled. Update the UI accordingly.
        }
    }
    else{
        // In case an error has occured, then just log the error and update the UI accordingly.
        NSLog(@"Error: %@", [error localizedDescription]);
        
    }
}

@end
