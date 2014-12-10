//
//  HouseDetailViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 12/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "PlaceMapViewController.h"
#import "PhotoBrowserViewController.h"
#import "UIUserSettings.h"
#import "Phones.h"
#import "Categories.h"
#import "DBWork.h"
#import "UIImageView+AFNetworking.h"

#import <TwitterKit/TwitterKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ResponceCollectionViewController.h"

static NSArray  * SCOPE = nil;

@implementation PlaceDetailViewController{
    UIUserSettings *_userSettings;
    BOOL _isExpanded;
    NSString *_testString;
}

-(void)viewDidLoad{

    _userSettings = [[UIUserSettings alloc] init];
    SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    NSLog(@"======= Gallery ====== : %lu", self.aPlace.gallery.count);
    
    [self configurePlaceGalleryPreview];
    
    //============ gesture recognizer =====
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    _isExpanded = NO;
    _testString = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. ==== Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation bar
-(void)setNavBarButtons{
    
    self.navigationItem.rightBarButtonItem = [_userSettings setupMapMarkerButtonItem:self]; // ====== setup right nav button ======
    self.navigationItem.rightBarButtonItem.tintColor = kDefaultNavItemTintColor;
    
    self.navigationItem.leftBarButtonItem = [_userSettings setupBackButtonItem:self];// ====== setup back nav button ====
    self.navigationItem.leftBarButtonItem.tintColor = kDefaultNavItemTintColor;
    self.navigationItem.title = self.aPlace.name;
    //NSLog(@"self.navigationItem.title = %@", self.aPlace);
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)mapButtonPressed{
    [self performSegueWithIdentifier:@"segueFromHouseDetailToHouseMap" sender:self];
}

#pragma mark - Place Details
-(void)configurePlaceGalleryPreview{
    
    NSMutableArray *imgArr = [[NSMutableArray alloc] initWithCapacity:0];
    for(Gallery *item in self.aPlace.gallery){
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, item.photo_small];
        NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSDictionary *imgDict = @{@"name":imgUrl, @"title":@""};
        [imgArr addObject:imgDict];
    }
    
    self.images = @[@{@"category": @"", @"images":imgArr}];
}

-(NSString*)getStringCategories{
    if([self.aPlace.category allObjects].count == 0)
        return @"";
    
    Categories *aCategory = [self.aPlace.category allObjects][0];
    NSMutableString *aStr =  [NSMutableString stringWithString:aCategory.name];
    
    for(int i = 1; i < [self.aPlace.category allObjects].count; i++){
        [aStr appendString:@", "];
        aCategory = [self.aPlace.category allObjects][i];
        [aStr appendString:aCategory.name];
        
    }
    
    return [NSString stringWithString:aStr];
}

-(NSString*)getStringPhones{
    if([self.aPlace.phones allObjects].count == 0)
        return @"";
    
    Phones *aPhone = [self.aPlace.phones allObjects][0];
    NSMutableString *aStr =  [NSMutableString stringWithString:aPhone.phone_number];
    
    for(int i = 1; i < [self.aPlace.phones allObjects].count; i++){
        [aStr appendString:@", "];
        aPhone = [self.aPlace.phones allObjects][i];
        [aStr appendString:aPhone.phone_number];
        
    }
    
    return [NSString stringWithString:aStr];
}

-(NSString *) stringByStrippingHTML {
    
    NSAttributedString *aString = [[NSAttributedString alloc] initWithData:[self.aPlace.decript dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    
    return aString.string;
}

- (CGFloat)textViewHeightForRowAtIndexPath: (NSIndexPath*)indexPath {
    
    UITextView *textView = [[UITextView alloc]init];
    textView.attributedText = [[NSAttributedString alloc] initWithString:[self configureAboutString] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]}];
    
    CGFloat textViewWidth = self.tableView.frame.size.width - 30; // - (trailing + leading)
    CGSize size = [textView sizeThatFits:CGSizeMake(textViewWidth, MAXFLOAT)];
    return size.height;
}

-(NSString*)configureAboutString{
    
    if(_isExpanded){
        return self.aPlace.decript;
    }
    
    NSString *aboutText = self.aPlace.decript;
    NSString *str = (aboutText.length > 200) ? [[aboutText substringToIndex:200] stringByAppendingString:@"..."] : aboutText;
    
    return str;
}

