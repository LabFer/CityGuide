//
//  HouseListCell.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 12/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"

@interface PlaceListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeImage;

@property (weak, nonatomic) IBOutlet UIImageView *mapMarkerImage;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet RateView *rateView;

+ (NSString *)reuseId;

@end
