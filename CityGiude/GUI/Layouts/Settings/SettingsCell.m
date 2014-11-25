//
//  SettingsCell.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 23/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "SettingsCell.h"
#import "Constants.h"

@implementation SettingsCell

- (IBAction)settingSwitchChanged:(id)sender {
    
    UITableView* tv = (UITableView*)self.superview.superview;
    NSIndexPath* idx = [tv indexPathForCell:self];
    NSLog(@"Settings pressed: %li", idx.row);
}

+ (NSString *)reuseId
{
    return kReuseSettingsCellID;
}

@end
