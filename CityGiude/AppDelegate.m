//
//  AppDelegate.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <TwitterKit/TwitterKit.h>
#import "DBWork.h"

#import "VKSdk.h"
//#import "CBSHKConfigurator.h"
//#import "SHKConfiguration.h"


@interface AppDelegate (){
    int _connectionCount;
}
@end

@implementation AppDelegate

@synthesize netStatus, hostReach;

+(void)initialize{
    //configure iLink
    //[iLink sharedInstance].globalPromptForUpdate = NO; // If you don't want iLink to prompt user to update when the app is old
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UINavigationBar appearance] setBarTintColor:kDefaultNavBarColor];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0], NSFontAttributeName, nil]];
    
    NSLog(@"Cache directory: %@", CACHE_DIR);
    
    [[Twitter sharedInstance] startWithConsumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
    [Fabric with:@[CrashlyticsKit, [Twitter sharedInstance]]];
    
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.hostReach = [Reachability reachabilityForInternetConnection];
    [hostReach startNotifier];
    [self updateInterfaceWithReachability:self.hostReach];
    [Flurry startSession:@"7YMHS9T4DFJHF2RH59VQ"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [self openActiveSessionWithPermissions:nil allowLoginUI:NO];
    }
    
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[DBWork shared] saveContext];
}

#pragma mark - Push Notifications

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tmpToken = [userDefaults objectForKey:@"token"];
    
    if(tmpToken) {
        //NSLog(@"tmpToken: %@", tmpToken);
        return;
    }
    
    //NSLog(@"My token is: %@", deviceToken);
    
    NSString *tokenString = [NSMutableString stringWithString:
                             [[deviceToken description] uppercaseString]];
    
    tokenString = [[tokenString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //NSLog(@"Token: %@", tokenString);
    
    if (tokenString) {
        [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"token"];
    }
    
    _connectionCount = 0;
    NSString *urlFormat = @"%@?method=%@&token=%@&typeDevice=%@";
    NSURL *registrationURL = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, URL_API, @"putToken", tokenString, DEVICE_KEY]];
    NSLog(@"%@", registrationURL);
    
    NSMutableURLRequest *registrationRequest = [[NSMutableURLRequest alloc] initWithURL:registrationURL];
    [registrationRequest setHTTPMethod:@"POST"];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:registrationRequest delegate:self];
    [connection start];
    //NSLog(@"connection: %@", connection);
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"%@", response.description);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"connection: %@", connection);
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", str);
}


-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"Failed to get token with error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    NSLog(@"Received notification: %@", userInfo);
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:   (UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString   *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

-(BOOL)pushNotificationOnOrOff{
    
    BOOL pushEnabled=NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            pushEnabled=YES;
        }
        else
            pushEnabled=NO;
    }
    else
    {
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types & UIRemoteNotificationTypeAlert)
            pushEnabled=YES;
        else
            pushEnabled=NO;
    }
    
    return pushEnabled;
}

#pragma mark - Facebook Login
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    // attempt to extract a token from the url
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI{
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      
                // Create a NSDictionary object and set the parameter values.
                NSDictionary *sessionStateInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                  session, @"session",
                                                  [NSNumber numberWithInteger:status], @"state",
                                                  error, @"error", nil];
                                      
                // Create a new notification, add the sessionStateInfo dictionary to it and post it.
                [[NSNotificationCenter defaultCenter] postNotificationName:kFacebookNotification
                                                                    object:nil
                                                                    userInfo:sessionStateInfo];
                                      
                }];
}

#pragma mark - Reachability

- (void) updateInterfaceWithReachability:(Reachability*)curReach {
    
    self.netStatus = [curReach currentReachabilityStatus];
    
//    if([self.window.rootViewController isKindOfClass:[UINavigationController class]]){
//        UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
//        if([[nav visibleViewController] isKindOfClass:[ReadScreenController class]]){
//            return;
//        }
//    }
//    
//    if(self.netStatus != NotReachable && [[SyncEngine sharedEngine] allowUseInternetConnection]){
//        [[SyncEngine sharedEngine] startSync];
//        [[SyncEngine sharedEngine] downloadArticleFromServer];
//    }
//    else{
//        [[SyncEngine sharedEngine] reloadCollectionView];
//    }
}

- (void) reachabilityChanged:(NSNotification*)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

#pragma mark - iLink
- (void)iLinkDidFindiTunesInfo{
    NSLog(@"App local URL: %@", [iLink sharedInstance].iLinkGetAppURLforLocal );
    NSLog(@"App sharing URL: %@", [iLink sharedInstance].iLinkGetAppURLforSharing );
    NSLog(@"App rating URL: %@", [iLink sharedInstance].iLinkGetRatingURL );
    NSLog(@"App Developer URL: %@", [iLink sharedInstance].iLinkGetDeveloperURLforSharing);
    NSLog(@"App appStoreCountry: %@", [iLink sharedInstance].appStoreCountry);
    
    [[iLink sharedInstance] iLinkOpenDeveloperPage]; // Would open developer page on the App Store
    [[iLink sharedInstance] iLinkOpenAppPageInAppStoreWithAppleID:553834731]; // Would open a different app then the current, For example the paid version. Just put the Apple ID of that app.
}
@end
