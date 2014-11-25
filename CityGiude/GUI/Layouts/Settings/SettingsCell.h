//
//  SettingsCell.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 23/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *settingTitle;
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;

- (IBAction)settingSwitchChanged:(id)sender;
+ (NSString *)reuseId;

@end
