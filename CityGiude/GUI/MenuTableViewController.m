//
//  MenuTableViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 13/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "MenuTableViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "UIImageView+AFNetworking.h"

#import "FavourViewController.h"
#import "Constants.h"
#import "UIUserSettings.h"

#import <FacebookSDK/FacebookSDK.h>
#import <TwitterKit/TwitterKit.h>
#import "VKSdk.h"

#import "AuthUserViewController.h"
#import "MenuListCell.h"
#import "PlaceListCell.h"
#import "DiscountListCell.h"
#import "Places.h"
#import "Discounts.h"
#import "SearchHeaderCollectionView.h"
#import "SearchListFlowLayout.h"
#import "DBWork.h"
#import "PlaceDetailViewController.h"
#import "DiscountDetailViewController.h"

#define MAX_ITEMS_SHOWN 2

@implementation MenuTableViewController{
    UIUserSettings *_userSettings;
    
    NSArray *_filteredPlaces;
    NSArray *_filteredDiscounts;
    
    BOOL isAllPlacesShown;
    BOOL isAllDiscountsShown;
}

-(void)viewDidLoad{

    [super viewDidLoad];
    
//    self.navigationControllerArray = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",nil];
    _userSettings = [[UIUserSettings alloc] init];
//    
//    self.userPhotoImage.layer.cornerRadius = kImageViewCornerRadius;
//    self.userPhotoImage.clipsToBounds = YES;
    self.searchBar.layer.borderWidth = 0.0f;
    
    self.searchResultsCollectionView.hidden = YES;
    
    SearchListFlowLayout *layout = [[SearchListFlowLayout alloc] init];
    CGFloat sizeOfItems = [UIScreen mainScreen].bounds.size.width;
    layout.itemSize = CGSizeMake(sizeOfItems, 115.0f); //size of each cell
    [self.searchResultsCollectionView setCollectionViewLayout:layout];
    
    _filteredDiscounts = [NSArray array];
    _filteredPlaces = [NSArray array];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapCollectionView:)];
    [self.searchResultsCollectionView addGestureRecognizer:gestureRecognizer];
    
    UITapGestureRecognizer *gestureRecognizerTable = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapTableView:)];
    [self.menuTableView addGestureRecognizer:gestureRecognizerTable];
    
    isAllPlacesShown = NO;
    isAllDiscountsShown = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    if([_userSettings isUserAuthorized]){
//        [self setAuthInformation];
//        
//    }
   
     [self.menuTableView reloadData];
    //слушаю PUSH-notification
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name:kReceiveRemoteNotification
                                               object:appDelegate];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReceiveRemoteNotification object:nil];
}

