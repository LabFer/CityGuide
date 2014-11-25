//
//  FilterViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 21/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "FilterViewController.h"
#import "FilterCommonCell.h"
#import "FilterListCell.h"
#import "UIUserSettings.h"
#import "Constants.h"

@implementation FilterViewController{
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _userSettings = [[UIUserSettings alloc] init];
    [self setNavBarButtons];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    //    LeftSideBarViewController *lc =  (LeftSideBarViewController *)self.mm_drawerController.leftDrawerViewController;
    //    lc.previousDisplayMode = UICatalog;
    //
    //    MMDrawerBarButtonItem *leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_left_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(leftDrawerButtonPress:)];
    //    leftDrawerButton.tintColor = [UIColor grayColor];
    //
    //    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
    //
    //    self.navigationController.navigationBar.topItem.title = kAppMainTitle;
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupConfirmButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupCancelButtonItem:self];// ====== setup back nav button =====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.title = kTitleFilter;
    
    
}

-(void)confirmButtonPressed{
    NSLog(@"confirmButtonPressed");
}

-(void)cancelButtonPressed{
    NSLog(@"cancelButtonPressed");
    [self goBack];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}
#pragma mark - TableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;
    
    if (indexPath.row < 3) {
        cell = [self.filtersTableView dequeueReusableCellWithIdentifier:[FilterCommonCell reuseId]];
        [self configureFilterCommonCell:(FilterCommonCell*)cell atIndexPath:indexPath];
    }
    else{
        cell = [self.filtersTableView dequeueReusableCellWithIdentifier:[FilterListCell reuseId]];
        [self configureFilterListCell:(FilterListCell*)cell atIndexPath:indexPath];
    }
    
    // Configure the cell...
    
    
    return cell;
}

- (void)configureFilterCommonCell:(FilterCommonCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            [cell.filterTitle setText:kFilterAllTime];
            break;
        case 1:
            [cell.filterTitle setText:kFilterWorkNow];
            break;
        case 2:
            [cell.filterTitle setText:kFilterWebsiteExists];
            break;
        default:
            break;
    }
    //Places *place = self.frcPlaces.fetchedObjects[indexPath.row];
    //
}

- (void)configureFilterListCell:(FilterListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    //Places *place = self.frcPlaces.fetchedObjects[indexPath.row];
    [cell.filterTitle setText:[NSString stringWithFormat:@"Фильтр: %li", indexPath.row]];
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self.placeTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //NSLog(@"Item selected: %@", self.frcPlaces.fetchedObjects[indexPath.row]);
    //[self performSegueWithIdentifier:@"segueFromHouseToHouseDetail" sender:indexPath];
    
}

@end
