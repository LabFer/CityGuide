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

@interface AboutCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *aboutPlaceTextView;
@property (weak, nonatomic) IBOutlet UIButton *showAllBtn;

+ (NSString *)reuseId;
@end
