//
//  FilterCommonCell.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 21/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Attributes.h"

@interface FilterCommonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *filterTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterCheck;
@property (strong, nonatomic) Attributes *anAttribute;

- (IBAction)filterValueChanged:(id)sender;

+ (NSString *)reuseId;

@end