#pragma mark - Authoruzation
-(void)setAuthInformation{

    
//    if([_userSettings isUserAuthorized]){
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
//        
//        [self.userPhotoImage setImageWithURL:[NSURL URLWithString:[userProfile objectForKey:kSocialUserPhoto]]];
//        self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", [userProfile objectForKey:kSocialUserFirstName], [userProfile objectForKey:kSocialUserLastName]];
//        
//        NSLog(@"User profile: %@", [userProfile objectForKey:kSocialType]);
//    }
//    else{
//        NSLog(@"User profile does not exist!");
//    }
    
    return;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //NSLog(@"cellForRowAtIndexPath: %@", CellIdentifier);
    MenuListCell *cell = [self.menuTableView dequeueReusableCellWithIdentifier:[MenuListCell reuseId] forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            if([_userSettings isUserAuthorized]){
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
                
                cell.menuImage.contentMode = UIViewContentModeScaleAspectFill;
                [cell.menuImage setImageWithURL:[NSURL URLWithString:[userProfile objectForKey:kSocialUserPhoto]]];
                
                cell.menuImage.layer.cornerRadius = 2;//kImageViewCornerRadius;
                cell.menuImage.clipsToBounds = YES;
                cell.menuLabel.text = [NSString stringWithFormat:@"%@ %@", [userProfile objectForKey:kSocialUserFirstName], [userProfile objectForKey:kSocialUserLastName]];
                
                cell.menuImage.hidden = NO;
                cell.menuLabel.hidden = NO;
                cell.userInteractionEnabled = YES;
            }
            else{
                cell.menuImage.hidden = YES;
                cell.menuLabel.hidden = YES;
                cell.userInteractionEnabled = NO;
            }

            break;
        
        case 1: //goto catalog screen
            [cell.menuImage setImage:[UIImage imageNamed:@"menu_houses"]];
            cell.menuLabel.text = @"Заведения";
           
            break;
        case 2: //goto catalog screen
            [cell.menuImage setImage:[UIImage imageNamed:@"menu_popular"]];
            cell.menuLabel.text = @"Категории";
            cell.menuImage.hidden = YES;
            cell.menuLabel.hidden = YES;

            break;
        case 3:
            [cell.menuImage setImage:[UIImage imageNamed:@"menu_discount"]];
            cell.menuLabel.text = @"Акции и скидки";

            break;
        case 4:
            [cell.menuImage setImage:[UIImage imageNamed:@"menu_near"]];
            cell.menuLabel.text = @"Рядом";

            break;
        case 5:
            [cell.menuImage setImage:[UIImage imageNamed:@"menu_favour"]];
            cell.menuLabel.text = @"Избранное";

            break;
        case 6:
            [cell.menuImage setImage:[UIImage imageNamed:@"menu_setup"]];
            cell.menuLabel.text = @"Настройки";
            break;
        case 7:
            cell.menuImage.hidden = YES;
            cell.menuLabel.hidden = YES;
            cell.userInteractionEnabled = NO;
            break;
        case 8:
            if([_userSettings isUserAuthorized]){
                [cell.menuImage setImage:[UIImage imageNamed:@"menu_exit"]];
                cell.menuLabel.text = kAuthLogOut;
            }
            else{
                [cell.menuImage setImage:[UIImage imageNamed:@"menu_login"]];
                cell.menuLabel.text = kAuthLogIn;
            }
            break;
        default:
            break;
    }
    
    
    return cell;
}

//-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
////    if(indexPath.row == 0){
////        if([_userSettings isUserAuthorized]){
////            self.userPhoto.hidden = NO;
////            self.userNameLabel.hidden = NO;
////            [self.authImage setImage:[UIImage imageNamed:@"menu_exit"]];
////            self.authLabel.text = kAuthLogOut;
////        }
////        else{
////            self.userPhoto.hidden = YES;
////            self.userNameLabel.hidden = YES;
////            [self.authImage setImage:[UIImage imageNamed:@"menu_login"]];
////            self.authLabel.text = kAuthLogIn;
////        }
////    }
//}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        //CGFloat userCellHeight = ([_userSettings isUserAuthorized]) ? 44.0f : 0.0f;
        //NSLog(@"[_userSettings isUserAuthorized]: %d, %f", [_userSettings isUserAuthorized], userCellHeight);
        if(![_userSettings isUserAuthorized]){
            //NSLog(@"heightForRowAtIndexPath [_userSettings isUserAuthorized]: NO. return 0.0f");
            return 0.0f;
        }
    }
    
    if(indexPath.row == 2){
        return 0.0f;
    }
    
    if(indexPath.row == 7){
        //CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        //NSLog(@"cell Height = %f; screenHeihgt = %f", screenHeight - 9 * 44.0f - 20.0f, screenHeight);
        NSInteger showRows = ([_userSettings isUserAuthorized]) ? 7 : 6;
        //NSLog(@"showRows: %lu", (unsigned long)showRows);
        return self.menuTableView.frame.size.height - showRows * 44.0f;
    }
    
    return 44.0f;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"didSelectRowAtIndexPath: %li", indexPath.row);
    

}

