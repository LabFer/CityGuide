//
//  SettingsTableViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 23/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "UIUserSettings.h"
#import "Constants.h"

#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "MenuTableViewController.h"

#import "SettingsCell.h"
#import "AppDelegate.h"

@implementation SettingsTableViewController{
    UIUserSettings *_userSettings;
}



-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    _userSettings = [[UIUserSettings alloc] init];
    [self setNavBarButtons];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kReceiveRemoteNotification
                                               object:appDelegate];
    
    // ====== mmdrawer swipe gesture =======
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveRemoteNotification object:nil];
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuDrawerButtonPress:)];
    leftDrawerButton.tintColor = kDefaultNavItemTintColor;//[UIColor blueColor];
    
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    
    self.navigationItem.title = kNavigationTitleSettings;
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    
}

-(void)menuDrawerButtonPress:(id)sender{
    
    [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

#pragma mark - TableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SettingsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsCell reuseId]];
    
    switch(indexPath.row){
        case 0:
            cell.settingTitle.text = kSettingsNotification;
            [self configureSwitch:kSettingsNotification forCell:cell withIndexPath:indexPath];
            break;
        case 1:
            cell.settingTitle.text = kSettingsDiscount;
            [self configureSwitch:kSettingsDiscount forCell:cell withIndexPath:indexPath];
            break;
        case 2:
            cell.settingTitle.text = kSettingsFavour;
            [self configureSwitch:kSettingsFavour forCell:cell withIndexPath:indexPath];
            break;
        case 3:
            cell.settingTitle.text = kSettingsComments;
            [self configureSwitch:kSettingsComments forCell:cell withIndexPath:indexPath];
            break;
        default: break;
    }
    
    return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    //    //NSLog(@"Item selected: %@", self.frcPlaces.fetchedObjects[indexPath.row]);
    //    [self performSegueWithIdentifier:@"segueFromDiscountListToDiscountDetail" sender:indexPath];
    
}

-(void)switchChanged:(UISwitch*)settingSwitch{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *res = [NSNumber numberWithBool:settingSwitch.on];
    switch(settingSwitch.tag){
        case 0:
            [userDefaults setObject:res forKey:kSettingsNotification];
            break;
        case 1:
            [userDefaults setObject:res forKey:kSettingsDiscount];
            break;
        case 2:
            [userDefaults setObject:res forKey:kSettingsFavour];
            break;
        case 3:
            [userDefaults setObject:res forKey:kSettingsComments];
            break;
        default: break;
    }
    
    [userDefaults synchronize];
}

-(void)configureSwitch:(NSString*)title forCell:(SettingsCell*)cell withIndexPath:(NSIndexPath*)indexPath{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *value = [userDefaults objectForKey:title];
    cell.settingSwitch.on = (value) ? value.boolValue : NO;
    cell.settingSwitch.tag = indexPath.row;
    [cell.settingSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
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
