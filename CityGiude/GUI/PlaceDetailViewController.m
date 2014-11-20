//
//  HouseDetailViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 12/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "PlaceMapViewController.h"
#import "UIUserSettings.h"
#import "Phones.h"
#import "Categories.h"

@implementation PlaceDetailViewController{
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{

    _userSettings = [[UIUserSettings alloc] init];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    
    [self setupPlaceInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupMapMarkerButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button ====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    self.navigationItem.title = self.aPlace.name;
    //NSLog(@"self.navigationItem.title = %@", self.aPlace);
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)mapButtonPressed{
    [self performSegueWithIdentifier:@"segueFromHouseDetailToHouseMap" sender:self];
}

#pragma mark - Place Details

-(void)setupPlaceInfo{
    self.placeName.text = self.aPlace.name;
    self.placeTextView.text = self.aPlace.decript;
    
    self.placeCategory.text = [self getStringCategories];
    self.placePhones.text = [self getStringPhones];
    
}

-(NSString*)getStringCategories{
    if([self.aPlace.category allObjects].count == 0)
        return @"";
    
    Categories *aCategory = [self.aPlace.category allObjects][0];
    NSMutableString *aStr =  [NSMutableString stringWithString:aCategory.name];
    
    for(int i = 1; i < [self.aPlace.category allObjects].count; i++){
        [aStr appendString:@", "];
        aCategory = [self.aPlace.category allObjects][i];
        [aStr appendString:aCategory.name];
        
    }
    
    return [NSString stringWithString:aStr];
}

-(NSString*)getStringPhones{
    if([self.aPlace.phones allObjects].count == 0)
        return @"";
    
    Phones *aPhone = [self.aPlace.phones allObjects][0];
    NSMutableString *aStr =  [NSMutableString stringWithString:aPhone.phone_number];
    
    for(int i = 1; i < [self.aPlace.phones allObjects].count; i++){
        [aStr appendString:@", "];
        aPhone = [self.aPlace.phones allObjects][i];
        [aStr appendString:aPhone.phone_number];
        
    }
    
    return [NSString stringWithString:aStr];
}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01f;
}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.backgroundColor = [UIColor clearColor];
    
//    if(indexPath.row == 1 || indexPath.row == 4 || indexPath.row == 12)
//        cell.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
//    else
//        cell.backgroundColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
//    
//    //    if(indexPath.row == 6){
//    //        //=========== add info bar ===========
//    //        NSString *story = @"Main_iPhone";
//    //        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:story bundle:nil];
//    //
//    //        CatalogInfoViewController *info = [storyboard instantiateViewControllerWithIdentifier:@"CatalogInfo"];
//    //        info.view.frame = CGRectMake(0, self.view.frame.size.height - 45, self.view.frame.size.width, 45);
//    //        info.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    //        info.view.backgroundColor = [UIColor lightGrayColor];
//    //        //	mainPagebar.delegate = self;
//    //
//    //        [self.view addSubview:info.view];
//    //        //[self.tableView addSubview:info.view];
//    //
//    //    }
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    //    if(indexPath.row == 2){
//    //        NSLog(@"kSubscriptionFree");
//    //        if(![[NSUserDefaults standardUserDefaults] boolForKey:kSubscriptionFree])
//    //            [[IAPHelper sharedInstance] buySubscription];//:kSubscriptionFree];
//    //    }
//    //    else
//    if(indexPath.row == 2){
//        [self reloadButtonPressed:self];
//    }
//    else if (indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 8 || indexPath.row == 9 || indexPath.row == 10){
//        NSString *articleID = [NSString stringWithFormat:@"%ld", indexPath.row - 4];
//        [self performSegueWithIdentifier:@"AboutScreen" sender:articleID];
//        // Your custom action here
//    }
//    else if(indexPath.row == 11){
//        [self sendEmail];
//    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSLog(@"prepareForSegue");
    if([[segue identifier] isEqualToString:@"segueFromHouseDetailToHouseMap"]){
        PlaceMapViewController *placeVC = (PlaceMapViewController*)[segue destinationViewController];
        //AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        NSLog(@"prepareForSegue: %@", self.aPlace);
        placeVC.mapPlace = self.aPlace;
        
        //subVC.navigationItem.title = appDelegate.testArray[idx.item];
        
    }
}

@end
