//
//  DBWork.m
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 18.11.13.
//  Copyright (c) 2013 Dmitry Kuznetsov. All rights reserved.
//

#import "DBWork.h"
#import "Constants.h"
#import "UIUserSettings.h"


@implementation DBWork

typedef enum {
    ObjectSynced = 0,
    ObjectCreated,
    ObjectDeleted,
} ObjectSyncStatus;

static DBWork* shared = NULL;

+(DBWork*)shared{
    if(!shared || shared == NULL){
        shared = [DBWork new];
        [shared prepareDatabase];
    }
    
    return shared;
}

#pragma mark - CoreData Helper

-(void)removeDataFromDB{

    [self deleteAllItemsInEntity:kCoreDataCategoriesEntity];
    //NSLog(@"Items deleted from: %@", kCoreDataCategoriesEntity);
    
    [self deleteAllItemsInEntity:kCoreDataPlacesEntity];
    //NSLog(@"Items deleted from: %@", kCoreDataPlacesEntity);
    
    [self deleteAllItemsInEntity:kCoreDataAttributesEntity];
    //NSLog(@"Items deleted from: %@", kCoreDataAttributesEntity);
    
    [self deleteAllItemsInEntity:kCoreDataValuesEntity];
    //NSLog(@"Items deleted from: %@", kCoreDataValuesEntity);
    
    [self deleteAllItemsInEntity:kCoreDataBannersEntity];
    //NSLog(@"Items deleted from: %@", kCoreDataBannersEntity);
    
    [self deleteAllItemsInEntity:kCoreDataCommentsEntity];
    //NSLog(@"Items deleted from: %@", kCoreDataCommentsEntity);
    
    [self deleteAllItemsInEntity:kCoreDataDiscountEntity];
    //NSLog(@"Items deleted from: %@", kCoreDataDiscountEntity);
    
    [self deleteAllItemsInEntity:kCoreDataCommentsEntity];
    //NSLog(@"Items deleted from: %@", kCoreDataCommentsEntity);
}

-(void)inserDataFromDictionary:(NSDictionary *)insertDictionary{
    
    NSLog(@"Try to remove data");
    [self removeDataFromDB];
    NSLog(@"Removing data complete!");
    
    NSLog(@"Try to insert data");
    
    //NSLog(@"Inserting Attributes: %@", [insertDictionary objectForKey:@"types"]);
    NSArray *attributesArray = [insertDictionary objectForKey:@"types"];
    [self insertAttributesFromArray:attributesArray];
    //NSLog(@"Inserting Attributes complete!");
    
    //NSLog(@"Inserting Attributes: %@", [insertDictionary objectForKey:@"category"]);
    NSArray *categoryArray = [insertDictionary objectForKey:@"category"];
    [self insertCategoriesFromArray:categoryArray];
    //NSLog(@"Inserting Category complete!");
//
    //NSLog(@"Inserting Attributes: %@", [insertDictionary objectForKey:@"place"]);
    NSArray *placesArray = [insertDictionary objectForKey:@"place"];
    [self insertPlacesFromArray:placesArray];
    //NSLog(@"Inserting Places complete!");
    
    //NSLog(@"Inserting Attributes: %@", [insertDictionary objectForKey:@"action"]);
    NSArray *discountsArray = [insertDictionary objectForKey:@"action"];
    [self insertDiscountsFromArray:discountsArray];
    //NSLog(@"Inserting Discounts complete!");
    
    //NSLog(@"Inserting comments: %@", [insertDictionary objectForKey:@"comments"]);
    NSArray *commentsArray = [insertDictionary objectForKey:@"comments"];
    [self insertCommentsFromArray:commentsArray];
    //NSLog(@"Inserting Comments complete!");
}

-(NSArray *)sortDescriptorsFromString:(NSString*)sortKeys{
    
    NSArray *tmp = [sortKeys componentsSeparatedByString:@","];
    NSMutableArray *sortArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(NSString *item in tmp){
        
        BOOL isAscending = YES;
        if([item isEqualToString:@"promoted"]) isAscending = NO;
        if([item isEqualToString:@"date"]) isAscending = NO;
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:item ascending:isAscending];
        [sortArray addObject:sortDescriptor];
    }
    
    return [NSArray arrayWithArray:sortArray];
}



-(void)deleteAllItemsInEntity:(NSString*)entityName{
    NSFetchedResultsController *frc = [self fetchedResultsController:entityName sortKey:nil predicate:nil sectionName:nil delegate:self];
    
    NSArray *allObjects = frc.fetchedObjects;
    for(NSManagedObject *anObject in allObjects){
        [self.managedObjectContext deleteObject:anObject];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error deleting: %@", error.localizedDescription);
    }
}

