//
//  AboutProgrammViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "AboutProgrammViewController.h"
#import "UIUserSettings.h"
#import "AppDelegate.h"

@implementation AboutProgrammViewController{
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    
    [self showString];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kReceiveRemoteNotification
                                               object:appDelegate];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveRemoteNotification object:nil];
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button ====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    self.navigationItem.title = kNavigationTitleAboutProgramm;
    //NSLog(@"self.navigationItem.title = %@", self.aPlace);
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - WebView

- (void)showString
{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *article = [userDefaults objectForKey:@"article"];
    
    NSString *htmlString = @"<html><body>";
    if(article)
        htmlString = [htmlString stringByAppendingString:article];
    htmlString = [htmlString stringByAppendingString:@"</body></html>"];
    // UIWebView uses baseURL to find style sheets, images, etc that you include in your HTML.
    NSURL *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.aboutWebView loadHTMLString:htmlString baseURL:bundleUrl];
}

#pragma mark - Push Notification
-(void)didReceiveRemoteNotification:(NSNotification *)notification {
    // see http://stackoverflow.com/a/2777460/305149
    if (self.isViewLoaded && self.view.window) {
        // handle the notification
        [_userSettings showPushView:notification.userInfo inViewController:self];
    }
}


@end
