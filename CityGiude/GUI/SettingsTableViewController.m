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

@implementation SettingsTableViewController{
    UIUserSettings *_userSettings;
}



-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    _userSettings = [[UIUserSettings alloc] init];
    
    

    
    
    [self setNavBarButtons];
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
            break;
        case 1:
            cell.settingTitle.text = kSettingsDiscount;
            break;
        case 2:
            cell.settingTitle.text = kSettingsFavour;
            break;
        case 3:
            cell.settingTitle.text = kSettingsComments;
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

@end