#pragma mark - Discounts Entity

-(void)insertNewDiscount:(NSDictionary *)aDiscount{
    
    if([self isDiscountExist:[[NSNumberFormatter alloc] numberFromString:[aDiscount objectForKey:@"id"]]])
        return;
    
    Discounts *discount = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataDiscountEntity inManagedObjectContext:self.managedObjectContext];
    
    discount.discountID = [[NSNumberFormatter alloc] numberFromString:[aDiscount objectForKey:@"id"]];
    discount.dateEnd = [[NSNumberFormatter alloc] numberFromString:[aDiscount objectForKey:@"dateEnd"]];
    discount.dateStart = [[NSNumberFormatter alloc] numberFromString:[aDiscount objectForKey:@"dateStart"]];
    discount.descript = [aDiscount objectForKey:@"description"];
    
    NSArray *img = [aDiscount objectForKey:@"image"];
    //NSLog(@"Discount images: %@, %@", img, img[0]);
    discount.image = img[0];
    discount.name = [aDiscount objectForKey:@"name"];
    discount.nameType = [aDiscount objectForKey:@"nameType"];
    discount.placeID = [[NSNumberFormatter alloc] numberFromString:[aDiscount objectForKey:@"placeID"]];
    discount.slider = [[NSNumberFormatter alloc] numberFromString:[aDiscount objectForKey:@"slider"]];
    discount.text = [aDiscount objectForKey:@"text"];
    discount.type = [[NSNumberFormatter alloc] numberFromString:[aDiscount objectForKey:@"type"]];
    discount.viewCount = [[NSNumberFormatter alloc] numberFromString:[aDiscount objectForKey:@"viewCount"]];
    discount.viewItem = [[NSNumberFormatter alloc] numberFromString:[aDiscount objectForKey:@"viewItem"]];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
}

-(void)insertDiscountsFromArray:(NSArray *)anArray{
    [anArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self insertNewDiscount:obj];
    }];
}

-(BOOL)isDiscountExist:(NSNumber *)discountID{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"discountID == %@", discountID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataDiscountEntity sortKey:@"discountID" predicate:predicate sectionName:nil delegate:self];
    
    Discounts *discount = frc.fetchedObjects.lastObject;
    if(discount) return YES;
    
    return NO;
}



#pragma mark - Comments Entity

-(void)insertNewComment:(NSDictionary *)aComment{
    
    //if([self isCommentExist:[[NSNumberFormatter alloc] numberFromString:[aComment objectForKey:@"id"]]])
    //    return;
    
    Comments *comment = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataCommentsEntity inManagedObjectContext:self.managedObjectContext];
    
    comment.commentID = [[NSNumberFormatter alloc] numberFromString:[aComment objectForKey:@"id"]];
    comment.date = [[NSNumberFormatter alloc] numberFromString:[aComment objectForKey:@"date"]];
    comment.name = [aComment objectForKey:@"name"];
    comment.photo = [aComment objectForKey:@"photo"];
    
    comment.placeID = [[NSNumberFormatter alloc] numberFromString:[aComment objectForKey:@"placeID"]];
    comment.rating = [[NSNumberFormatter alloc] numberFromString:[aComment objectForKey:@"rating"]];
    comment.text = [aComment objectForKey:@"text"];;//@"Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to catch this in the debugger.  The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.";//
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
}

-(void)insertCommentsFromArray:(NSArray *)anArray{
    [anArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self insertNewComment:obj];
    }];
}

-(BOOL)isCommentExist:(NSNumber *)commentID{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"commentID == %@", commentID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataCommentsEntity sortKey:@"commentID" predicate:predicate sectionName:nil delegate:self];
    
    Comments *comment = frc.fetchedObjects.lastObject;
    if(comment) return YES;
    
    return NO;
}


#pragma mark - Places Entity

-(void)insertNewPlace:(NSDictionary *)aPlace{
    
    //if([self isPlaceExist:[[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"id"]]])
    //    return;
    
    Places *place = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataPlacesEntity inManagedObjectContext:self.managedObjectContext];
    
    place.placeID = [[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"id"]];
    place.address = [aPlace objectForKey:@"address"];
    place.longitude = [NSDecimalNumber decimalNumberWithString:[aPlace objectForKey:@"longitude"]];
    place.lattitude = [NSDecimalNumber decimalNumberWithString:[aPlace objectForKey:@"latitude"]];
    place.name = [aPlace objectForKey:@"name"];