#pragma mark - TableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat cellHeight = 44.0f;
    if(indexPath.row == 0){
        if([self.aPlace.photo_big isEqualToString:@""] || !self.aPlace.photo_big){ // has no image
            [self configureMainNoImageCell:self.prototypeMainCellNoImage forRowAtIndexPath:indexPath];
            [self.prototypeMainCellNoImage layoutIfNeeded];
            CGSize size = [self.prototypeMainCellNoImage.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            cellHeight = size.height + 5;
            
        }
        else{ // has image
            [self configureMainImageCell:self.prototypeMainCell forRowAtIndexPath:indexPath];
            [self.prototypeMainCell layoutIfNeeded];
            CGSize size = [self.prototypeMainCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            cellHeight = size.height + 1;
        }
    }
    else if(indexPath.row == 1){
        cellHeight =  44.0f;
    }
    else if (indexPath.row == 2){
        cellHeight = ([self.aPlace.gallery count] == 0) ? 0.0f : 115.0f;
    }
    else if(indexPath.row == 3){
        cellHeight = [self textViewHeightForRowAtIndexPath:indexPath] + 8 + 10 + 44 + 10;
    }
    else if(indexPath.row == 4){
        cellHeight = 80.0f;
    }
    else if(indexPath.row == 5){
        cellHeight = 185.0f;
    }
    return cellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

#pragma mark - TableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0){
        if([self.aPlace.photo_big isEqualToString:@""] || !self.aPlace.photo_big){ // has no image
            cell = [self.tableView dequeueReusableCellWithIdentifier:[PlaceDetailedMainCellNoImage reuseId] forIndexPath:indexPath];
            [self configureMainNoImageCell:cell forRowAtIndexPath:indexPath];
            
        }
        else{ // has image
            cell = [self.tableView dequeueReusableCellWithIdentifier:[PlaceDetailedMainCell reuseId] forIndexPath:indexPath];
            [self configureMainImageCell:cell forRowAtIndexPath:indexPath];
        }
    }
    else if(indexPath.row == 1){
        cell = [self.tableView dequeueReusableCellWithIdentifier:[RatingCell reuseId] forIndexPath:indexPath];
        [self configureRatingCell:cell forRowAtIndexPath:indexPath];
        
    }
    else if(indexPath.row == 2){
        cell = [self.tableView dequeueReusableCellWithIdentifier:[PPImageScrollingTableViewCell reuseId] forIndexPath:indexPath];
        if([self.aPlace.gallery count] != 0)
            [self configureScrollingViewCell:cell forRowAtIndexPath:indexPath];
        
    }
    else if (indexPath.row == 3){
        cell = [self.tableView dequeueReusableCellWithIdentifier:[AboutCell reuseId] forIndexPath:indexPath];
        [self configureAboutCell:cell forRowAtIndexPath:indexPath];
        
    }
    else if (indexPath.row == 4){
        cell = [self.tableView dequeueReusableCellWithIdentifier:[ShareCell reuseId] forIndexPath:indexPath];
        [self configureShareCell:cell forRowAtIndexPath:indexPath];
        
    }
    else if (indexPath.row == 5){
        cell = [self.tableView dequeueReusableCellWithIdentifier:[InfoCell reuseId] forIndexPath:indexPath];
        [self configureInfoCell:cell forRowAtIndexPath:indexPath];
        
    }
    else if(indexPath.row == 6 || indexPath.row == 7){
        cell = [self.tableView dequeueReusableCellWithIdentifier:[CommonCell reuseId] forIndexPath:indexPath];
        [self configureCommonCell:cell forRowAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - Configure Cells
- (void)configureCommonCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[CommonCell class]]){
        CommonCell* detailCell = (CommonCell*)cell;
        detailCell.nameLabel.text = (indexPath.row == 6) ? kSettingsDiscount: kSettingsResponces;
    }
}