#pragma mark - User Log Out
-(void)userLogOut{
    
    if([_userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *profile = [userDefaults objectForKey:kSocialUserProfile];
        
        if([[profile objectForKey:kSocialType] isEqualToString:kSocialFacebookProfile]){
            [self facebookLogOut];
            [userDefaults removeObjectForKey:kSocialUserProfile];
            [userDefaults synchronize];
        }
        else if([[profile objectForKey:kSocialType] isEqualToString:kSocialTwitterProfile]){
            [self twitterLogOut];
            [userDefaults removeObjectForKey:kSocialUserProfile];
            [userDefaults synchronize];
        }
        else if([[profile objectForKey:kSocialType] isEqualToString:kSocialVKontakteProfile]){
            [self vkontakteLogOut];
            [userDefaults removeObjectForKey:kSocialUserProfile];
            [userDefaults synchronize];
        }
        
    }
    
    [self.menuTableView reloadData];

}

-(void)facebookLogOut{
    NSLog(@"facebookLogOut");
    if ([FBSession activeSession].state == FBSessionStateOpen ||
        [FBSession activeSession].state == FBSessionStateOpenTokenExtended) {
        
        // Close an existing session.
        [[FBSession activeSession] closeAndClearTokenInformation];
        NSLog(@"User logged out facebook!");
        
        
    }
}

-(void)twitterLogOut{
    
     NSLog(@"twitterLogOut");
    [[Twitter sharedInstance] logOut];

}

-(void)vkontakteLogOut{
    
    NSLog(@"vkontakteLogOut");
    [VKSdk forceLogout];
}

-(void)openMainViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    
    UINavigationController *navigationController = (UINavigationController *)[[UINavigationController alloc] initWithRootViewController:(UIViewController *)newViewController];
    [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
//    [self.mm_drawerController setCenterViewController:navigationController withFullCloseAnimation:YES completion:nil];
}

#pragma mark - Search Bar delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    //if(searchText.length == 0){
    if(searchText.length == 0) {
        //NSLog(@"search text is Zero");
        
        //self.searchResultsCollectionView.alpha = 1.0f;
        [UIView animateWithDuration:.25 animations:^
         {
             self.searchResultsCollectionView.alpha = 0.0f;
             [self.mm_drawerController setMaximumLeftDrawerWidth:280.0f];
             [self.mm_drawerController setShowsShadow:YES];
         } completion:nil];
        
        self.searchResultsCollectionView.hidden = YES;
        
    }
    else{
        NSLog(@"search text is %@", searchText);
        NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
        
        if ([searchTerms count] == 1) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (decript contains[cd] %@) OR (SUBQUERY(keys, $key, $key.name contains[cd] %@).@count>0)", searchText, searchText, searchText];
            NSPredicate *d = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (descript contains[cd] %@) OR (text contains[cd] %@)", searchText, searchText, searchText];
            
            _filteredPlaces = nil;
            _filteredPlaces = [[[DBWork shared] getAllItemsInEntity:kCoreDataPlacesEntity withSortKeys:@"promoted,sort,name"] filteredArrayUsingPredicate:p];
            
            _filteredDiscounts = nil;
            _filteredDiscounts = [[[DBWork shared] getAllItemsInEntity:kCoreDataDiscountEntity withSortKeys:@"name"] filteredArrayUsingPredicate:d];
        } else {
            NSMutableArray *subPredicatesP = [[NSMutableArray alloc] init];
            NSMutableArray *subPredicatesD = [[NSMutableArray alloc] init];
            for (NSString *term in searchTerms) {
                NSPredicate *p = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (decript contains[cd] %@) OR (SUBQUERY(keys, $key, $key.name contains[cd] %@).@count>0)", term, term, term];
                [subPredicatesP addObject:p];
                NSPredicate *d = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (descript contains[cd] %@) OR (text contains[cd] %@)", term, term, term];
                [subPredicatesD addObject:d];
            }
            NSPredicate *cp = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicatesP];
            NSPredicate *cd = [NSCompoundPredicate orPredicateWithSubpredicates:subPredicatesD];
        
            _filteredPlaces = nil;
            _filteredPlaces = [[[DBWork shared] getAllItemsInEntity:kCoreDataPlacesEntity withSortKeys:@"promoted,sort,name"] filteredArrayUsingPredicate:cp];
            
            _filteredDiscounts = nil;
            _filteredDiscounts = [[[DBWork shared] getAllItemsInEntity:kCoreDataDiscountEntity withSortKeys:@"name"] filteredArrayUsingPredicate:cd];
        }
        //NSLog(@"_filteredPlaces: %@", _filteredPlaces);
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.searchResultsCollectionView.hidden = NO;
        
        //self.searchResultsCollectionView.alpha = 0.0f;
        [UIView animateWithDuration:.25 animations:^
         {
             self.searchResultsCollectionView.alpha = 1.0f;
             [self.mm_drawerController setMaximumLeftDrawerWidth:screenWidth];
             [self.mm_drawerController setShowsShadow:NO];
         } completion:nil];
    }
    
    [self.searchResultsCollectionView reloadData];
}