//    place.phones = [aPlace objectForKey:@"phones"];
    place.photo_small = [aPlace objectForKey:@"picture"];
    place.photo_big = [aPlace objectForKey:@"picture_big"];
    place.sort = [[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"position"]];
    place.promoted = [[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"promoted"]];
    place.rate = [[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"rate"]];
    place.rate_count = [[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"rate_count"]];
    place.website = [aPlace objectForKey:@"site"];
    place.work_time_description = [aPlace objectForKey:@"work_time_description"];
    place.work_time_start = [[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"work_time_start"]];
    place.work_time_end = [[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"work_time_end"]];
    //place.decript = [aPlace objectForKey:@"text"];
    place.decript = [self stringByStrippingHTML:[aPlace objectForKey:@"text"]];
       
    place.attributes = [self getAttributesArrayForPlaceFromArray:[aPlace objectForKey:@"type"]];
    place.keys = [self insertNewKeysFromArray:[aPlace objectForKey:@"keys"]];
    place.phones = [self insertNewPhonesFromArray:[aPlace objectForKey:@"phone"]];
    place.gallery = [self insertNewGalleryFromArray:[aPlace objectForKey:@"images"]];
    place.categories = [self getCategoriesFromArray:[aPlace objectForKey:@"parentID"]];
    place.favour = [NSNumber numberWithBool:NO];
    
    //FIXME: what is viewCount, viewItem, text
//    @property (nonatomic, retain) NSData * categories_ids; FIXME: replace with real data from server
//    @property (nonatomic, retain) NSData * properties;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

}

-(void)insertPlacesFromArray:(NSArray *)anArray{
    [anArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self insertNewPlace:obj];
    }];
}

-(BOOL)isPlaceExist:(NSNumber *)placeID{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"placeID == %@", placeID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataPlacesEntity sortKey:@"placeID" predicate:predicate sectionName:nil delegate:self];
    
    Places *place = frc.fetchedObjects.lastObject;
    if(place) return YES;
    
    return NO;
}

-(Places*)getPlaceByplaceID:(NSNumber*)placeID{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"placeID == %@", placeID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataPlacesEntity sortKey:@"name" predicate:predicate sectionName:nil delegate:self];
    
    Places *place = frc.fetchedObjects.lastObject;
    
    return place;
}

-(BOOL)isPlaceFavour:(NSNumber *)placeID{
    
    //NSLog(@"isPlaceFavour");

    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND favourType == %@ AND parentID == %@ AND favourStatus != %@", [userProfile objectForKey:kSocialUserToken], kCoreDataFavourTypePlace, placeID, [NSNumber numberWithInteger:ObjectDeleted]];
    
        NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:nil predicate:predicate sectionName:nil delegate:self];
    
        Favourites *favour = frc.fetchedObjects.lastObject;
        if(favour) return YES;
    }
    
    return NO;
}

-(void)setPlaceToFavour:(NSNumber *)placeID{
    
    if([self isPlaceFavour:placeID]) return;
    
    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        //NSLog(@"setPlaceToFavour");
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        Favourites *favour = [NSEntityDescription insertNewObjectForEntityForName:kCoreDatafavouriteEntity inManagedObjectContext:self.managedObjectContext];
    
        favour.parentID = placeID;
        favour.favourType = kCoreDataFavourTypePlace;
        favour.userToken = [userProfile objectForKey:kSocialUserToken];
        favour.favourStatus = [NSNumber numberWithInteger:ObjectCreated];
    
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    
}

-(void)removePlaceFromFavour:(NSNumber *)placeID{
    
    //NSLog(@"removeCategoryFromFavour");

    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND favourType == %@ AND parentID == %@", [userProfile objectForKey:kSocialUserToken], kCoreDataFavourTypePlace, placeID];
    
        NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:nil predicate:predicate sectionName:nil delegate:self];
        
        Favourites *favour = (Favourites*)[frc fetchedObjects].lastObject;
        
        if(favour.favourStatus.integerValue == ObjectCreated){ //if object not sync yet, only created
            NSManagedObject *deleteObject = frc.fetchedObjects.lastObject;
            
            if(deleteObject){
                [self.managedObjectContext deleteObject:deleteObject];
            }
        }
        else{
            favour.favourStatus = [NSNumber numberWithInteger:ObjectDeleted];
        }
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }

    }
}