- (void)configureInfoCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[InfoCell class]]){
        InfoCell* detailCell = (InfoCell*)cell;
        detailCell.adressLabel.text = self.aPlace.address;
        detailCell.workTimeLabel.text = self.aPlace.work_time_description;
        
        [detailCell.btnPhone setTitle:[self getStringPhones] forState:UIControlStateNormal];
        [detailCell.btnPhone addTarget:self action:@selector(btnPhonePressed:) forControlEvents:UIControlEventTouchUpInside];
        detailCell.btnPhone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [detailCell.btnSite setTitle:self.aPlace.website forState:UIControlStateNormal];
        [detailCell.btnSite addTarget:self action:@selector(btnSitePressed:) forControlEvents:UIControlEventTouchUpInside];
        detailCell.btnSite.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        [detailCell.btnSocial setTitle:@"vk.com/place" forState:UIControlStateNormal];
        [detailCell.btnSocial addTarget:self action:@selector(btnSocialPressed:) forControlEvents:UIControlEventTouchUpInside];
        detailCell.btnSocial.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
}

- (void)configureShareCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[ShareCell class]]){
        ShareCell* detailCell = (ShareCell*)cell;
        [detailCell.btnFB addTarget:self action:@selector(btnFBPressed:) forControlEvents:UIControlEventTouchUpInside];
        [detailCell.btnVK addTarget:self action:@selector(btnVKPressed:) forControlEvents:UIControlEventTouchUpInside];
        [detailCell.btnTW addTarget:self action:@selector(btnTWPressed:) forControlEvents:UIControlEventTouchUpInside];
        [detailCell.btnMAIL addTarget:self action:@selector(btnMailPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
}


- (void)configureAboutCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[AboutCell class]]){
        AboutCell* detailCell = (AboutCell*)cell;
        detailCell.aboutPlaceTextView.text = [self configureAboutString];
        
        [detailCell.showAllBtn addTarget:self action:@selector(expandText:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *titleStr = _isExpanded ? kTextViewCollapse : kTextViewShowAll;
        [detailCell.showAllBtn setTitle:titleStr forState:UIControlStateNormal];
        if(self.aPlace.decript.length < 200)
            detailCell.showAllBtn.hidden = YES;
        
    }
}


- (void)configureMainImageCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[PlaceDetailedMainCell class]]){
        PlaceDetailedMainCell* detailCell = (PlaceDetailedMainCell*)cell;
        detailCell.placeTitle.text = self.aPlace.name;
        detailCell.placeSubTitle.text = [self getStringCategories];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, self.aPlace.photo_big];
        NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [detailCell.placeImage setImageWithURL:nil];
        [detailCell.placeImage setImageWithURL:imgUrl];
        
        if([[DBWork shared] isPlaceFavour:self.aPlace.id]){
            [detailCell.btnHeart setImage:[UIImage imageNamed:@"heart-active"] forState:UIControlStateNormal];
        }
        else{
            [detailCell.btnHeart setImage:[UIImage imageNamed:@"heart-inactive"] forState:UIControlStateNormal];
        }
        [detailCell.btnHeart addTarget:self action:@selector(btnHeartPressed:) forControlEvents:UIControlEventTouchUpInside];
        detailCell.userInteractionEnabled = YES;
        
        detailCell.placeImage.layer.cornerRadius = kImageViewCornerRadius;
        detailCell.placeImage.clipsToBounds = YES;
    }
}

- (void)configureMainNoImageCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[PlaceDetailedMainCellNoImage class]]){
        PlaceDetailedMainCellNoImage* detailCell = (PlaceDetailedMainCellNoImage*)cell;
        detailCell.placeTitle.text = self.aPlace.name;
        detailCell.placeSubTitle.text = [self getStringCategories];
        
        if(self.aPlace.favour.boolValue){
            [detailCell.btnHeart setImage:[UIImage imageNamed:@"active_heart"] forState:UIControlStateNormal];
        }
        else{
            [detailCell.btnHeart setImage:[UIImage imageNamed:@"inactive_heart"] forState:UIControlStateNormal];
        }
        
        [detailCell.btnHeart addTarget:self action:@selector(btnHeartPressed:) forControlEvents:UIControlEventTouchUpInside];
        detailCell.userInteractionEnabled = YES;
        

    }
}

