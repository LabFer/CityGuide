//
//  SubCategoryCollectionViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 11/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "SubCategoryCollectionViewController.h"
#import "UIUserSettings.h"
#import "PlaceViewController.h"

#import "CategoryCell.h"
#import "CategoryListCell.h"
#import "DBWork.h"

#import "MainViewController.h"
#import "CategoryTileFlowLayout.h"
#import "CategoryListFlowLayout.h"
#import "AuthUserViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+MMDrawerController.h"


@implementation SubCategoryCollectionViewController{
    UIUserSettings *_userSettings;
    NSString *_sortKeys;
    SubCategoryTileFlowLayout *_tileLayout;
    SubCategoryListFlowLayout *_listLayout;
}

-(void)viewDidLoad{
    
    // ============== CollectionView Settings ===========
    _userSettings = [[UIUserSettings alloc] init];

    [super viewDidLoad];
    
    
    // ======== Set CoreData =======
    NSString *str = [NSString stringWithFormat:@"parent_id == %@", self.aCategory.categoryID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
    _sortKeys = @"sort,name";
    self.frcCategories = [[DBWork shared] fetchedResultsController:kCoreDataCategoriesEntity sortKey:_sortKeys predicate:predicate sectionName:nil delegate:self];
    
    _tileLayout = [[SubCategoryTileFlowLayout alloc] init];
    if(IS_IPAD){
        _tileLayout.numberOfColumns = 4;
        _tileLayout.itemSize = CGSizeMake(160.0f, 160.0f); //size of each cell
        _tileLayout.sectionInset = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    }
    
    _listLayout = [[SubCategoryListFlowLayout alloc] init];
    
    if(IS_IPAD){
        CGFloat screenSize = [UIScreen mainScreen].bounds.size.width;
        _listLayout.numberOfColumns = 2;
        _listLayout.itemSize = CGSizeMake(screenSize/2, 80.0f); //size of each cell
    }

    if([_userSettings getPresentationMode] == UICatalogTile){
        [self.collectionView setCollectionViewLayout:_tileLayout];
    }
    else{
        [self.collectionView setCollectionViewLayout:_listLayout];
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self setNavBarButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    //слушаю PUSH-notification
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
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupRightButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;

    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button ======
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.title = self.aCategory.name;
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // ====== mmdrawer swipe gesture =======
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    //[self.mm_drawerController setCloseDrawerGestureModeMask:MMOpenDrawerGestureModeNone];

    

}

-(void)rightBarButtonPressed{
    
    MainViewController *main = (MainViewController*)self.delegate;
    
    if([_userSettings getPresentationMode] == UICatalogList){
        [self.collectionView setCollectionViewLayout:_tileLayout];
        [_userSettings setPresentationMode:UICatalogTile];
        
        //[main.catalogCollectionView setCollectionViewLayout:_listLayout];
    }
    else{
        [self.collectionView setCollectionViewLayout:_listLayout];
        [_userSettings setPresentationMode:UICatalogList];
        
        //[main.catalogCollectionView setCollectionViewLayout:_tileLayout];
    }
    
    [main setCollectionViewLayout];
    [self.collectionView reloadData];
    //[main.catalogCollectionView reloadData]; //updates data in MainViewController

    self.navigationItem.rightBarButtonItem = [_userSettings setupRightButtonItem:self];
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return [[JournalData shared].books numberOfsections];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [self.frcCategories.fetchedObjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = nil;
    
    //NSLog(@"MainViewController indexPath: %li", indexPath.item);
    
    if([_userSettings getPresentationMode] == UICatalogList){
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[CategoryListCell reuseId] forIndexPath:indexPath];
        [self configureCategoryListCell:(CategoryListCell *)cell atIndexPath:indexPath];
    }
    else{
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[CategoryTileCell reuseId] forIndexPath:indexPath];
        [self configureCategoryTileCell:(CategoryTileCell *)cell atIndexPath:indexPath];
    }
    
    //
    //    cell.layer.shouldRasterize = YES;
    //    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    return cell;
}

-(void)configureCategoryListCell:(CategoryListCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Categories *category = self.frcCategories.fetchedObjects[indexPath.item];
    
    
    NSAttributedString *countStr = [[NSAttributedString alloc]
                                    initWithString:[NSString stringWithFormat:@" (%lu)", (unsigned long)category.places.count]
                                    attributes:@{
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14.0f],
                                                 NSStrokeColorAttributeName : [UIColor blackColor]}]; //1
    
    NSMutableAttributedString *nameStr = [[NSMutableAttributedString alloc]
                                    initWithString:category.name
                                    attributes:@{
                                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f],
                                                 NSStrokeColorAttributeName : [UIColor blackColor]}]; //1
    
    [nameStr appendAttributedString:countStr];    
    [cell.labelCategoryName setAttributedText:nameStr];
    
    //[cell.labelCategoryName setText:category.name];
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, category.photo];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = cell.imageViewCategoryIcon.center;
    [cell addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    
    //cell.placeImage.image = [UIImage imageNamed:@"default50"];
    [cell.imageViewCategoryIcon setImageWithURLRequest:[NSURLRequest requestWithURL:imgUrl]
                                      placeholderImage:[UIImage imageNamed:@"no_photo"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   
                                                   [activityIndicatorView removeFromSuperview];
                                                   
                                                   // do image resize here
                                                   
                                                   // then set image view
                                                   NSLog(@"Image downloaded");
                                                   cell.imageViewCategoryIcon.image = image;
                                               }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   [activityIndicatorView removeFromSuperview];
                                                   NSLog(@"Fail to download image");
                                                   // do any other error handling you want here
                                               }];
    
    
    
    [cell.btnCellHeart addTarget:self action:@selector(collectionViewCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if([[DBWork shared] isCategoryFavour:category.categoryID])
        [cell.btnCellHeart setImage:[UIImage imageNamed:@"active_heart"] forState:UIControlStateNormal];
    else
        [cell.btnCellHeart setImage:[UIImage imageNamed:@"inactive_heart"] forState:UIControlStateNormal];
}

-(void)configureCategoryTileCell:(CategoryTileCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Categories *category = self.frcCategories.fetchedObjects[indexPath.item];
    [cell.labelCategoryName setText:category.name];
    
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, category.photo];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = cell.imageViewCategoryIcon.center;
    [cell addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    
    //cell.placeImage.image = [UIImage imageNamed:@"default50"];
    [cell.imageViewCategoryIcon setImageWithURLRequest:[NSURLRequest requestWithURL:imgUrl]
                                      placeholderImage:[UIImage imageNamed:@"no_photo"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   
                                                   [activityIndicatorView removeFromSuperview];
                                                   
                                                   // do image resize here
                                                   
                                                   // then set image view
                                                   NSLog(@"Image downloaded");
                                                   cell.imageViewCategoryIcon.image = image;
                                               }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   [activityIndicatorView removeFromSuperview];
                                                   NSLog(@"Fail to download image");
                                                   // do any other error handling you want here
                                               }];
    
    
    [cell.btnCellHeart addTarget:self action:@selector(collectionViewCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if([[DBWork shared] isCategoryFavour:category.categoryID])
        [cell.btnCellHeart setImage:[UIImage imageNamed:@"active_heart"] forState:UIControlStateNormal];
    else
        [cell.btnCellHeart setImage:[UIImage imageNamed:@"inactive_heart"] forState:UIControlStateNormal];
}

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"segueFromSubcategoryToHouse" sender:indexPath];
}

