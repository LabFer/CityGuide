//
//  AboutProgrammViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "AboutProgrammViewController.h"
#import "UIUserSettings.h"

@implementation AboutProgrammViewController{
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    
    [self showString];
    
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
    NSString *htmlString = @"<html><body>";
    htmlString = [htmlString stringByAppendingString:@"<h1>заголовок</h1><table style=\"width:100%%\"><tr><td style=\"text-align:left\">lll</td><td style=\"text-align: right\">rrr</td></tr><tr><td colspan=2><img src=\"\" style=\"width:100%\"/></td></tr></table><div>остальной текст с разбивкой если надо на параграфы</div>"];
    htmlString = [htmlString stringByAppendingString:@"</body></html>"];
    // UIWebView uses baseURL to find style sheets, images, etc that you include in your HTML.
    NSURL *bundleUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    [self.aboutWebView loadHTMLString:htmlString baseURL:bundleUrl];
}

@end
