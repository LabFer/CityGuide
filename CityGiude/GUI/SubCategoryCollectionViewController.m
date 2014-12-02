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


@implementation SubCategoryCollectionViewController{
    UIUserSettings *_userSettings;
    NSString *_sortKeys;
}

-(void)viewDidLoad{
    
    // ============== CollectionView Settings ===========
    _userSettings = [[UIUserSettings alloc] init];

    [super viewDidLoad];
    
    
    // ======== Set CoreData =======
    NSString *str = [NSString stringWithFormat:@"parent_id == %@", self.aCategory.id];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
    _sortKeys = @"sort,name";
    self.frcCategories = [[DBWork shared] fetchedResultsController:kCoreDataCategoriesEntity sortKey:_sortKeys predicate:predicate sectionName:nil delegate:self];
    
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
    
    MainViewController *main = (MainViewController*)self.delegate;
    
    if([_userSettings getPresentationMode] == UICatalogList){
        [self.collectionView setCollectionViewLayout:[[SubCategoryTileFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogTile];
        
        [main.catalogCollectionView setCollectionViewLayout:[[CategoryTileFlowLayout alloc] init]];
    }
    else{
        [self.collectionView setCollectionViewLayout:[[SubCategoryListFlowLayout alloc] init]];
        [_userSettings setPresentationMode:UICatalogList];
        
        [main.catalogCollectionView setCollectionViewLayout:[[CategoryListFlowLayout alloc] init]];
    }
    
    [self.collectionView reloadData];
    [main.catalogCollectionView reloadData]; //updates data in MainViewController

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
    [cell.btnCellHeart addTarget:self action:@selector(collectionViewCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if(category.favour.boolValue)
        [cell.btnCellHeart setImage:[UIImage imageNamed:@"active_heart"] forState:UIControlStateNormal];
    else
        [cell.btnCellHeart setImage:[UIImage imageNamed:@"inactive_heart"] forState:UIControlStateNormal];
}

-(void)configureCategoryTileCell:(CategoryTileCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Categories *category = self.frcCategories.fetchedObjects[indexPath.item];
    [cell.labelCategoryName setText:category.name];
    [cell.btnCellHeart addTarget:self action:@selector(collectionViewCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if(category.favour.boolValue)
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
    
    //if(category.favour.boolValue)
    category.favour = [NSNumber numberWithBool:!category.favour.boolValue];
    [[DBWork shared] saveContext];
    
    [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil]];
    
    //NSString *title = self.strings[indexPath.row];
    
    //self.someLabel.text = title;
    
}


@end
