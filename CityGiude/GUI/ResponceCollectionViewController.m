//
//  ResponceCollectionViewController.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 25/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "ResponceCollectionViewController.h"
#import "UIUserSettings.h"
#import "SubCategoryListFlowLayout.h"
#import "Constants.h"
#import "UICollectionViewCell+AutoLayoutDynamicHeightCalculation.h"
#import "DBWork.h"
#import "Comments.h"
#import "UIImageView+AFNetworking.h"

@implementation ResponceCollectionViewController{
    UIUserSettings *_userSettings;
}


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    _userSettings = [[UIUserSettings alloc] init];
    
//    SubCategoryListFlowLayout *layout = [[SubCategoryListFlowLayout alloc] init];
//    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width;
//    layout.itemSize = CGSizeMake(sizeOfItems, 115.0f); //size of each cell
//    //[self.collectionView setCollectionViewLayout:layout];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"placeID == %@", self.aPlace.id];
    NSLog(@"!!! Places predicate: %@", predicate);
    self.frcComments = [[DBWork shared] fetchedResultsController:kCoreDataCommentsEntity sortKey:@"date" predicate:predicate sectionName:nil delegate:self];
    
//    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [self setNavBarButtons];
    
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupResponseButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button =====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.title = kNavigationTitleResponse;
    
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)responseButtonPressed{
     [self performSegueWithIdentifier:@"segueFromResponseListToSendResponse" sender:self];
}

#pragma mark UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.frcComments.fetchedObjects count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CommentListCell* cell = [self.tableView dequeueReusableCellWithIdentifier:[CommentListCell reuseId] forIndexPath:indexPath];
    
    [self configureCommentListCell:cell atIndexPath:indexPath];
    
    return cell;
}


-(void)configureCommentListCell:(CommentListCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Comments *comment = self.frcComments.fetchedObjects[indexPath.item];

    cell.userNameLabel.text = comment.name;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, comment.photo];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [cell.userPhoto setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"photo"]];
    
    cell.commentTextLabel.text = comment.text;
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:comment.date.doubleValue];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    cell.dateLabel.text = [dateFormatter stringFromDate:startDate];
    
    // ======= rate view =====
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"star_grey"];
    //self.rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"star_yellow"];
    cell.rateView.rating = comment.rating.floatValue;
    cell.rateView.editable = NO;
    cell.rateView.maxRating = 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return [self heightForBasicCellAtIndexPath:indexPath];
    
    [self configureCommentListCell:self.prototypeCell atIndexPath:indexPath];
    
    // Need to set the width of the prototype cell to the width of the table view
    // as this will change when the device is rotated.
    
    self.prototypeCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.prototypeCell.bounds));
    
    [self.prototypeCell layoutIfNeeded];
    
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

-(CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath*)indexPath{
    static CommentListCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:[CommentListCell reuseId]];
    });
    
    [self configureCommentListCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

-(CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell*)sizingCell{
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
}



-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

#pragma mark - Accessor
- (CommentListCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:[CommentListCell reuseId]];
    }
    return _prototypeCell;
}

//segueFromResponcesListToAuth

@end
