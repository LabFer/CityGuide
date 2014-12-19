//
//  HouseDetailViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 12/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Places.h"

#import "PlaceDetailedMainCell.h"
#import "PlaceDetailedMainCellNoImage.h"
#import "RatingCell.h"
#import "PPImageScrollingTableViewCell.h"
#import "AboutCell.h"
#import "ShareCell.h"
#import "InfoCell.h"
#import "CommonCell.h"
#import "VKSdk.h"

//#import "SHKSharerDelegate.h"

@interface PlaceDetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, VKSdkDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) PlaceDetailedMainCell *prototypeMainCell;
@property (nonatomic, strong) PlaceDetailedMainCellNoImage *prototypeMainCellNoImage;

@property (nonatomic, strong) Places *aPlace;
@property (strong, nonatomic) NSArray *images;

-(void)setPlaceToFavour;

@end
