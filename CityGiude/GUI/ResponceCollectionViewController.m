//
//  ResponceCollectionViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 25/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "ResponceCollectionViewController.h"
#import "UIUserSettings.h"
#import "SubCategoryListFlowLayout.h"
#import "Constants.h"
#import "PlaceListCell.h"

@implementation ResponceCollectionViewController{
    UIUserSettings *_userSettings;
}


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    _userSettings = [[UIUserSettings alloc] init];
    
    SubCategoryListFlowLayout *layout = [[SubCategoryListFlowLayout alloc] init];
    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width;
    layout.itemSize = CGSizeMake(sizeOfItems, 115.0f); //size of each cell
    [self.collectionView setCollectionViewLayout:layout];
    
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self in %@", self.aCategory.places];
//    NSLog(@"Places predicate: %@", predicate);
//    self.frcPlaces = [[DBWork shared] fetchedResultsController:kCoreDataPlacesEntity sortKey:@"sort" predicate:predicate sectionName:nil delegate:self];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [self setNavBarButtons];
    
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupResponseButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button =====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.title = kNavigationTitleResponse;
    
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)responseButtonPressed{
     [self performSegueWithIdentifier:@"segueFromResponseListToSendResponse" sender:self];
}

#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return [[JournalData shared].books numberOfsections];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 10;//[self.frcPlaces.fetchedObjects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PlaceListCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[PlaceListCell reuseId] forIndexPath:indexPath];
    
    [self configurePlaceListCell:(PlaceListCell *)cell atIndexPath:indexPath];
    
    //NSLog(@"MainViewController indexPath: %li", indexPath.item);
    //    cell.layer.shouldRasterize = YES;
    //    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    return cell;
}

-(void)configurePlaceListCell:(PlaceListCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    //Places *place = self.frcPlaces.fetchedObjects[indexPath.row];
    //[cell.titleLabel setText:place.name];
    cell.mapMarkerImage.hidden = YES;
}

#pragma mark - CollectionViewDelegate
-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
   
}



@end
