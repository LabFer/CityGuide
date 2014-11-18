//
//  CategoryCollectionViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 10/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "CategoryCollectionViewController.h"
#import "CategoryDataSource.h"
#import "CategoryTileFlowLayout.h"
#import "CategoryListFlowLayout.h"
#import "Constants.h"
#import "UIUserSettings.h"

@interface CategoryCollectionViewController (){
    CategoryDataSource *_dataSource;
    UIUserSettings *_userSettings;
}

@end

@implementation CategoryCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    // ============== CollectionView Settings ===========
    _dataSource = [[CategoryDataSource alloc] init];
    [self.collectionView setDataSource:_dataSource];
    
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    _dataSource.delegate = self;
    
    _userSettings = [[UIUserSettings alloc] init];
    
    if([_userSettings getPresentationMode] == UICatalogTile)
        [self.collectionView setCollectionViewLayout:[[CategoryTileFlowLayout alloc] init]];
    else
        [self.collectionView setCollectionViewLayout:[[CategoryListFlowLayout alloc] init]];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