-(NSArray*)getFavourPlace{
    
    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND favourType == %@",[userProfile objectForKey:kSocialUserToken], kCoreDataFavourTypePlace];
    
        NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:nil predicate:predicate sectionName:nil delegate:self];
    
        NSMutableArray *categoryIDs = [[NSMutableArray alloc] initWithCapacity:0];
    
        for(Favourites *f in frc.fetchedObjects){
            [categoryIDs addObject:f.parentID];
        }
    
        return categoryIDs;
    }
    
    return [NSArray array];
}

#pragma mark - Favourites Entity
-(NSArray*)getUnsyncFavourites{
    
    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND favourStatus == %@",[userProfile objectForKey:kSocialUserToken], [NSNumber numberWithInteger:ObjectCreated]];
        
        NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:nil predicate:predicate sectionName:nil delegate:self];
        
        return [frc fetchedObjects];
    }
    return [NSArray array];
}

-(NSArray*)getDeletedFavourites{
    
    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND favourStatus == %@",[userProfile objectForKey:kSocialUserToken], [NSNumber numberWithInteger:ObjectDeleted]];
        
        NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:nil predicate:predicate sectionName:nil delegate:self];
        
        return [frc fetchedObjects];
    }
    return [NSArray array];
}

-(void)insertNewFavourite:(NSDictionary*)aFavourite{
    
    
    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND parentID == %@ AND favourType == %@", [aFavourite objectForKey:@"usertoken"], [aFavourite objectForKey:@"favoriteid"], [aFavourite objectForKey:@"favoritetype"]];
    
        NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:@"favourID" predicate:predicate sectionName:nil delegate:self];
    
        Favourites *favourite = frc.fetchedObjects.lastObject;
        
        if(!favourite){
            NSLog(@"A favourite item does not exist: %@. Create new favourite item", aFavourite);
            favourite = [NSEntityDescription insertNewObjectForEntityForName:kCoreDatafavouriteEntity inManagedObjectContext:self.managedObjectContext];
        }

        favourite.favourID = [[NSNumberFormatter alloc] numberFromString:[aFavourite objectForKey:@"id"]];
        favourite.parentID = [[NSNumberFormatter alloc] numberFromString:[aFavourite objectForKey:@"favoriteid"]];
        favourite.favourType = [aFavourite objectForKey:@"favoritetype"];
        favourite.userToken = [aFavourite objectForKey:@"usertoken"];
        favourite.favourStatus = [NSNumber numberWithInteger:ObjectSynced];
    
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save favourite: %@", [error localizedDescription]);
        }
    }
    else{
        NSLog(@"insertNewFavourite. User is not authorized");
    }
}

-(void)insertFavouritesFromArray:(NSArray *)anArray{
    [anArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self insertNewFavourite:obj];
    }];
}

-(void)deleteFavouritesFromArray:(NSArray *)anArray{

    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        [anArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            //NSDictionary* item = (NSDictionary*)obj;
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
            
            NSNumber *favourID = (NSNumber*)obj;//[[NSNumberFormatter alloc] numberFromString:[item objectForKey:@"id"]];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND favourID == %@", [userProfile objectForKey:kSocialUserToken], favourID];
            
            NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:nil predicate:predicate sectionName:nil delegate:self];
            
            NSManagedObject *deleteObject = frc.fetchedObjects.lastObject;
            if(deleteObject){
                [self.managedObjectContext deleteObject:deleteObject];
            }
            
            NSError *error;
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error deleting: %@", error.localizedDescription);
            }
        }];
    }
    else{
        NSLog(@"insertNewFavourite. User is not authorized");
    }
        
}

#pragma mark - Banners
-(void)insertNewBanner:(NSDictionary *)aBanner{
    
    if([self isBannerExist:[[NSNumberFormatter alloc] numberFromString:[aBanner objectForKey:@"banerID"]]])
        return;
    
    Banners *banner = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataBannersEntity inManagedObjectContext:self.managedObjectContext];
    
    banner.bannerID = [[NSNumberFormatter alloc] numberFromString:[aBanner objectForKey:@"banerID"]];
    banner.bannerName = [aBanner objectForKey:@"banerName"];
    banner.showName = [[NSNumberFormatter alloc] numberFromString:[aBanner objectForKey:@"showName"]];
    banner.type = [aBanner objectForKey:@"type"];
    banner.picture = [aBanner objectForKey:@"picture"];
    banner.url = [aBanner objectForKey:@"url"];
    banner.position = [[NSNumberFormatter alloc] numberFromString:[aBanner objectForKey:@"position"]];

    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save banner: %@", [error localizedDescription]);
    }
    
}

