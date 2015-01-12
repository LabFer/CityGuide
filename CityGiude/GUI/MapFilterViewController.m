//
//  FilterViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 21/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "MapFilterViewController.h"
#import "FilterCommonCell.h"
#import "FilterListCell.h"
#import "UIUserSettings.h"
#import "Constants.h"
#import "NearMapViewController.h"

@implementation MapFilterViewController{
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    _userSettings = [[UIUserSettings alloc] init];
    [self setNavBarButtons];
    
    // ====== set textview ======
    
    self.keysTextView.layer.borderWidth = 1.0f;
    self.keysTextView.layer.borderColor = [[UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f] CGColor];
    self.keysTextView.layer.cornerRadius = kImageViewCornerRadius;
    
    self.keysTextView.text = kPlaceholderTextViewKeyWords;
    self.keysTextView.textColor = [UIColor lightGrayColor]; //optional
    
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
    
    if(![self.keysTextView.text isEqualToString:kPlaceholderTextViewKeyWords]){
        NSArray *searchTerms = [self.keysTextView.text componentsSeparatedByString:@" "];
        [self.filterDictionary setObject:searchTerms forKey:@"searchTerms"];
    }
    
    if([self.delegate isKindOfClass:[NearMapViewController class]]){
        NearMapViewController *mapVC = (NearMapViewController*)self.delegate;
        mapVC.filterDictionary = self.filterDictionary;
    }
    
    [self goBack];
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
    
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}
#pragma mark - TableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = nil;

    cell = [self.filtersTableView dequeueReusableCellWithIdentifier:[FilterCommonCell reuseId]];
    [self configureFilterCommonCell:(FilterCommonCell*)cell atIndexPath:indexPath];

    
    // Configure the cell...
    
    
    return cell;
}

- (void)configureFilterCommonCell:(FilterCommonCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    
    if(indexPath.row == 0){
        NSNumber *selectedItem = [self.filterDictionary objectForKey:kFilterAllTime];
        if(selectedItem){
            NSLog(@"selectedItem for %@ exist: %@", kFilterAllTime, selectedItem);
            [cell.filterCheck setSelectedSegmentIndex:selectedItem.integerValue];
        }
        else{
            NSLog(@"selectedItem for %@ exists", kFilterAllTime);
            [self.filterDictionary setObject:[NSNumber numberWithInteger:1] forKey:kFilterAllTime];
        }
        [cell.filterTitle setText:kFilterAllTime];
    }
    else if(indexPath.row == 1){
        NSNumber *selectedItem = [self.filterDictionary objectForKey:kFilterWorkNow];
        if(selectedItem){
            NSLog(@"selectedItem for %@ exist: %@", kFilterWorkNow, selectedItem);
            [cell.filterCheck setSelectedSegmentIndex:selectedItem.integerValue];
        }
        else{
            NSLog(@"selectedItem for %@ not exists", kFilterWorkNow);
            [self.filterDictionary setObject:[NSNumber numberWithInteger:1] forKey:kFilterWorkNow];
        }
        [cell.filterTitle setText:kFilterWorkNow];
    }
    else if(indexPath.row == 2){
        NSNumber *selectedItem = [self.filterDictionary objectForKey:kFilterWebsiteExists];
        if(selectedItem){
            NSLog(@"selectedItem for %@ exist: %@", kFilterWebsiteExists, selectedItem);
            [cell.filterCheck setSelectedSegmentIndex:selectedItem.integerValue];
        }
        else{
            NSLog(@"selectedItem for %@ not exist", kFilterWebsiteExists);
            [self.filterDictionary setObject:[NSNumber numberWithInteger:1] forKey:kFilterWebsiteExists];
        }
        [cell.filterTitle setText:kFilterWebsiteExists];
    }
    
    [cell.filterCheck addTarget:self action:@selector(segmentedConrolChanged:) forControlEvents:UIControlEventValueChanged];
    cell.filterCheck.tag = indexPath.row;
}

-(void)segmentedConrolChanged:(UISegmentedControl *)segment{
    
    if(segment.tag == 0){
        [self.filterDictionary setObject:[NSNumber numberWithInteger:segment.selectedSegmentIndex] forKey:kFilterAllTime];
    }
    else if(segment.tag == 1){
        [self.filterDictionary setObject:[NSNumber numberWithInteger:segment.selectedSegmentIndex] forKey:kFilterWorkNow];
        
    }
    else if(segment.tag == 2){
        [self.filterDictionary setObject:[NSNumber numberWithInteger:segment.selectedSegmentIndex] forKey:kFilterWebsiteExists];
        
    }
    
    NSLog(@"%ld, %ld", (long)segment.tag, (long)segment.selectedSegmentIndex);
    NSLog(@"filter: %@", self.filterDictionary);
}


-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[self.placeTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //NSLog(@"Item selected: %@", self.frcPlaces.fetchedObjects[indexPath.row]);
    //[self performSegueWithIdentifier:@"segueFromHouseToHouseDetail" sender:indexPath];
    
}

#pragma mark - Text View Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.keysTextView.text isEqualToString:kPlaceholderTextViewKeyWords]) {
        self.keysTextView.text = @"";
        self.keysTextView.textColor = [UIColor blackColor]; //optional
    }
    [self.keysTextView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.keysTextView.text isEqualToString:@""]) {
        self.keysTextView.text = kPlaceholderTextViewKeyWords;
        self.keysTextView.textColor = [UIColor lightGrayColor]; //optional
    }
    [self.keysTextView  resignFirstResponder];
}

@end
