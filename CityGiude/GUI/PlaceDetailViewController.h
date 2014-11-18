//
//  HouseDetailViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 12/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Places.h"

@interface PlaceDetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Places *aPlace;

@end