-(void)insertBannersFromArray:(NSArray *)anArray{
    [anArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self insertNewBanner:obj];
    }];
}

-(NSArray*)getArrayOfBanners{
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataBannersEntity sortKey:@"bannerName" predicate:nil sectionName:nil delegate:self];
    return frc.fetchedObjects;
}

-(BOOL)isBannerExist:(NSNumber *)bannerID{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bannerID == %@", bannerID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataBannersEntity sortKey:@"bannerID" predicate:predicate sectionName:nil delegate:self];
    
    Banners *banner = frc.fetchedObjects.lastObject;
    if(banner) return YES;
    
    return NO;
}

#pragma mark - Keys Entity
-(NSSet*)insertNewKeysFromArray:(NSArray *)anArray{
    
    NSMutableArray *attrSet = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *keyName in anArray) {
        if(![keyName isEqualToString:@""]){
            Keys *aKey = nil;
            if([self isKeyExist:keyName]){
                aKey = [self getKeyByName:keyName];
                //NSLog(@"Key exist: %@", keyName);
            }
            else{
                aKey = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataKeysEntity inManagedObjectContext:self.managedObjectContext];
                aKey.name = keyName;
                //NSLog(@"Insert new Key: %@", keyName);
            }

            [attrSet addObject:aKey];
        }
    }
    
    return [[NSSet alloc] initWithArray:attrSet];
    
}

-(BOOL)isKeyExist:(NSString*)keyName{
    
    Keys *key = [self getKeyByName:keyName];
    if(key) return YES;
    return NO;
}

-(Keys*)getKeyByName:(NSString*)keyName{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", keyName];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataKeysEntity sortKey:@"name" predicate:predicate sectionName:nil delegate:self];
    
    Keys *key = frc.fetchedObjects.lastObject;
    
    return key;

}

#pragma mark - Phones Entity
-(NSSet*)insertNewPhonesFromArray:(NSArray *)anArray{
    
    NSMutableArray *attrSet = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *phoneNum in anArray) {
        if(![phoneNum isEqualToString:@""]){
            Phones *aPhone = nil;
            if([self isPhoneExist:phoneNum]){
                aPhone = [self getPhoneByNumber:phoneNum];
                //NSLog(@"Phone exist: %@", phoneNum);
            }
            else{
                aPhone = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataPhonesEntity inManagedObjectContext:self.managedObjectContext];
                aPhone.phone_number = phoneNum;
                //NSLog(@"Insert new Phone: %@", phoneNum);
            }
            
            [attrSet addObject:aPhone];
        }
    }
    
    return [[NSSet alloc] initWithArray:attrSet];
    
}

-(BOOL)isPhoneExist:(NSString*)phoneNum{
    
    Phones *phone = [self getPhoneByNumber:phoneNum];
    if(phone) return YES;
    return NO;
}

-(Phones*)getPhoneByNumber:(NSString*)phoneNum{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"phone_number == %@", phoneNum];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataPhonesEntity sortKey:@"phone_number" predicate:predicate sectionName:nil delegate:self];
    
    Phones *phone = frc.fetchedObjects.lastObject;
    
    return phone;
    
}

#pragma mark - Gallery Entity
-(NSSet*)insertNewGalleryFromArray:(NSArray *)anArray{
    
    NSMutableArray *attrSet = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *imgDict in anArray) {
        NSString *smallImg = [imgDict objectForKey:@"smallPicture"];
        NSString *bigImg = [imgDict objectForKey:@"picture"];
        
        if(![smallImg isEqualToString:@""]){
            Gallery *aGallery = nil;
            if([self isGalleryExist:smallImg]){
                aGallery = [self getGalleryBySmallImg:smallImg];
                NSLog(@"Gallery exist: %@", smallImg);
            }
            else{
                aGallery = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataGalleryEntity inManagedObjectContext:self.managedObjectContext];
                aGallery.photo_small = smallImg;
                aGallery.photo_big = bigImg;
                NSLog(@"Insert new Gallery: %@", smallImg);
            }
            
            [attrSet addObject:aGallery];
        }
    }
    
    return [[NSSet alloc] initWithArray:attrSet];
    
}

-(BOOL)isGalleryExist:(NSString*)smallImg{
    
    Gallery *gallery = [self getGalleryBySmallImg:smallImg];
    if(gallery) return YES;
    return NO;
}

