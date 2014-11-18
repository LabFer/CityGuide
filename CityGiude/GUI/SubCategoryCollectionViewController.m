//
//  SubCategoryCollectionViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 11/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "SubCategoryCollectionViewController.h"
#import "UIUserSettings.h"
#import "CategoryListFlowLayout.h"
#import "CategoryTileFlowLayout.h"
#import "SubCategoryListDataSource.h"
#import "SubCategoryTileDataSource.h"
#import "PlaceViewController.h"

#import "AppDelegate.h"


@implementation SubCategoryCollectionViewController{
    SubCategoryListDataSource *_listDataSource;
    SubCategoryTileDataSource *_tileDataSource;
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{
    
    // ============== CollectionView Settings ===========
    _userSettings = [[UIUserSettings alloc] init];
    _tileDataSource = [[SubCategoryTileDataSource alloc] initWithDelegate:self];
    _listDataSource = [[SubCategoryListDataSource alloc] initWithDelegate:self];
    
    NSLog(@"From Category: %@, %@", self.aCategory.id, self.aCategory.name);
    
    
    if([_userSettings getPresentationMode] == UICatalogTile){
        [self.collectionView setDataSource:_tileDataSource];
        //_tileDataSource.delegate = self;
        [self.collectionView setCollectionViewLayout:[[CategoryTileFlowLayout alloc] init]];
    }
    else{
        [self.collectionView setDataSource:_listDataSource];
        [self.collectionView setCollectionViewLayout:[[CategoryListFlowLayout alloc] init]];
    }
    
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    
    [self setNavBarButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupRightButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;

    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button ======
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.title = self.aCategory.name;
    
    // ====== setup statbar color ===========
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    

}

-(void)rightBarButtonPressed{
    
    if([_userSettings getPresentationMode] == UICatalogList){
        [self.collectionView setDataSource:_tileDataSource];
        //_tileDataSource.delegate = self;
        [self.collectionView setCollectionViewLayout:[[CategoryTileFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogTile];
    }
    else{
        [self.collectionView setDataSource:_listDataSource];
        [self.collectionView setCollectionViewLayout:[[CategoryListFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogList];
    }
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupRightButtonItem:self];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSLog(@"Item selected: %@", appDelegate.testArray[indexPath.item]);
    [self performSegueWithIdentifier:@"segueFromSubcategoryToHouse" sender:indexPath];
}

#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromSubcategoryToHouse"]){
        PlaceViewController *placeVC = (PlaceViewController*)[segue destinationViewController];
        
        NSIndexPath *idx = (NSIndexPath*)sender;
        
        placeVC.aCategory = ([_userSettings getPresentationMode] == UICatalogList) ? _listDataSource.itemsArray[idx.item] : _tileDataSource.itemsArray[idx.item];
        
    }

}


@end
