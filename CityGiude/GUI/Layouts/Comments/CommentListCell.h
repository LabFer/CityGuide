//
//  CommentListCell.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 08/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"
#import "ALLabel.h"

@interface CommentListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userPhoto;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet RateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;

+ (NSString *)reuseId;
@end