#pragma mark UICollectionViewDataSource

-(void)collectionView:collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return [[JournalData shared].books numberOfsections];
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if(section == 0){
        NSLog(@"[_filteredPlaces count]: %lu", (unsigned long)[_filteredPlaces count]);
        if([_filteredPlaces count] > MAX_ITEMS_SHOWN && !isAllPlacesShown)
            return 2;
        
        return [_filteredPlaces count];
    }
    
    NSLog(@"[_filteredDiscounts count]: %lu", (unsigned long)[_filteredDiscounts count]);
    if([_filteredDiscounts count] > MAX_ITEMS_SHOWN && !isAllDiscountsShown)
        return 2;
    return [_filteredDiscounts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell *cell = nil;
    //NSLog(@"indexPath.section: %lu", (unsigned long)indexPath.section);
    
    if(indexPath.section == 0){
    
        cell = [self.searchResultsCollectionView dequeueReusableCellWithReuseIdentifier:[PlaceListCell reuseId] forIndexPath:indexPath];
    
        [self configurePlaceListCell:(PlaceListCell *)cell atIndexPath:indexPath];
    }
    else{
        cell = [self.searchResultsCollectionView dequeueReusableCellWithReuseIdentifier:[DiscountListCell reuseId] forIndexPath:indexPath];
        
        [self configureDiscountListCell:(DiscountListCell *)cell atIndexPath:indexPath];
    }
    
    //NSLog(@"MainViewController indexPath: %li", indexPath.item);
    //    cell.layer.shouldRasterize = YES;
    //    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    return cell;
}

-(void)configurePlaceListCell:(PlaceListCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    
    
    Places *place = _filteredPlaces[indexPath.item];//self.frcPlaces.fetchedObjects[indexPath.item];
    //NSLog(@"configurePlaceListCell: %@, %@", indexPath, place.name);
    [cell.titleLabel setText:place.name];
    [cell.subTitleLabel setText:place.address];
    //@property (weak, nonatomic) IBOutlet UIImageView *placeImage; FIXME: add image for place
    
    CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[place.lattitude doubleValue] longitude:[place.longitude doubleValue]];
    //NSLog(@"Place location is %@",placeLocation);
    
    NSString *distance = [self getDistanceFromUserLocationTo:placeLocation];
    
    [cell.distanceLabel setText:distance]; //FIXME add distance for place
    
    if(place.promoted.boolValue){
        cell.backgroundColor = kPromotedPlaceCellColor;
    }
    else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, place.photo_small];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = cell.placeImage.center;
    [cell addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    
    //cell.placeImage.image = [UIImage imageNamed:@"default50"];
    [cell.placeImage setImageWithURLRequest:[NSURLRequest requestWithURL:imgUrl]
                              placeholderImage:[UIImage imageNamed:@"no_photo"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           [activityIndicatorView removeFromSuperview];
                                           
                                           // do image resize here
                                           
                                           // then set image view
                                           
                                           cell.placeImage.image = image;
                                       }
                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           [activityIndicatorView removeFromSuperview];
                                           
                                           // do any other error handling you want here
                                       }];

    
    
    
    
    //NSLog(@"Promoted: %@", place.promoted);
    //[cell.placeImage setImageWithURL:imgUrl];
    //[cell.placeImage setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"photo"]];
    
    cell.placeImage.layer.cornerRadius = kImageViewCornerRadius;
    cell.placeImage.clipsToBounds = YES;
    
    
    // ======= rate view =====
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"star_grey"];
    //self.rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"star_yellow"];
    cell.rateView.rating = place.rate.floatValue;
    cell.rateView.editable = NO;
    cell.rateView.maxRating = 5;
}

