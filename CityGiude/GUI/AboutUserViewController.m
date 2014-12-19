//
//  AboutUserViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "AboutUserViewController.h"
#import "UIUserSettings.h"
#import "Constants.h"

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuTableViewController.h"

#import "iLink.h"

@implementation AboutUserViewController{
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    //    MenuTableViewController *lc =  (MenuTableViewController *)self.mm_drawerController.leftDrawerViewController;
    //    lc.previousDisplayMode = UICatalog;
    
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuDrawerButtonPress:)];
    leftDrawerButton.tintColor = kDefaultNavItemTintColor;//[UIColor blueColor];
    
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    //    self.navigationController.navigationBar.topItem.title = kAppMainTitle;
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    
    if([_userSettings isUserAuthorized]){
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSDictionary *profile = [userDefault objectForKey:kSocialUserProfile];
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", [profile objectForKey:kSocialUserFirstName], [profile objectForKey:kSocialUserLastName]];
    }
    else{
    
        self.navigationItem.title = kNavigationTitleAboutUser;
    }
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    
}

-(void)menuDrawerButtonPress:(id)sender{
    //    if(_isSearchBarShown){
    //        [_searchView resignFirstResponder];
    //    }
    
    //    LeftSideBarViewController *lc =  (LeftSideBarViewController *)self.mm_drawerController.leftDrawerViewController;
    //    lc.delegate = self;
    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - Button Handlers
- (IBAction)btnResponcePressed:(id)sender {
    [[iLink sharedInstance] iLinkOpenRatingsPageInAppStore];
}

- (IBAction)btnMailPressed:(id)sender {
    [self sendEmail];
}

- (IBAction)btnAboutProgrammPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"segueFromAboutUserToAboutProgramm" sender:self];
}

#pragma mark - Send Email

-(void)sendEmail{
    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setSubject:kMailSubject];
        [mailController setToRecipients:[NSArray arrayWithObject:kMailAdress]];
        [self presentViewController:mailController animated:YES completion:nil];
    }
    else{
        //NSLog(@"Sorry, you need to setup email first");
        // ошибку не настроен почтовый аккаунт
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:kMailNoEmailAccount delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [av show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
