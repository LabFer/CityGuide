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
#import "AuthUserViewController.h"

#import "MenuTableViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "MMDrawerBarButtonItem.h"
#import "VALabel.h"
#import "Constants.h"
#import "DiscountListViewController.h"
#import "DBWork.h"
#import "Discounts.h"

#import "PlacePhotoAlbumViewController.h"

static NSArray  * SCOPE = nil;

@implementation PlaceDetailViewController{
    UIUserSettings *_userSettings;
    BOOL _isExpanded;
    BOOL _isImageCached;
    //NSString *_testString;
    UIImageView *_logoImage;
}

-(void)viewDidLoad{

    _userSettings = [[UIUserSettings alloc] init];
    SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_NOHTTPS, VK_PER_EMAIL, VK_PER_MESSAGES];
    
    [super viewDidLoad];
    
    [self setNavBarButtons];
    NSLog(@"======= Gallery ====== : %lu", (unsigned long)self.aPlace.gallery.count);
    
    [self configurePlaceGalleryPreview];
    
    //============ gesture recognizer =====
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    _isExpanded = NO;
    //_testString = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. ==== Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
    
    _isImageCached = NO;
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    //слушаю PUSH-notification
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kReceiveRemoteNotification
                                               object:appDelegate];
    
    // ====== mmdrawer swipe gesture =======
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveRemoteNotification object:nil];
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
    if([self.delegate isKindOfClass:[MenuTableViewController class]]){
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        [self.mm_drawerController setMaximumLeftDrawerWidth:screenWidth];
        [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
        
    }
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
    if([self.aPlace.categories allObjects].count == 0)
        return @"";
    
    Categories *aCategory = [self.aPlace.categories allObjects][0];
    NSMutableString *aStr =  [NSMutableString stringWithString:aCategory.name];
    
    for(int i = 1; i < [self.aPlace.categories allObjects].count; i++){
        [aStr appendString:@", "];
        aCategory = [self.aPlace.categories allObjects][i];
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
        
        [self configureMainNoImageCell:self.prototypeMainCellNoImage forRowAtIndexPath:indexPath];
        
        //[self.prototypeMainCellNoImage setNeedsUpdateConstraints];
        [self.prototypeMainCellNoImage updateConstraintsIfNeeded];
        //[self.prototypeMainCellNoImage setNeedsLayout];
        [self.prototypeMainCellNoImage layoutIfNeeded];
        [self.prototypeMainCellNoImage setNeedsDisplay];
        CGSize size = [self.prototypeMainCellNoImage.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        cellHeight = size.height + 5;
        
    }
    else if(indexPath.row == 1){
        if([self.aPlace.photo_big isEqualToString:@""] || !self.aPlace.photo_big){ // has no image
            cellHeight = 0.0f;
            
        }
        else{ // has image
            NSLog(@"Place has Image");
//            [self configureMainImageCell:self.prototypeMainCell forRowAtIndexPath:indexPath];
//            //[self.prototypeMainCell setNeedsUpdateConstraints];
//            [self.prototypeMainCell updateConstraintsIfNeeded];
//            //[self.prototypeMainCell setNeedsLayout];
//            [self.prototypeMainCell layoutIfNeeded];
//            [self.prototypeMainCell setNeedsDisplay];
//            CGSize size = [self.prototypeMainCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//            cellHeight = size.height + 1;
            if(IS_IPAD){
                cellHeight = 315.0f + 8.0f + 8.0f + 1.0f;
            }
            else{
                cellHeight = 125.0f + 8.0f + 8.0f + 1.0f;
            }
        }

    }
    else if(indexPath.row == 2){
        cellHeight =  44.0f;
    }
    else if (indexPath.row == 3){
        cellHeight = ([self.aPlace.gallery count] == 0) ? 0.0f : 115.0f;
    }
    else if(indexPath.row == 4){
        
        cellHeight = (self.aPlace.decript.length == 0) ? 0.0f : [self textViewHeightForRowAtIndexPath:indexPath] + 8 + 10 + 44 + 10;
    }
    else if(indexPath.row == 5){//social
        cellHeight = 80.0f;
    }
    else if(indexPath.row == 6){//info
        [self configureInfoCell:self.prototypeInfoCell forRowAtIndexPath:indexPath];
        //[self.prototypeMainCell setNeedsUpdateConstraints];
        //[self.prototypeInfoCell updateConstraintsIfNeeded];
        //[self.prototypeMainCell setNeedsLayout];
//        [self.prototypeInfoCell layoutIfNeeded];
//        [self.prototypeInfoCell setNeedsDisplay];
//        CGSize size = [self.prototypeInfoCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        cellHeight = self.prototypeInfoCell.cellHeight + 1;
        
        //cellHeight = 185.0f;
    }
    
    //NSLog(@"cellHeight: %f; for row: %lu", cellHeight, (unsigned long)indexPath.row);
    return cellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

#pragma mark - TableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 9;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0){ // make title cell
        cell = [self.tableView dequeueReusableCellWithIdentifier:[PlaceDetailedMainCellNoImage reuseId] forIndexPath:indexPath];
        [self configureMainNoImageCell:cell forRowAtIndexPath:indexPath];
        
    }
    if(indexPath.row == 1){ //make image/logo cell
        cell = [self.tableView dequeueReusableCellWithIdentifier:[PlaceDetailedMainCell reuseId] forIndexPath:indexPath];
        [self configureMainImageCell:cell forRowAtIndexPath:indexPath];
    }
    else if(indexPath.row == 2){//make rating cell
        cell = [self.tableView dequeueReusableCellWithIdentifier:[RatingCell reuseId] forIndexPath:indexPath];
        [self configureRatingCell:cell forRowAtIndexPath:indexPath];
        
    }
    else if(indexPath.row == 3){//make photo browser cell
        cell = [self.tableView dequeueReusableCellWithIdentifier:[PPImageScrollingTableViewCell reuseId] forIndexPath:indexPath];
        if([self.aPlace.gallery count] != 0)
            [self configureScrollingViewCell:cell forRowAtIndexPath:indexPath];
        
    }
    else if (indexPath.row == 4){//share cell
        cell = [self.tableView dequeueReusableCellWithIdentifier:[AboutCell reuseId] forIndexPath:indexPath];
        [self configureAboutCell:cell forRowAtIndexPath:indexPath];
        
    }
    else if (indexPath.row == 5){
        cell = [self.tableView dequeueReusableCellWithIdentifier:[ShareCell reuseId] forIndexPath:indexPath];
        [self configureShareCell:cell forRowAtIndexPath:indexPath];
        
    }
    else if (indexPath.row == 6){
        cell = [self.tableView dequeueReusableCellWithIdentifier:[InfoCell reuseId] forIndexPath:indexPath];
        //if(cell == nil){
            NSLog(@"info cell is nil");
            [self configureInfoCell:cell forRowAtIndexPath:indexPath];
        //}
        
    }
    else if(indexPath.row == 7 || indexPath.row == 8){
        cell = [self.tableView dequeueReusableCellWithIdentifier:[CommonCell reuseId] forIndexPath:indexPath];
        [self configureCommonCell:cell forRowAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - Configure Cells
- (void)configureCommonCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[CommonCell class]]){
        CommonCell* detailCell = (CommonCell*)cell;
        detailCell.nameLabel.text = (indexPath.row == 7) ? kSettingsDiscount: kSettingsResponces;
    }
}