-(Gallery*)getGalleryBySmallImg:(NSString*)smallImg{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photo_small == %@", smallImg];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataGalleryEntity sortKey:@"photo_small" predicate:predicate sectionName:nil delegate:self];
    
    Gallery *gallery = frc.fetchedObjects.lastObject;
    
    return gallery;
}

#pragma mark - Categories Entity

-(void)insertNewCategory:(NSDictionary *)aCategory{
    
    if([self isCategoryExist:[[NSNumberFormatter alloc] numberFromString:[aCategory objectForKey:@"id"]]])
        return;
    
    Categories *category = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataCategoriesEntity inManagedObjectContext:self.managedObjectContext];
    category.categoryID = [[NSNumberFormatter alloc] numberFromString:[aCategory objectForKey:@"id"]];
    category.name = [aCategory objectForKey:@"name"];
    category.parent_id = [[NSNumberFormatter alloc] numberFromString:[aCategory objectForKey:@"parentID"]];
    category.photo = [aCategory objectForKey:@"photo"];
    category.sort = [[NSNumberFormatter alloc] numberFromString:[aCategory objectForKey:@"position"]];
    category.favour = [NSNumber numberWithBool:NO];
    category.attributes = [self getAttributeItemForParent:[[NSNumberFormatter alloc] numberFromString:[aCategory objectForKey:@"id"]] forParent:kAttributeParentCategory];
    
//    @property (nonatomic, retain) NSData * filters; FIXME: replace with real data from server
//    @property (nonatomic, retain) NSSet *places;
//    @property (nonatomic, retain) NSSet *attributes;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

-(void)insertCategoriesFromArray:(NSArray *)anArray{
    [anArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self insertNewCategory:obj];
    }];
}

-(BOOL)isCategoryExist:(NSNumber *)categoryID{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", categoryID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataCategoriesEntity sortKey:@"categoryID" predicate:predicate sectionName:nil delegate:self];
    
    Categories *cat = frc.fetchedObjects.lastObject;
    if(cat) return YES;
    
    return NO;
}

-(BOOL)isCategoryFavour:(NSNumber*)categoryID{
    
    //NSLog(@"isCategoryFavour");

    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND favourType == %@ AND parentID == %@ AND favourStatus != %@", [userProfile objectForKey:kSocialUserToken], kCoreDataFavourTypeCategory, categoryID, [NSNumber numberWithInteger:ObjectDeleted]];
    
        NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:nil predicate:predicate sectionName:nil delegate:self];
    
        Favourites *favour = frc.fetchedObjects.lastObject;
        if(favour) return YES;
    }
    
    return NO;
}

-(void)setCategoryToFavour:(NSNumber *)categoryID{
    
    if([self isCategoryFavour:categoryID]) return;

    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        //NSLog(@"setCategoryToFavour");
        Favourites *favour = [NSEntityDescription insertNewObjectForEntityForName:kCoreDatafavouriteEntity inManagedObjectContext:self.managedObjectContext];
    
        favour.parentID = categoryID;
        favour.favourType = kCoreDataFavourTypeCategory;
        favour.userToken = [userProfile objectForKey:kSocialUserToken];
        favour.favourStatus = [NSNumber numberWithInteger:ObjectCreated];
    
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }

}

-(void)removeCategoryFromFavour:(NSNumber *)categoryID{

    //NSLog(@"removeCategoryFromFavour");

    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND favourType == %@ AND parentID == %@", [userProfile objectForKey:kSocialUserToken], kCoreDataFavourTypeCategory, categoryID];
    
        NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:nil predicate:predicate sectionName:nil delegate:self];
    
        Favourites *favour = (Favourites*)[frc fetchedObjects].lastObject;
        
        if(favour.favourStatus.integerValue == ObjectCreated){ //if object not sync yet, only created
            NSManagedObject *deleteObject = frc.fetchedObjects.lastObject;
            
            if(deleteObject){
                [self.managedObjectContext deleteObject:deleteObject];
            }
        }
        else{
            favour.favourStatus = [NSNumber numberWithInteger:ObjectDeleted];
        }
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}

-(NSArray*)getFavourCategory{
    

    UIUserSettings *userSettings = [[UIUserSettings alloc] init];
    if([userSettings isUserAuthorized]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userToken == %@ AND favourType == %@", [userProfile objectForKey:kSocialUserToken], kCoreDataFavourTypeCategory];
    
        NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDatafavouriteEntity sortKey:nil predicate:predicate sectionName:nil delegate:self];
    
        NSMutableArray *categoryIDs = [[NSMutableArray alloc] initWithCapacity:0];
    
        for(Favourites *f in frc.fetchedObjects){
            [categoryIDs addObject:f.parentID];
        }
    
        return categoryIDs;
    }
    return [NSArray array];
}


