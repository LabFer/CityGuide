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
#import "BannerHeaderCollectionView.h"


@implementation SubCategoryCollectionViewController{
    UIUserSettings *_userSettings;
}

-(void)viewDidLoad{
    
    // ============== CollectionView Settings ===========
    _userSettings = [[UIUserSettings alloc] init];

    [super viewDidLoad];
    
    
    // ======== Set CoreData =======
    NSString *str = [NSString stringWithFormat:@"parent_id == %@", self.aCategory.id];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
    self.frcCategories = [[DBWork shared] fetchedResultsController:kCoreDataCategoriesEntity sortKey:@"sort" predicate:predicate sectionName:nil delegate:self];
    
    if([_userSettings getPresentationMode] == UICatalogTile){
        [self.collectionView setCollectionViewLayout:[[SubCategoryTileFlowLayout alloc] init]];
    }
    else{
        [self.collectionView setCollectionViewLayout:[[SubCategoryListFlowLayout alloc] init]];
    }
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self setNavBarButtons];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    

}

-(void)rightBarButtonPressed{
    
    if([_userSettings getPresentationMode] == UICatalogList){
        [self.collectionView setCollectionViewLayout:[[SubCategoryTileFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogTile];
    }
    else{
        [self.collectionView setCollectionViewLayout:[[SubCategoryListFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogList];
    }
    
    [self.collectionView reloadData];
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
    [cell.labelCategoryName setText:category.name];
}

-(void)configureCategoryTileCell:(CategoryTileCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Categories *category = self.frcCategories.fetchedObjects[indexPath.item];
    [cell.labelCategoryName setText:category.name];
}

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"segueFromSubcategoryToHouse" sender:indexPath];
}

//#pragma mark CollectionView Header
//-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    
//    //NSLog(@"CollectionView Header: %@", indexPath);
//        
//    BannerHeaderCollectionView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"BannerHeaderCollectionView" forIndexPath:indexPath];
//    return headerView;
//}

#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromSubcategoryToHouse"]){
        PlaceViewController *placeVC = (PlaceViewController*)[segue destinationViewController];
        
        NSIndexPath *idx = (NSIndexPath*)sender;
        
        placeVC.aCategory = self.frcCategories.fetchedObjects[idx.item];
        
    }

}


@end
