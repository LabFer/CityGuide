//
//  PlaceDetailedMainCell.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 28/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VALabel.h"
#import "RateView.h"

@interface RatingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet VALabel *ratingCountLabel;

@property (weak, nonatomic) IBOutlet RateView *rateView;
+ (NSString *)reuseId;
@end