-(NSSet*)getCategoriesFromArray:(NSArray *)anArray{
    //    NSArray *attrArray = [aPlace objectForKey:@"type"];
    
    NSMutableArray *attrSet = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *categoryID in anArray) {
        Categories *cat = [self getCategoryItem:[[NSNumberFormatter alloc] numberFromString:categoryID]];
        [attrSet addObject:cat];
    }
    
    return [[NSSet alloc] initWithArray:attrSet];
}

-(Categories*)getCategoryItem:(NSNumber *)categoryID{
    NSString *item = [categoryID stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryID == %@", item];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataCategoriesEntity sortKey:@"categoryID" predicate:predicate sectionName:nil delegate:self];
    
    return frc.fetchedObjects.lastObject;
}

#pragma mark - Attributes Entity

// ==== Attributes For Category ======
-(void)insertNewAttributeForCategory:(NSDictionary *)anAttribute{
    
//    if([self isAttributeExist:[[NSNumberFormatter alloc] numberFromString:[anAttribute objectForKey:@"id"]] forParent:kAttributeParentCategory])
//        return;
    
    Attributes *attribute = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataAttributesEntity inManagedObjectContext:self.managedObjectContext];
    
    attribute.attributeID = [[NSNumberFormatter alloc] numberFromString:[anAttribute objectForKey:@"id"]];
    attribute.name = [anAttribute objectForKey:@"name"];
    attribute.picture = [anAttribute objectForKey:@"picture"];
    attribute.parentType = kAttributeParentCategory;
    attribute.parentID = [[NSNumberFormatter alloc] numberFromString:[anAttribute objectForKey:@"parentID"]];
    
    NSString* type = [anAttribute objectForKey:@"type"];
    attribute.type = type;
    if([type isEqualToString:@"array"]){

        attribute.values = [self insertNewValuesForAttributeFromArray:[anAttribute objectForKey:@"value"]];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

}

-(NSSet*)insertNewValuesForAttributeFromArray:(NSArray *)anArray{ // need for Category
    
    NSMutableArray *attrSet = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *valueDict in anArray) {
        
        Values *value = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataValuesEntity inManagedObjectContext:self.managedObjectContext];
        
        value.valueID = [[NSNumberFormatter alloc] numberFromString:[valueDict objectForKey:@"valueID"]];
        value.valueName = [valueDict objectForKey:@"value"];

        [attrSet addObject:value];

    }
    
    return [[NSSet alloc] initWithArray:attrSet];
    
}

-(void)insertAttributesFromArray:(NSArray*)anArray{
    
    [anArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self insertNewAttributeForCategory:obj];
    }];
}

// =================

-(NSSet*)getAttributesFromArray:(NSArray *)anArray forParent:(NSString *)parentName{
//    NSArray *attrArray = [aPlace objectForKey:@"type"];
    
    NSMutableArray *attrSet = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *attrID in anArray) {
        Attributes *attr = [self getAttributeItem:[[NSNumberFormatter alloc] numberFromString:attrID] forParent:parentName];
        [attrSet addObject:attr];
    }
    
    return [[NSSet alloc] initWithArray:attrSet];
}

