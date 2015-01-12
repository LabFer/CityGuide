//
//  PlaceDetailedMainCell.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 28/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCell : UITableViewCell

//@property (weak, nonatomic) IBOutlet UILabel *adressLabel;
//@property (weak, nonatomic) IBOutlet UILabel *workTimeLabel;
//@property (weak, nonatomic) IBOutlet UIButton *btnPhone;
//@property (weak, nonatomic) IBOutlet UIButton *btnSite;
//@property (weak, nonatomic) IBOutlet UIButton *btnSocial;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (nonatomic) CGFloat cellHeight;

+ (NSString *)reuseId;
@end