-(NSString *)getDistanceFromUserLocationTo:(CLLocation *)coordinate {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    CLLocationDistance distance = [locationManager.location distanceFromLocation:coordinate];
    NSString *stringDistance;
    if (distance<1000) {
        distance = ceil(distance/100)*100;
        stringDistance = [NSString stringWithFormat:@"%.0f м",distance];
    }
    else {
        distance = ceil(distance/100)/10;
        stringDistance = [NSString stringWithFormat:@"%.1f км",distance];
    }
    
    return stringDistance;
}


-(void)configureDiscountListCell:(DiscountListCell*)cell atIndexPath:(NSIndexPath*)indexPath{
    Discounts *discount = _filteredDiscounts[indexPath.item];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", URL_BASE, discount.image];
    NSURL *imgUrl = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = cell.discountImage.center;
    [cell addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    [cell.discountImage setImageWithURLRequest:[NSURLRequest requestWithURL:imgUrl]
                     placeholderImage:[UIImage imageNamed:@"no_photo"]
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  
                                  [activityIndicatorView removeFromSuperview];
                                  
                                  // do image resize here
                                  
                                  // then set image view
                                  
                                  cell.discountImage.image = image;
                              }
                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                  [activityIndicatorView removeFromSuperview];
                                  
                                  // do any other error handling you want here
                              }];
    
    
    
    
    
    //NSLog(@"%@\n%@", urlStr, imgUrl);
    //[cell.placeImage setImageWithURL:imgUrl];
    //[cell.discountImage setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"photo"]];
    
    cell.discountImage.layer.cornerRadius = kImageViewCornerRadius;
    cell.discountImage.clipsToBounds = YES;
    
    cell.discountText.text = discount.descript;
    cell.discountTitle.text = discount.name;
    cell.discountTime.text = [self timeDifferenceToString:discount.dateEnd];
}

-(NSString*)timeDifferenceToString:(NSNumber*)endTime{
    
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *currentDate = [NSDate date];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endTime.doubleValue];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:currentDate  toDate:endDate  options:0];
    
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    //    NSLog(@"currentDate: %@", [dateFormatter stringFromDate:currentDate]);
    //    NSLog(@"endDate: %@", [dateFormatter stringFromDate:endDate]);
    
    //    NSLog(@"Break down: %ld min : %ld hours : %ld days : %ld months", [breakdownInfo minute], [breakdownInfo hour], [breakdownInfo day], [breakdownInfo month]);
    
    NSString *resultString = @"";
    if([breakdownInfo month] != 0){
        resultString = [NSString stringWithFormat:@" Осталось %li месяца %li дней", (long)[breakdownInfo month], (long)[breakdownInfo day]];
    }
    else{
        if([breakdownInfo day] != 0){
            resultString = [NSString stringWithFormat:@"Осталось %li дней", (long)[breakdownInfo day]];
        }
        else{
            resultString = [NSString stringWithFormat:@"Осталось %li часов %li минут", (long)[breakdownInfo hour], (long)[breakdownInfo minute]];
        }
    }
    
    return resultString;
}




#pragma mark CollectionView Header
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"CollectionView Header: %@", indexPath);
    
    SearchHeaderCollectionView *headerView = [self.searchResultsCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[SearchHeaderCollectionView kind] forIndexPath:indexPath];
    
    if(indexPath.section == 0){
        headerView.sectionTitleLabel.text = kSettingsPlaces;
        [headerView.btnShowMore addTarget:self action:@selector(changeShowPlacesStatus) forControlEvents:UIControlEventTouchUpInside];
        
        if([_filteredPlaces count] > MAX_ITEMS_SHOWN)
            headerView.btnShowMore.hidden = NO;
        else
            headerView.btnShowMore.hidden = YES;
        
        if(isAllPlacesShown){
            headerView.btnShowMore.titleLabel.text = @"Скрыть";
        }
        else{
            headerView.btnShowMore.titleLabel.text = @"Показать все";
        }
    }
    else{
        headerView.sectionTitleLabel.text = kSettingsDiscount;
        [headerView.btnShowMore addTarget:self action:@selector(changeShowDiscountsStatus) forControlEvents:UIControlEventTouchUpInside];
        
        if([_filteredDiscounts count] > MAX_ITEMS_SHOWN)
            headerView.btnShowMore.hidden = NO;
        else
            headerView.btnShowMore.hidden = YES;
        
        if(isAllDiscountsShown){
            headerView.btnShowMore.titleLabel.text = @"Показать все";
        }
        else{
            headerView.btnShowMore.titleLabel.text = @"Скрыть";
        }
    }
    
    [headerView setBackgroundColor:[UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f]];
    
    return headerView;
}