-(Attributes*)getAttributeItem:(NSNumber *)attributeID forParent:(NSString *)parentName{
    NSString *item = [attributeID stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentType == %@ AND attributeID == %@", parentName, item];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataAttributesEntity sortKey:@"attributeID" predicate:predicate sectionName:nil delegate:self];
    
    return frc.fetchedObjects.lastObject;
}


-(NSSet*)getAttributeItemForParent:(NSNumber *)parentID forParent:(NSString *)parentName{
    NSString *item = [parentID stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentType == %@ AND parentID == %@", parentName, item];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataAttributesEntity sortKey:@"attributeID" predicate:predicate sectionName:nil delegate:self];
    
    return [[NSSet alloc] initWithArray:frc.fetchedObjects];
}

-(BOOL)isAttributeExist:(NSNumber *)attributeID forParent:(NSString *)parentName{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentType == %@ AND attributeID == %@", parentName, attributeID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataAttributesEntity sortKey:@"attributeID" predicate:predicate sectionName:nil delegate:self];
    
    Attributes *attr = frc.fetchedObjects.lastObject;
    if(attr) return YES;
    
    return NO;
}

-(NSSet*)getAttributesArrayForPlaceFromArray:(NSDictionary*)attrArray{
    
    NSMutableArray *attrSet = [[NSMutableArray alloc] initWithCapacity:0];
    //NSLog(@"Place type arr: %@", attrArray);
    
    for (id key in attrArray) { // go throught all dicts in array
        //NSLog(@"Place type arr: %@", [attrArray objectForKey:key]);
        NSDictionary* attrDict = [attrArray objectForKey:key];
        //NSLog(@"Place type dict: %@", attrDict);
        Attributes *categoryAttribute = [self getAttributeItem:[[NSNumberFormatter alloc] numberFromString:[attrDict objectForKey:@"typeID"]] forParent:kAttributeParentCategory]; // get existing for category attribute
        
        if(categoryAttribute){ // if attribute exists add attribute to place
            Attributes *placeAttribute = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataAttributesEntity inManagedObjectContext:self.managedObjectContext]; //insert new attribute for place
            
            placeAttribute.attributeID = [[NSNumberFormatter alloc] numberFromString:[attrDict objectForKey:@"typeID"]];
            placeAttribute.value = [attrDict objectForKey:@"value"];
            placeAttribute.parentID = [[NSNumberFormatter alloc] numberFromString:[attrDict objectForKey:[attrDict objectForKey:@"placeID"]]];
            placeAttribute.name = [attrDict objectForKey:@"name"];
            placeAttribute.parentType = kAttributeParentPlace;
            placeAttribute.parentID = [[NSNumberFormatter alloc] numberFromString:[attrDict objectForKey:@"placeID"]];
            
            NSString *type = [attrDict objectForKey:@"type"];
            if(![type isKindOfClass:[NSNull class]]){
                placeAttribute.type = type;
            
                if([type isEqualToString:@"array"]){ // if attribute type is array
                    NSArray* arr = [attrDict objectForKey:@"valueID"]; // get aaray of ids
                
                    NSMutableSet *valueSet = [[NSMutableSet alloc] initWithCapacity:0]; // container for values
                    for(NSString* valueID in arr){
                        Values *existValue = [self getValuesItemByID:[[NSNumberFormatter alloc] numberFromString:valueID]]; // get existing value
                        Values *valueForPlace = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataValuesEntity inManagedObjectContext:self.managedObjectContext]; //create new value for place
                        valueForPlace.valueID = existValue.valueID;
                        valueForPlace.valueName = existValue.valueName;
                    
                        [valueSet addObject:valueForPlace]; //add value to container
                    
                    }
                
                    placeAttribute.values = [[NSSet alloc] initWithSet:valueSet]; // add values to attribute
                }
            }
            
            [attrSet addObject:placeAttribute]; //add attribute to place set
        }
        
    }
    
    return [[NSSet alloc] initWithArray:attrSet];
}

-(Values*)getValuesItemByID:(NSNumber*)valueID{
    NSString *item = [valueID stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"valueID == %@", item];
        
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataValuesEntity sortKey:@"valueID" predicate:predicate sectionName:nil delegate:self];
        
        return frc.fetchedObjects.lastObject;
}

#pragma mark - Core Data stack

-(NSFetchedResultsController *)fetchedResultsController:(NSString*)entityName                                                  sortKey:(NSString*)sortKeys predicate:(NSPredicate*)predicate sectionName:(NSString*)sectionName delegate:(id)delegate
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:DBWork.shared.managedObjectContext];
    fetchRequest.fetchBatchSize = 20;
    
    //NSLog(@"FRC predicate: %@", predicate);
    if (predicate) {
        [fetchRequest setPredicate:predicate];
    }
    
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    fetchRequest.sortDescriptors = [self sortDescriptorsFromString:sortKeys];//[NSArray arrayWithObjects:sortDescriptor, nil];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[DBWork shared].managedObjectContext sectionNameKeyPath:sectionName cacheName:nil];
    
    aFetchedResultsController.delegate = delegate;
    
	NSError *error = nil;
	if (![aFetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return aFetchedResultsController;
}

-(void)prepareDatabase{
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kCoreDataModelName withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:kCoreDataSQLiteName];
    
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]){
        //Do something with error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = DBWork.shared.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(NSString *) stringByStrippingHTML:(NSString*)aString {
    
    NSAttributedString *resultString = [[NSAttributedString alloc] initWithData:[aString dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil];
    
    return resultString.string;
}


@end