- (void)configureInfoCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[InfoCell class]]){
        //NSLog(@"Info cell: %@", cell);
        //if (cell == nil){
            NSLog(@"Configure Info cell: %@", cell);
            InfoCell* detailCell = (InfoCell*)cell;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        CGFloat mainX = detailCell.mainTitleLabel.frame.origin.x;
        CGFloat mainY = detailCell.mainTitleLabel.frame.origin.y;
        CGFloat mainW = detailCell.mainTitleLabel.frame.size.width;
        CGFloat mainH = detailCell.mainTitleLabel.frame.size.height;
        
        //=========== adress ============
        UILabel *address = (UILabel *)[detailCell.contentView viewWithTag:1];
        if(!address){
            
            address = [[UILabel alloc] initWithFrame:CGRectMake(mainX, mainY + mainH + 10, mainW, mainH)];
            [address setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
            address.textAlignment = NSTextAlignmentLeft;
            address.tag = 1;
            [address setBackgroundColor:[UIColor clearColor]];
            [detailCell.contentView addSubview:address];
            //detailCell.cellHeight = address.frame.origin.y + address.frame.size.height + 10;
        }
        address.text = @"Адрес:";
        [address sizeToFit];
        
        UIImageView *ivAddress = (UIImageView *)[detailCell.contentView viewWithTag:2];
        UIImage *imgAddress = [UIImage imageNamed:@"char_mapmaker"];
        if(!ivAddress){
            ivAddress = [[UIImageView alloc] initWithFrame:CGRectMake(mainX + mainW + 5, address.frame.origin.y + address.frame.size.height - imgAddress.size.height - 2, imgAddress.size.width, imgAddress.size.height)];
            ivAddress.tag = 2;
            [detailCell.contentView addSubview:ivAddress];
        }
        ivAddress.image = imgAddress;
        
        CGFloat localX = ivAddress.frame.origin.x + ivAddress.frame.size.width + 10;
        UILabel *addressText = (UILabel *)[detailCell.contentView viewWithTag:3];
        if(!addressText){
            addressText = [[UILabel alloc] initWithFrame:CGRectMake(localX, address.frame.origin.y, /*detailCell.contentView.frame.size.width*/screenWidth - localX, mainH)];
            [addressText setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            addressText.textAlignment = NSTextAlignmentLeft;
        
            [addressText setTextColor:[UIColor grayColor]];
            [addressText setBackgroundColor:[UIColor clearColor]];
            addressText.tag = 3;
            [detailCell.contentView addSubview:addressText];
            //detailCell.cellHeight = fmax(address.frame.origin.y + address.frame.size.height + 10, addressText.frame.origin.y + addressText.frame.size.height + 10);
        }
        addressText.text = [NSString stringWithFormat:@"%@", self.aPlace.address];
        [addressText setNumberOfLines:0];
        [addressText sizeToFit];
        detailCell.cellHeight = fmax(address.frame.origin.y + address.frame.size.height + 10, addressText.frame.origin.y + addressText.frame.size.height + 10);
        
        // ===========================
        // ========== work time ==============
        UILabel *work = (UILabel *)[detailCell.contentView viewWithTag:4];
        if(!work){
            work = [[UILabel alloc] initWithFrame:CGRectMake(mainX,
                                                                  detailCell.cellHeight,
                                                                  mainW, mainH)];
            [work setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
            work.textAlignment = NSTextAlignmentLeft;
            work.tag = 4;
            [work setBackgroundColor:[UIColor clearColor]];
            [detailCell.contentView addSubview:work];
            //detailCell.cellHeight = work.frame.origin.y + work.frame.size.height + 10;
        }
        work.text = @"Режим работы:";
        [work sizeToFit];
        
        UIImage *imgWorkTime = [UIImage imageNamed:@"char_clock"];
        UIImageView *ivWorkTime = (UIImageView *)[detailCell.contentView viewWithTag:5];
        if(!ivWorkTime){
            ivWorkTime = [[UIImageView alloc] initWithFrame:CGRectMake(mainX + mainW + 5, work.frame.origin.y + work.frame.size.height - imgWorkTime.size.height - 2, imgWorkTime.size.width, imgWorkTime.size.height)];
            
            ivWorkTime.tag = 5;
            [detailCell.contentView addSubview:ivWorkTime];
        }
        ivWorkTime.image = imgWorkTime;
        
        localX = ivWorkTime.frame.origin.x + ivWorkTime.frame.size.width + 10;
        UILabel *worktimeText = (UILabel *)[detailCell.contentView viewWithTag:6];
        if(!worktimeText){
            worktimeText = [[UILabel alloc] initWithFrame:CGRectMake(localX, work.frame.origin.y, /*detailCell.contentView.frame.size.width*/screenWidth - localX - 8, mainH)];
            [worktimeText setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            worktimeText.textAlignment = NSTextAlignmentLeft;
        
            [worktimeText setTextColor:[UIColor grayColor]];
            worktimeText.tag = 6;
        
            [worktimeText setBackgroundColor:[UIColor clearColor]];
            [detailCell.contentView addSubview:worktimeText];
            
        }
        worktimeText.text = [NSString stringWithFormat:@"%@", self.aPlace.work_time_description];
        [worktimeText setNumberOfLines:0];
        [worktimeText sizeToFit];
        detailCell.cellHeight = fmax(work.frame.origin.y + work.frame.size.height + 10, worktimeText.frame.origin.y + worktimeText.frame.size.height + 10);
        
        // ========================================
        // =================== phone ==============
        UILabel *phone = (UILabel *)[detailCell.contentView viewWithTag:7];
        if(!phone){
            phone = [[UILabel alloc] initWithFrame:CGRectMake(mainX,
                                                                   detailCell.cellHeight,
                                                                  mainW, mainH)];
            [phone setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
            phone.textAlignment = NSTextAlignmentLeft;
            [phone setBackgroundColor:[UIColor clearColor]];
            phone.tag = 7;
            [detailCell.contentView addSubview:phone];
            //detailCell.cellHeight = phone.frame.origin.y + phone.frame.size.height + 10;
        }
        phone.text = @"Телефон:";
        [phone sizeToFit];
        
        UIImage *imgPhone = [UIImage imageNamed:@"char_phone"];
        UIImageView *ivPhone = (UIImageView *)[detailCell.contentView viewWithTag:8];
        if(!ivPhone){
            ivPhone = [[UIImageView alloc] initWithFrame:CGRectMake(mainX + mainW + 5, phone.frame.origin.y + phone.frame.size.height - imgPhone.size.height - 2, imgPhone.size.width, imgPhone.size.height)];
            ivPhone.tag = 8;
            [detailCell.contentView addSubview:ivPhone];
        }
        ivPhone.image = imgPhone;
        
        localX = ivPhone.frame.origin.x + ivPhone.frame.size.width + 10;
        UIButton *btnPhone = (UIButton *)[detailCell.contentView viewWithTag:9];

        if(!btnPhone){
            btnPhone = [[UIButton alloc] initWithFrame:CGRectMake(localX, phone.frame.origin.y, /*detailCell.contentView.frame.size.width*/screenWidth - localX - 8, mainH)];
            [btnPhone addTarget:self action:@selector(btnPhonePressed:) forControlEvents:UIControlEventTouchUpInside];
            btnPhone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [btnPhone.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            btnPhone.tag = 9;
            btnPhone.titleLabel.textAlignment = NSTextAlignmentLeft;
            [btnPhone setTitleColor:kDefaultNavBarColor forState:UIControlStateNormal];
            [btnPhone setBackgroundColor:[UIColor clearColor]];
            [detailCell.contentView addSubview:btnPhone];

        }
        [btnPhone setTitle:[self getStringPhones] forState:UIControlStateNormal];
        [btnPhone.titleLabel setNumberOfLines:0];
        [btnPhone.titleLabel sizeToFit];
        detailCell.cellHeight = fmax(phone.frame.origin.y + phone.frame.size.height + 10, btnPhone.frame.origin.y + btnPhone.frame.size.height + 10);
        
        // ======================================================
        // ====================== website ===============================
        UILabel *website = (UILabel *)[detailCell.contentView viewWithTag:10];
        if(!website){
            website = [[UILabel alloc] initWithFrame:CGRectMake(mainX,
                                                                   detailCell.cellHeight,
                                                                   mainW, mainH)];
            [website setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
            website.textAlignment = NSTextAlignmentLeft;
            [website setBackgroundColor:[UIColor clearColor]];
            website.tag = 10;
            [detailCell.contentView addSubview:website];
            //detailCell.cellHeight = website.frame.origin.y + website.frame.size.height + 10;
        }
        website.text = @"Сайт:";
        [website sizeToFit];
        
        
        UIImage *imgWeb = [UIImage imageNamed:@"char_site"];
        UIImageView *ivWeb = (UIImageView *)[detailCell.contentView viewWithTag:11];

        if(!ivWeb){
            ivWeb = [[UIImageView alloc] initWithFrame:CGRectMake(mainX + mainW + 5, website.frame.origin.y + website.frame.size.height - imgWeb.size.height - 2, imgWeb.size.width, imgWeb.size.height)];
            ivWeb.tag = 11;
            [detailCell.contentView addSubview:ivWeb];
        }
        ivWeb.image = imgWeb;

        
        localX = ivWeb.frame.origin.x + ivWeb.frame.size.width + 10;
        UIButton *btnWeb = (UIButton *)[detailCell.contentView viewWithTag:12];
        if(!btnWeb){
            btnWeb = [[UIButton alloc] initWithFrame:CGRectMake(localX, website.frame.origin.y, /*detailCell.contentView.frame.size.width*/screenWidth - localX - 8, mainH)];
        
            
            [btnWeb addTarget:self action:@selector(btnSitePressed:) forControlEvents:UIControlEventTouchUpInside];
            btnWeb.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [btnWeb.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            btnWeb.tag = 12;
            btnWeb.titleLabel.textAlignment = NSTextAlignmentLeft;
            [btnWeb setTitleColor:kDefaultNavBarColor forState:UIControlStateNormal];
            [btnWeb setBackgroundColor:[UIColor clearColor]];
            
            [detailCell.contentView addSubview:btnWeb];
            
        }
        [btnWeb setTitle:self.aPlace.website forState:UIControlStateNormal];
        [btnWeb.titleLabel setNumberOfLines:0];
        [btnWeb.titleLabel sizeToFit];
        detailCell.cellHeight = fmax(website.frame.origin.y + website.frame.size.height + 10, btnWeb.frame.origin.y + btnWeb.frame.size.height + 10);
        //NSLog(@"detailCell.cellHeight: %f", detailCell.cellHeight);
        // =====================================================

        NSLog(@"Attributes: %lu", (unsigned long)self.aPlace.attributes.count);
        NSInteger aTag = 13;
        for(Attributes *attr in self.aPlace.attributes){
            if(![attr.type isEqualToString:@"check"]){
                UILabel *attrLabel = (UILabel *)[detailCell.contentView viewWithTag:aTag];
                if(!attrLabel){
                    attrLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainX,
                                                                         detailCell.cellHeight,
                                                                         mainW, mainH)];
                    [attrLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
                    attrLabel.textAlignment = NSTextAlignmentLeft;
                    attrLabel.tag = aTag;
                    [attrLabel setBackgroundColor:[UIColor clearColor]];
                    [detailCell.contentView addSubview:attrLabel];
                }
                aTag++;
                attrLabel.text = [NSString stringWithFormat:@"%@:", attr.name];
                [attrLabel setNumberOfLines:0];
                [attrLabel sizeToFit];
            
                //UIImage *imgWeb = [UIImage imageNamed:@"char_site"];
                UIImageView *ivAttr = (UIImageView *)[detailCell.contentView viewWithTag:aTag];
                if(!ivAttr){
                    ivAttr = [[UIImageView alloc] initWithFrame:CGRectMake(mainX + mainW + 5, attrLabel.frame.origin.y + attrLabel.frame.size.height - 13 - 2, 13, 13)];
                    ivAttr.tag = aTag;
                    [detailCell.contentView addSubview:ivAttr];
                }
                aTag++;
                NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, attr.picture];
                NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                [ivAttr setImageWithURL:imgUrl];
                
                
                localX = ivAttr.frame.origin.x + ivAttr.frame.size.width + 10;
                CGFloat localHeight = 0.0f;
                //NSLog(@"localHeight: %f", localHeight);
                if([attr.type isEqualToString:@"url"]){
                    UIButton *btnAttr = (UIButton *)[detailCell.contentView viewWithTag:aTag];
                    if(!btnAttr){
                        btnAttr = [[UIButton alloc] initWithFrame:CGRectMake(localX, attrLabel.frame.origin.y, /*detailCell.contentView.frame.size.width*/screenWidth - localX - 8, mainH)];
                
                    
                        [btnAttr addTarget:self action:@selector(btnSitePressed:) forControlEvents:UIControlEventTouchUpInside];
                        btnAttr.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                        [btnAttr.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
                        btnAttr.tag = aTag;
                        btnAttr.titleLabel.textAlignment = NSTextAlignmentLeft;
                        [btnAttr setTitleColor:kDefaultNavBarColor forState:UIControlStateNormal];
                        [btnAttr setBackgroundColor:[UIColor clearColor]];
                    
                        [detailCell.contentView addSubview:btnAttr];
                        
                    }
                    [btnAttr setTitle:attr.value forState:UIControlStateNormal];
                    [btnAttr.titleLabel setNumberOfLines:0];
                    [btnAttr.titleLabel sizeToFit];
                    localHeight = btnAttr.frame.origin.y + btnAttr.frame.size.height + 10;
                }
                else if([attr.type isEqualToString:@"string"]){
                    UILabel *valueText1 = (UILabel *)[detailCell.contentView viewWithTag:aTag];
                    if(!valueText1){
                        valueText1 = [[UILabel alloc] initWithFrame:CGRectMake(localX, attrLabel.frame.origin.y, /*detailCell.contentView.frame.size.width*/screenWidth - localX - 8, mainH)];
                        [valueText1 setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
                        valueText1.textAlignment = NSTextAlignmentLeft;
                    
                        [valueText1 setTextColor:[UIColor grayColor]];
                        
                        valueText1.tag = aTag;
                        [valueText1 setBackgroundColor:[UIColor clearColor]];
                        [detailCell.contentView addSubview:valueText1];
                        
                    }
                    valueText1.text = [NSString stringWithFormat:@"%@", attr.value];
                    [valueText1 setNumberOfLines:0];
                    [valueText1 sizeToFit];
                    localHeight = valueText1.frame.origin.y + valueText1.frame.size.height + 10;
                }
                else if([attr.type isEqualToString:@"array"]){
                    UILabel *valueText = (UILabel *)[detailCell.contentView viewWithTag:aTag];
                    if(!valueText){
                        valueText = [[UILabel alloc] initWithFrame:CGRectMake(localX, attrLabel.frame.origin.y, /*detailCell.contentView.frame.size.width*/screenWidth - localX - 8, mainH)];
                        [valueText setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
                        valueText.textAlignment = NSTextAlignmentLeft;
                        [valueText setTextColor:[UIColor grayColor]];
                        [valueText setNumberOfLines:0];
                        valueText.tag = aTag;
                        [valueText setBackgroundColor:[UIColor clearColor]];
                        [detailCell.contentView addSubview:valueText];
                        
                    }
                    NSMutableArray* arr = [[NSMutableArray alloc] initWithCapacity:0];
                    for(Values *val in attr.values){
                        [arr addObject:val.valueName];
                    }
                    valueText.text = [arr componentsJoinedByString:@", "];
                    [valueText setNumberOfLines:0];
                    [valueText sizeToFit];
                    localHeight = valueText.frame.origin.y + valueText.frame.size.height + 10;
                    
                }
                aTag++;
                detailCell.cellHeight = fmax(attrLabel.frame.origin.y + attrLabel.frame.size.height + 10, localHeight);
                //NSLog(@"localHeight: %f", localHeight);
                //NSLog(@"detailCell.cellHeight: %f", detailCell.cellHeight);
            }
        }
        
//
//        [detailCell.btnSocial setTitle:@"vk.com/place" forState:UIControlStateNormal];
//        [detailCell.btnSocial addTarget:self action:@selector(btnSocialPressed:) forControlEvents:UIControlEventTouchUpInside];
//        detailCell.btnSocial.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        cell.layer.shouldRasterize = YES;
//        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
//        }
//        else{
//            NSLog(@"Info cell not configured: %@", cell);
//
//            //cell = self.prototypeInfoCell;
//        }
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
        //if(_testString.length < 200)
            detailCell.showAllBtn.hidden = YES;
        
    }
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"configureCell: %@", cell);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, self.aPlace.photo_big];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"URL: %@", imgUrl);
    __weak UITableViewCell *weakCell = cell;
    
    [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:imgUrl]
                          placeholderImage:[UIImage imageNamed:@"defaulticonbig"]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       NSLog(@"weakCell. imageDownloaded");
                                       weakCell.imageView.image = image;
                                       [weakCell setNeedsLayout];
                                       [self.tableView beginUpdates];
                                       [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                       [self.tableView endUpdates];
                                       
                                   } failure:nil];
}

- (void)configureMainImageCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[PlaceDetailedMainCell class]]){
        PlaceDetailedMainCell* detailCell = (PlaceDetailedMainCell*)cell;
        
        if([self.aPlace.photo_big isEqualToString:@""] || !self.aPlace.photo_big){ // has no image
            detailCell.placeImage.hidden = YES;
            detailCell.btnHeart.hidden = YES;
            
        }
        else{ // has image
            detailCell.placeImage.hidden = NO;
            detailCell.btnHeart.hidden = NO;
            
            NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, self.aPlace.photo_big];
            NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            NSLog(@"URL: %@", imgUrl);
            
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            activityIndicatorView.center = CGPointMake(self.tableView.frame.size.width/2,detailCell.contentView.center.y);
            
            
            [detailCell addSubview:activityIndicatorView];
            [activityIndicatorView startAnimating];
            [detailCell.contentView bringSubviewToFront:activityIndicatorView];
            
            UIImage *img = [UIImage imageWithContentsOfFile: NIPathForBundleResource(nil, @"NimbusPhotos.bundle/gfx/default.png")];
            
            [detailCell.placeImage setImageWithURLRequest:[NSURLRequest requestWithURL:imgUrl]
                                         placeholderImage:img /*[UIImage imageNamed:@"defaulticonbig"]*/
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                      
                                                      [activityIndicatorView removeFromSuperview];
                                                      
                                                      // do image resize here
                                                      // then set image view
                                                      NSLog(@"detailCell.placeImage. Image downloaded");
                                                      detailCell.placeImage.image = image;
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                      [activityIndicatorView removeFromSuperview];
                                                      NSLog(@"detailCell.placeImage. Fail to download image");
//                                                      // do any other error handling you want here

                                                  }];

            if([[DBWork shared] isPlaceFavour:self.aPlace.placeID]){
                [detailCell.btnHeart setImage:[UIImage imageNamed:@"heart-active"] forState:UIControlStateNormal];
            }
            else{
                [detailCell.btnHeart setImage:[UIImage imageNamed:@"heart-inactive"] forState:UIControlStateNormal];
            }
            [detailCell.btnHeart addTarget:self action:@selector(btnHeartPressed:) forControlEvents:UIControlEventTouchUpInside];
            detailCell.userInteractionEnabled = YES;
            
            detailCell.placeImage.layer.cornerRadius = kImageViewCornerRadius;
            NSLog(@"detailCell.placeImage.layer.cornerRadius = kImageViewCornerRadius;");
            detailCell.placeImage.layer.masksToBounds = YES;
            //detailCell.placeImage.clipsToBounds = YES;
        }

    }
}