-(void)changeShowPlacesStatus{
    isAllPlacesShown = !isAllPlacesShown;
    
    [self.searchResultsCollectionView reloadData];
}

-(void)changeShowDiscountsStatus{
    isAllDiscountsShown = !isAllDiscountsShown;
    [self.searchResultsCollectionView reloadData];
}

#pragma mark - Keyboard

- (void)handleTapCollectionView:(UITapGestureRecognizer *)gestureRecognizer{
    NSLog(@"CollectionView hideKeyboard:");
    [self.searchBar resignFirstResponder];
    
    NSIndexPath *indexPath = [self.searchResultsCollectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.searchResultsCollectionView]];
    
    if(indexPath){
        if(indexPath.section == 0){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            PlaceDetailViewController *newViewController = (PlaceDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlaceDetailViewController"];
            
            Places *aPlace = _filteredPlaces[indexPath.item];
            newViewController.aPlace = aPlace;
            newViewController.delegate = self;
            
            UINavigationController *navigationController = (UINavigationController *)[[UINavigationController alloc] initWithRootViewController:(UIViewController *)newViewController];
            
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
            
            //self.frcPlaces.fetchedObjects[indexPath.item];
            //[self performSegueWithIdentifier:@"segueFromHouseToHouseDetail" sender:aPlace];
        }
        else{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            DiscountDetailViewController *newViewController = (DiscountDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DiscountDetailViewController"];
            
            Discounts *aDiscount = _filteredDiscounts[indexPath.item];
            newViewController.aDiscount = aDiscount;
            newViewController.delegate = self;
            
            UINavigationController *navigationController = (UINavigationController *)[[UINavigationController alloc] initWithRootViewController:(UIViewController *)newViewController];
            
            [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
        }
    }
}

- (void)handleTapTableView:(UITapGestureRecognizer *)gestureRecognizer{
    //NSLog(@"TableView hideKeyboard:");
    [self.searchBar resignFirstResponder];
    
    NSIndexPath *indexPath = [self.menuTableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.menuTableView]];
    
    if(indexPath){
        [self.menuTableView deselectRowAtIndexPath:indexPath animated:YES];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        UIViewController *newViewController;
        
        switch (indexPath.row) {
            case 0:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"AboutUserViewController"];
                break;
            case 1: //goto catalog screen
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                break;
            case 2: //goto catalog screen
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PlaceViewController"];
                break;
            case 3:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DiscountListViewController"];
                break;
            case 4:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"NearMapViewController"];
                break;
            case 5:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"FavourViewController"];
                break;
            case 6:
                newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
                break;
            case 7:
                return;
                break;
            case 8:
                if([_userSettings isUserAuthorized]){
                    [self userLogOut];
                    newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                }
                else{
                    newViewController = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                    AuthUserViewController* auth = [storyboard instantiateViewControllerWithIdentifier:@"AuthUserViewController"];
                    auth.delegate = self;
                    [self presentViewController:auth animated:YES completion:nil];
                    
                    
                }
                break;
            default:
                break;
        }
        
        UINavigationController *navigationController = (UINavigationController *)[[UINavigationController alloc] initWithRootViewController:(UIViewController *)newViewController];
        
        [self.mm_drawerController setCenterViewController:navigationController withCloseAnimation:YES completion:nil];
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
