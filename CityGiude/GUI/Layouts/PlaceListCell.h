//
//  HouseListCell.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 12/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *placeImage;

@property (weak, nonatomic) IBOutlet UIImageView *mapMarkerImage;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *star1Image;
@property (weak, nonatomic) IBOutlet UIImageView *star2Image;
@property (weak, nonatomic) IBOutlet UIImageView *star3Image;
@property (weak, nonatomic) IBOutlet UIImageView *star4Image;
@property (weak, nonatomic) IBOutlet UIImageView *star5Image;

+ (NSString *)reuseId;

@end