-(void)reloadAsyncData:(NSIndexPath*)indexPath{
    [self.tableView beginUpdates];
    NSLog(@"reloadAsyncData");
    [self.tableView reloadData];
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)configureMainNoImageCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([cell isKindOfClass:[PlaceDetailedMainCellNoImage class]]){
        PlaceDetailedMainCellNoImage* detailCell = (PlaceDetailedMainCellNoImage*)cell;
        detailCell.placeTitle.text = self.aPlace.name;
        detailCell.placeSubTitle.text = [self getStringCategories];
        
        if([self.aPlace.photo_big isEqualToString:@""] || !self.aPlace.photo_big){ // has no image
            
            detailCell.btnHeart.hidden = NO;
            detailCell.cellSeparator.hidden = NO;
//            if(self.aPlace.favour.boolValue){
//                [detailCell.btnHeart setImage:[UIImage imageNamed:@"active_heart"] forState:UIControlStateNormal];
//            }
//            else{
//                [detailCell.btnHeart setImage:[UIImage imageNamed:@"inactive_heart"] forState:UIControlStateNormal];
//            }
            
        }
        else{ // has image
            detailCell.cellSeparator.hidden = YES;
            detailCell.btnHeart.hidden = YES;
            
            
        }
        
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
        UIView *view = (UIView *)[detailCell.contentView viewWithTag:1];
        if(!view){
            NSDictionary *cellData = [self.images objectAtIndex:0];
            [detailCell setScrollViewWidth:self.tableView.frame.size.width];
            [detailCell setImageData:cellData];
        
            //[detailCell setDelegate:self];
            [detailCell setCollectionViewBackgroundColor:[UIColor clearColor]];
            detailCell.imageScrollingView.tag = 1;
        }
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

- (InfoCell *)prototypeInfoCell
{
    if (!_prototypeInfoCell)
    {
        _prototypeInfoCell = [self.tableView dequeueReusableCellWithIdentifier:[InfoCell reuseId]];
    }
    return _prototypeInfoCell;
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
    else if([[segue identifier] isEqualToString:@"segueFromPlaceDetailToDiscounts"]){
        DiscountListViewController *cv = (DiscountListViewController*)[segue destinationViewController];
        
        cv.aPlace = self.aPlace;
        cv.delegate = self;
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
    
    NSString *call = [NSString stringWithFormat:@"tel:%@", [actionSheet buttonTitleAtIndex:buttonIndex]];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:call]];
    static UIWebView *webView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webView = [UIWebView new];
    });
    
