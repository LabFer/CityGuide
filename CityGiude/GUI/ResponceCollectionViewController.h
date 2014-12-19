//
//  ResponceCollectionViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 25/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Places.h"
#import "CommentListCell.h"

@interface ResponceCollectionViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) Places *aPlace;
@property (nonatomic, strong) NSFetchedResultsController *frcComments;

@property (nonatomic, strong) CommentListCell *prototypeCell;

@end
