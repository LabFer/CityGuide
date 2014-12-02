//
//  PlaceDetailedMainCell.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 28/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnVK;
@property (weak, nonatomic) IBOutlet UIButton *btnFB;
@property (weak, nonatomic) IBOutlet UIButton *btnTW;
@property (weak, nonatomic) IBOutlet UIButton *btnMAIL;

+ (NSString *)reuseId;
@end
