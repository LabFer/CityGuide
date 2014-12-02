//
//  HouseListCell.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 12/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@protocol FavourPlaceListCellDelegate <NSObject>
@optional
- (void)btnDeletePressed:(id)sender forCell:(UICollectionViewCell *)cell;
@end

@interface FavourPlaceListCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeImage;

@property (weak, nonatomic) IBOutlet UIImageView *mapMarkerImage;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UIView *cellContentView;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipe;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;

- (IBAction)brnDeletePressed:(id)sender;

@property (weak, nonatomic) id<FavourPlaceListCellDelegate> delegate;

+ (NSString *)reuseId;

@end