//    UIWebView *callWebview = [[UIWebView alloc] init];
    NSURL *telURL = [NSURL URLWithString:call];
    [webView loadRequest:[NSURLRequest requestWithURL:telURL]];
    NSLog(@"ActionSheet pressed: %@", telURL);
}

-(void)btnSitePressed:(UIButton*)btn{
    NSRange result = [btn.titleLabel.text rangeOfString:@"http"];
    
    NSString *web = (result.location == NSNotFound) ? [NSString stringWithFormat:@"http://%@", btn.titleLabel.text] : btn.titleLabel.text;
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

    //if(_testString.length <200) return;
    if(self.aPlace.decript.length < 200) return;
    
    UITableViewCell *cell = (UITableViewCell *)btn.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Expand Text Pressed: %@, %@", cell, indexPath);

    [self.tableView beginUpdates]; // This will cause an animated update of
    _isExpanded = !_isExpanded;
    
    NSLog(@"System Version: %@", [[UIDevice currentDevice] systemVersion]);
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //[self.tableView reloadData];
//    if(_isExpanded)
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
//        
//    else
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView reloadData];
    [self.tableView endUpdates];
}

- (IBAction)btnHeartPressed:(id)sender {
    
    if(![_userSettings isUserAuthorized]){
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                          message:kFavourNeedAuth
                                                         delegate:self
                                                cancelButtonTitle:kAlertCancel
                                                otherButtonTitles:kAlertAuthEnter, nil];
        [message show];
        return;
    }
    
    if([[DBWork shared] isPlaceFavour:self.aPlace.placeID]){
        [[DBWork shared] removePlaceFromFavour:self.aPlace.placeID];
    }
    else{
        [self setPlaceToFavour];
    }

    [self configureBtnHeart:(UIButton*)sender];

