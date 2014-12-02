//
//  PlaceDetailedMainCell.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 28/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
+ (NSString *)reuseId;
@end
