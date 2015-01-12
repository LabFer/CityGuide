//
//  MenuTableViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 13/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mapbox.h"

@interface MenuTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate>

//@property (nonatomic, strong) NSMutableArray *navigationControllerArray;
//@property (weak, nonatomic) IBOutlet UIImageView *userPhotoImage;
//@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *authLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *authImage;
//@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *searchResultsCollectionView;

-(void)openMainViewController;

@end