//    self.aPlace.favour = [NSNumber numberWithBool:!self.aPlace.favour.boolValue];
//    [[DBWork shared] saveContext];
    //NSLog(@"self.aPlace.decript.length: %lu", self.aPlace.decript.length);
    
    //[self.tableView reloadRowsAtIndexPaths:@[_mainCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)setPlaceToFavour{
    [[DBWork shared] setPlaceToFavour:self.aPlace.placeID];
}

-(void)configureBtnHeart:(UIButton*)btn{
    
    NSString *activeStr = ([self.aPlace.photo_big isEqualToString:@""] || !self.aPlace.photo_big) ? @"active_heart": @"heart-active";
    NSString *inactiveStr = ([self.aPlace.photo_big isEqualToString:@""] || !self.aPlace.photo_big) ? @"inactive_heart": @"heart-inactive";
    
    if([[DBWork shared] isPlaceFavour:self.aPlace.placeID]){
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
        NSLog(@"didSelectImageAtIndexPath: %lu", (unsigned long)indexPath.row);
        
        switch (indexPath.row) {
            case 2:
                [self performSegueWithIdentifier:@"segueFromPlaceDetailToResponces" sender:self];
                break;
            case 3:
                
                [self showPhotoAlbum];
                //[self performSegueWithIdentifier:@"segueFromPlaceDetailToPhotoBrowser" sender:self];
                break;
            case 7:
               //if([[DBWork shared] getDiscountForPlaceID:self.aPlace.placeID])
                   [self performSegueWithIdentifier:@"segueFromPlaceDetailToDiscounts" sender:self];
                break;
            case 8:
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

#pragma mark - Photo Album
-(void)showPhotoAlbum{
    PlacePhotoAlbumViewController* vc = [[PlacePhotoAlbumViewController alloc] initWith:@""];
    vc.title = self.aPlace.name;
    vc.aPlace = self.aPlace;
    
    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"alertView: %@", alertView.message);
    
    if(buttonIndex != [alertView cancelButtonIndex]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        AuthUserViewController* auth = [storyboard instantiateViewControllerWithIdentifier:@"AuthUserViewController"];
        auth.delegate = self;
        auth.needToSetFavour = YES;
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