- (void)configureRatingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[RatingCell class]]){
        RatingCell* detailCell = (RatingCell*)cell;
        detailCell.rateView.notSelectedImage = [UIImage imageNamed:@"star_grey"];
        detailCell.rateView.fullSelectedImage = [UIImage imageNamed:@"star_yellow"];
        detailCell.rateView.rating = self.aPlace.rate.floatValue;
        detailCell.rateView.editable = NO;
        detailCell.rateView.maxRating = 5;
        
        detailCell.ratingCountLabel.text = [NSString stringWithFormat:@"(%@)", self.aPlace.rate_count];
    }
}

- (void)configureScrollingViewCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[PPImageScrollingTableViewCell class]]){
        PPImageScrollingTableViewCell* detailCell = (PPImageScrollingTableViewCell*)cell;
        NSDictionary *cellData = [self.images objectAtIndex:0];
        [detailCell setScrollViewWidth:self.tableView.frame.size.width];
        [detailCell setImageData:cellData];
        //[detailCell setDelegate:self];
        [detailCell setCollectionViewBackgroundColor:[UIColor clearColor]];
    }
}


#pragma mark - Prototype Cells
- (PlaceDetailedMainCell *)prototypeMainCell
{
    if (!_prototypeMainCell)
    {
        _prototypeMainCell = [self.tableView dequeueReusableCellWithIdentifier:[PlaceDetailedMainCell reuseId]];
    }
    return _prototypeMainCell;
}

- (PlaceDetailedMainCellNoImage *)prototypeMainCellNoImage
{
    if (!_prototypeMainCellNoImage)
    {
        _prototypeMainCellNoImage = [self.tableView dequeueReusableCellWithIdentifier:[PlaceDetailedMainCellNoImage reuseId]];
    }
    return _prototypeMainCellNoImage;
}

#pragma mark - Storyboard Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSLog(@"prepareForSegue");
    if([[segue identifier] isEqualToString:@"segueFromHouseDetailToHouseMap"]){
        PlaceMapViewController *placeVC = (PlaceMapViewController*)[segue destinationViewController];
        placeVC.mapPlace = self.aPlace;
    }
    else if ([[segue identifier] isEqualToString:@"segueFromPlaceDetailToPhotoBrowser"]){
        PhotoBrowserViewController *placeVC = (PhotoBrowserViewController*)[segue destinationViewController];
        placeVC.aPlace = self.aPlace;
    }
    else if([[segue identifier] isEqualToString:@"segueFromPlaceDetailToResponces"]){
        ResponceCollectionViewController *cv = (ResponceCollectionViewController*)[segue destinationViewController];
        
        cv.aPlace = self.aPlace;
    }
}

#pragma mark - Button Handlers
-(void)btnPhonePressed:(UIButton*)btn{
    
    if(IS_IPAD) return; //iPad does not support calls
    if(self.aPlace.phones.count == 0) return; //if has no phone numbers do nothing
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:kActionSheetPhoneTitle
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for(Phones *phone in [self.aPlace.phones allObjects]){
        [actionSheet addButtonWithTitle:phone.phone_number];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:kActionSheetPhoneCancel];
    
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString *call = [NSString stringWithFormat:@"tel://%@", [actionSheet buttonTitleAtIndex:buttonIndex]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call]];
    NSLog(@"ActionSheet pressed: %@", call);
}

-(void)btnSitePressed:(UIButton*)btn{
    NSString *web = [NSString stringWithFormat:@"http://%@", btn.titleLabel.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:web]];
    NSLog(@"Goto website: %@", web);
}

-(void)btnSocialPressed:(UIButton*)btn{
    NSString *web = [NSString stringWithFormat:@"http://%@", btn.titleLabel.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:web]];
    NSLog(@"Goto social: %@", web);
}

-(void)btnFBPressed:(UIButton*)btn{
    NSLog(@"btnFBPressed");

    // Check if the Facebook app is installed and we can present the share dialog
    
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:nil
                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                          if(error) {
                                              // An error occurred, we need to handle the error
                                              // See: https://developers.facebook.com/docs/ios/errors
                                              NSLog(@"Error publishing story: %@", error.description);
                                          } else {
                                              // Success
                                              NSLog(@"result %@", results);
                                          }
                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:nil
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User cancelled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }

}

-(void)btnVKPressed:(UIButton*)btn{
    
    [VKSdk initializeWithDelegate:self andAppId:kVkontakteID];
    
    [VKSdk initializeWithDelegate:self andAppId:kVkontakteID];
    if(![VKSdk wakeUpSession]){
        [self authorizeVK];
    }
    else{
        [self showVkontakteShareController];
    }
}

