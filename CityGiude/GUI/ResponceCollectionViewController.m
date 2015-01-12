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
#import "ResponseViewController.h"
#import "AuthUserViewController.h"
#import "NothingView.h"

@implementation ResponceCollectionViewController{
    UIUserSettings *_userSettings;
    NothingView *_nView;
}


-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    _userSettings = [[UIUserSettings alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"placeID == %@", self.aPlace.placeID];
    NSLog(@"!!! Places predicate: %@", predicate);
    self.frcComments = [[DBWork shared] fetchedResultsController:kCoreDataCommentsEntity sortKey:@"date" predicate:predicate sectionName:nil delegate:self];
    
//    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    _userSettings = [[UIUserSettings alloc] init];
    
    [self setNavBarButtons];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kReceiveRemoteNotification
                                               object:appDelegate];
    
    if([self.frcComments fetchedObjects].count == 0){
        _nView = [[NothingView alloc] initWithFrame:CGRectMake(0, 0, 250.0f, 200.0f)];
        [_nView setInfoLabel:@"Отзывов пока нет.\nБудь первым, кто оставит отзыв"];
        [_nView showInView:self.tableView animated:YES];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveRemoteNotification object:nil];
    
    if(_nView){
        [_nView hideWithAnimation:YES];
        _nView = nil;
    }
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
    
    if([_userSettings isUserAuthorized]){
        [self performSegueWithIdentifier:@"segueFromResponseListToSendResponse" sender:self];
    }
    else{
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                          message:kCommentNeedAuth
                                                         delegate:self
                                                cancelButtonTitle:kAlertCancel
                                                otherButtonTitles:kAlertAuthEnter, nil];
        [message show];
    }
    
    
    
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
    
    NSString *urlStr = [NSString stringWithFormat:@"%@", comment.photo];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = cell.userPhoto.center;
    [cell addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    
    //cell.placeImage.image = [UIImage imageNamed:@"default50"];
    cell.userPhoto.contentMode = UIViewContentModeScaleAspectFill;
    [cell.userPhoto setImageWithURLRequest:[NSURLRequest requestWithURL:imgUrl]
                                      placeholderImage:[UIImage imageNamed:@"no_photo_user"]
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   
                                                   [activityIndicatorView removeFromSuperview];
                                                   
                                                   // do image resize here
                                                   
                                                   // then set image view
                                                   NSLog(@"Image downloaded");
                                                   cell.userPhoto.image = image;
                                               }
                                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   [activityIndicatorView removeFromSuperview];
                                                   NSLog(@"Fail to download image");
                                                   // do any other error handling you want here
                                               }];

    //[cell.userPhoto setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"photo"]];
    
    cell.userPhoto.layer.cornerRadius = kImageViewCornerRadius;
    cell.userPhoto.clipsToBounds = YES;
    
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

#pragma mark - Storyboard Navigation - Segue handler

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier] isEqualToString:@"segueFromResponseListToSendResponse"]){
        ResponseViewController *subVC = (ResponseViewController*)[segue destinationViewController];
        subVC.aPlace = self.aPlace;
        subVC.delegate = self;
    }
    
//    else if([[segue identifier] isEqualToString:@"segueFromResponcesListToAuth"]){
//        AuthUserViewController *subVC = (AuthUserViewController*)[segue destinationViewController];
//        subVC.delegate = self;
//        subVC.aPlace = self.aPlace;
//    }
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView: %@", alertView.message);
    
    if(buttonIndex != [alertView cancelButtonIndex]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        AuthUserViewController* auth = [storyboard instantiateViewControllerWithIdentifier:@"AuthUserViewController"];
        auth.delegate = self;
        [self presentViewController:auth animated:YES completion:nil];

        //[self performSegueWithIdentifier:@"segueFromResponcesListToAuth" sender:self];
    }
    
}

#pragma mark - Push Notification
-(void)didReceiveRemoteNotification:(NSNotification *)notification {
    // see http://stackoverflow.com/a/2777460/305149
    if (self.isViewLoaded && self.view.window) {
        // handle the notification
        [_userSettings showPushView:notification.userInfo inViewController:self];
    }
}


@end