#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromSubcategoryToHouse"]){
        PlaceViewController *placeVC = (PlaceViewController*)[segue destinationViewController];
        
        NSIndexPath *idx = (NSIndexPath*)sender;
        
        placeVC.aCategory = self.frcCategories.fetchedObjects[idx.item];
        
    }

}

#pragma mark - Button Handlers

- (IBAction)collectionViewCellButtonPressed:(UIButton *)button{
    
    //Acccess the cell
    UICollectionViewCell *cell = (UICollectionViewCell*)button.superview.superview;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    Categories *category = self.frcCategories.fetchedObjects[indexPath.item];
    //NSLog(@"button pressed: %@, %@", indexPath, category.name);
    
    if([[DBWork shared] isCategoryFavour:category.categoryID]){
        [[DBWork shared] removeCategoryFromFavour:category.categoryID];
    }
    else{
        if([_userSettings isUserAuthorized]){
            [self setCategoryToFavour:category];
        }
        else{
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                              message:kFavourNeedAuth
                                                             delegate:self
                                                    cancelButtonTitle:kAlertCancel
                                                    otherButtonTitles:kAlertAuthEnter, nil];
            [message show];
        }
    }
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
    
    //NSString *title = self.strings[indexPath.row];
    
    //self.someLabel.text = title;
    
}

-(void)setCategoryToFavour:(Categories*)category{
    [[DBWork shared] setCategoryToFavour:category.categoryID];
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView: %@", alertView.message);
    
    if(buttonIndex != [alertView cancelButtonIndex]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        AuthUserViewController* auth = [storyboard instantiateViewControllerWithIdentifier:@"AuthUserViewController"];
        auth.delegate = self;
        auth.needToSetFavour = YES;
        [self presentViewController:auth animated:YES completion:nil];
        
        //[self performSegueWithIdentifier:@"segueFromResponcesListToAuth" sender:self];
    }
    
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