-(void)btnTWPressed:(UIButton*)btn{
    NSLog(@"btnTWPressed");

    TWTRComposer *composer = [[TWTRComposer alloc] init];
    [composer showWithCompletion:^(TWTRComposerResult result) {
        if (result == TWTRComposerResultCancelled) {
            NSLog(@"Tweet composition cancelled");
        }
        else {
            NSLog(@"Sending Tweet!");
        }
    }];
}

-(void)btnMailPressed:(UIButton*)btn{
    [self sendEmail];
}

-(void)expandText:(UIButton*)btn{

    if(self.aPlace.decript.length < 200) return;
    
    UITableViewCell *cell = (UITableViewCell *)btn.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Expand Text Pressed: %@, %@", cell, indexPath);

    [self.tableView beginUpdates]; // This will cause an animated update of
    _isExpanded = !_isExpanded;
    
    if(_isExpanded)
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    else
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (IBAction)btnHeartPressed:(id)sender {
    
    if([[DBWork shared] isPlaceFavour:self.aPlace.id]){
        [[DBWork shared] removePlaceFromFavour:self.aPlace.id];
    }
    else{
        [[DBWork shared] setPlaceToFavour:self.aPlace.id];
    }
    
//    self.aPlace.favour = [NSNumber numberWithBool:!self.aPlace.favour.boolValue];
//    [[DBWork shared] saveContext];
    //NSLog(@"self.aPlace.decript.length: %lu", self.aPlace.decript.length);
    [self configureBtnHeart:(UIButton*)sender];
    //[self.tableView reloadRowsAtIndexPaths:@[_mainCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)configureBtnHeart:(UIButton*)btn{
    
    NSString *activeStr = ([self.aPlace.photo_big isEqualToString:@""] || !self.aPlace.photo_big) ? @"active_heart": @"heart-active";
    NSString *inactiveStr = ([self.aPlace.photo_big isEqualToString:@""] || !self.aPlace.photo_big) ? @"inactive_heart": @"heart-inactive";
    
    if([[DBWork shared] isPlaceFavour:self.aPlace.id]){
        [btn setImage:[UIImage imageNamed:activeStr] forState:UIControlStateNormal];
    }
    else{
        [btn setImage:[UIImage imageNamed:inactiveStr] forState:UIControlStateNormal];
    }
}

#pragma mark - Gesture recognizer
- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.tableView]];
    
    if(indexPath){
        NSLog(@"didSelectImageAtIndexPath: %lu", indexPath.row);
        
        switch (indexPath.row) {
            case 1:
                [self performSegueWithIdentifier:@"segueFromPlaceDetailToResponces" sender:self];
                break;
            case 2:
                [self performSegueWithIdentifier:@"segueFromPlaceDetailToPhotoBrowser" sender:self];
                break;
            case 7:
                [self performSegueWithIdentifier:@"segueFromPlaceDetailToResponces" sender:self];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Send Email

-(void)sendEmail{
    if([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setSubject:kMailSubject];
        [mailController setToRecipients:[NSArray arrayWithObject:kMailAdress]];
        [self presentViewController:mailController animated:YES completion:nil];
    }
    else{
        //NSLog(@"Sorry, you need to setup email first");
        // ошибку не настроен почтовый аккаунт
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:kMailNoEmailAccount delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [av show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VK SDK Delegate
-(void)authorizeVK{
    [VKSdk authorize:SCOPE revokeAccess:YES];
}

-(void)showVkontakteShareController{
    VKShareDialogController *shareVK = [[VKShareDialogController alloc] init];
    [shareVK presentIn:self];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    NSLog(@"vkSdkTokenHasExpired: %@", expiredToken);
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    NSLog(@"vkSdkReceivedNewToken: %@", newToken);
    [self showVkontakteShareController];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    NSLog(@"vkSdkShouldPresentViewController: %@", controller);
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    NSLog(@"vkSdkAcceptedUserToken: %@", token);
    
}
- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    NSLog(@"vkSdkUserDeniedAccess: %@", authorizationError);
    //    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - Facebook SDK
// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}


@end
