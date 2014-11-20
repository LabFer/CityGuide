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
@property (weak, nonatomic) IBOutlet UILabel *placeName;
@property (weak, nonatomic) IBOutlet UILabel *placeCategory;
@property (weak, nonatomic) IBOutlet UIImageView *placeImage;
@property (weak, nonatomic) IBOutlet UITextView *placeTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeAdress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeWorkTime;
@property (weak, nonatomic) IBOutlet UILabel *placePhones;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeSite;



@end
