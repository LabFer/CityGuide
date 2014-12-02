//
//  DBWork.m
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 18.11.13.
//  Copyright (c) 2013 Dmitry Kuznetsov. All rights reserved.
//

#import "DBWork.h"
#import "Constants.h"
#import "Categories.h"
#import "Places.h"

@implementation DBWork

static DBWork* shared = NULL;

+(DBWork*)shared{
    if(!shared || shared == NULL){
        shared = [DBWork new];
        [shared prepareDatabase];
    }
    
    return shared;
}

#pragma mark - CoreData Helper
-(void)inserDataFromDictionary:(NSDictionary *)insertDictionary{
    
    NSLog(@"Try to insert data");
//    NSLog(@"inserting dictionary: %@", [insertDictionary objectForKey:@"types"]);
    NSArray *attributesArray = [insertDictionary objectForKey:@"types"];
    [self insertAttributesFromArray:attributesArray];
    
    NSArray *categoryArray = [insertDictionary objectForKey:@"category"];
    [self insertCategoriesFromArray:categoryArray];
//
    NSArray *placesArray = [insertDictionary objectForKey:@"place"];
    [self insertPlacesFromArray:placesArray];
}

-(NSArray *)sortDescriptorsFromString:(NSString*)sortKeys{
    
    NSArray *tmp = [sortKeys componentsSeparatedByString:@","];
    NSMutableArray *sortArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(NSString *item in tmp){
        
        BOOL isAscending = YES;
        if([item isEqualToString:@"promoted"]) isAscending = NO;
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:item ascending:isAscending];
        [sortArray addObject:sortDescriptor];
    }
    
    return [NSArray arrayWithArray:sortArray];
}


#pragma mark - Places Entity

-(void)insertNewPlace:(NSDictionary *)aPlace{
    
    if([self isPlaceExist:[[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"id"]]])
        return;
    
    Places *place = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataPlacesEntity inManagedObjectContext:self.managedObjectContext];
    
    place.id = [[NSNumberFormatter alloc] numberFromString:[aPlace objectForKey:@"id"]];
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
    place.decript = [aPlace objectForKey:@"text"];
       
    place.attributes = [self getAttributesFromArray:[aPlace objectForKey:@"type"]];
    place.keys = [self insertNewKeysFromArray:[aPlace objectForKey:@"keys"]];
    place.phones = [self insertNewPhonesFromArray:[aPlace objectForKey:@"phone"]];
    place.gallery = [self insertNewGalleryFromArray:[aPlace objectForKey:@"images"]];
    place.category = [self getCategoriesFromArray:[aPlace objectForKey:@"parentID"]];
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", placeID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataPlacesEntity sortKey:@"id" predicate:predicate sectionName:nil delegate:self];
    
    Places *place = frc.fetchedObjects.lastObject;
    if(place) return YES;
    
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
                NSLog(@"Key exist: %@", keyName);
            }
            else{
                aKey = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataKeysEntity inManagedObjectContext:self.managedObjectContext];
                aKey.name = keyName;
                NSLog(@"Insert new Key: %@", keyName);
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
                NSLog(@"Phone exist: %@", phoneNum);
            }
            else{
                aPhone = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataPhonesEntity inManagedObjectContext:self.managedObjectContext];
                aPhone.phone_number = phoneNum;
                NSLog(@"Insert new Phone: %@", phoneNum);
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
    category.id = [[NSNumberFormatter alloc] numberFromString:[aCategory objectForKey:@"id"]];
    category.name = [aCategory objectForKey:@"name"];
    category.parent_id = [[NSNumberFormatter alloc] numberFromString:[aCategory objectForKey:@"parentID"]];
    category.photo = [aCategory objectForKey:@"photo"];
    category.sort = [[NSNumberFormatter alloc] numberFromString:[aCategory objectForKey:@"position"]];
    category.favour = [NSNumber numberWithBool:NO];
    
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", categoryID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataCategoriesEntity sortKey:@"id" predicate:predicate sectionName:nil delegate:self];
    
    Categories *cat = frc.fetchedObjects.lastObject;
    if(cat) return YES;
    
    return NO;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@", item];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataCategoriesEntity sortKey:@"id" predicate:predicate sectionName:nil delegate:self];
    
    return frc.fetchedObjects.lastObject;
}

#pragma mark - Attributes Entity

-(void)insertNewAttribute:(NSDictionary *)anAttribute{
    
    if([self isAttributeExist:[[NSNumberFormatter alloc] numberFromString:[anAttribute objectForKey:@"id"]]])
        return;
    
    Attributes *attribute = [NSEntityDescription insertNewObjectForEntityForName:kCoreDataAttributesEntity inManagedObjectContext:self.managedObjectContext];
    
    attribute.id = [[NSNumberFormatter alloc] numberFromString:[anAttribute objectForKey:@"id"]];
    attribute.name = [anAttribute objectForKey:@"name"];
//    attribute.type = [anAttribute objectForKey:@"type"]; FIXME: replace with real data from server
//    @property (nonatomic, retain) NSData * value;
//    @property (nonatomic, retain) NSNumber * require;
//    @property (nonatomic, retain) NSNumber * filterable;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

-(void)insertAttributesFromArray:(NSArray*)anArray{
    
    [anArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self insertNewAttribute:obj];
    }];
}

-(NSSet*)getAttributesFromArray:(NSArray *)anArray{
//    NSArray *attrArray = [aPlace objectForKey:@"type"];
    
    NSMutableArray *attrSet = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *attrID in anArray) {
        Attributes *attr = [self getAttributeItem:[[NSNumberFormatter alloc] numberFromString:attrID]];
        [attrSet addObject:attr];
    }
    
    return [[NSSet alloc] initWithArray:attrSet];
}

-(Attributes*)getAttributeItem:(NSNumber *)attributeID{
    NSString *item = [attributeID stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id==%@", item];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataAttributesEntity sortKey:@"id" predicate:predicate sectionName:nil delegate:self];
    
    return frc.fetchedObjects.lastObject;
}

-(BOOL)isAttributeExist:(NSNumber *)attributeID{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", attributeID];
    
    NSFetchedResultsController *frc = [self fetchedResultsController:kCoreDataAttributesEntity sortKey:@"id" predicate:predicate sectionName:nil delegate:self];
    
    Attributes *attr = frc.fetchedObjects.lastObject;
    if(attr) return YES;
    
    return NO;
}




-(void)deleteItems:(NSDictionary*)deleteDict{

    for(NSDictionary *item in deleteDict){
        NSString *itemID = [item objectForKey:@"id"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookID==%@", itemID];
        
        NSFetchedResultsController *frc = [self fetchedResultsController:@"ChildBook" sortKey:@"name" predicate:predicate sectionName:nil delegate:self];
        
        NSManagedObject *deleteObject = frc.fetchedObjects.lastObject;
        
        if(deleteObject)
            [self.managedObjectContext deleteObject:deleteObject];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error deleting: %@", error.localizedDescription);
    }
}

-(void)deleteItem:(NSNumber *)itemID{
    
    NSString *item = [itemID stringValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bookID==%@", item];
        
    NSFetchedResultsController *frc = [self fetchedResultsController:@"ChildBook" sortKey:@"name" predicate:predicate sectionName:nil delegate:self];
        
    NSManagedObject *deleteObject = frc.fetchedObjects.lastObject;
        
    if(deleteObject){
        [self.managedObjectContext deleteObject:deleteObject];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error deleting: %@", error.localizedDescription);
    }
}

-(NSArray*)arrayWithObjects{
    return [[self fetchedResultsController:@"ChildBook" sortKey:@"created" predicate:nil sectionName:nil delegate:self] fetchedObjects];
}

-(void)updateDataFromArray:(NSArray *)updateArray{
    
    [updateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *str = [NSString stringWithFormat:@"bookID == %@", [obj objectForKey:@"id"]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:str];

        NSFetchedResultsController *frc = [self fetchedResultsController:@"ChildBook" sortKey:@"bookID" predicate:predicate sectionName:nil delegate:nil];
        
        
//        ChildBook *bookInfo = [frc fetchedObjects].lastObject;
//        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//
//        bookInfo.position = [obj objectForKey:@"position"];
//        bookInfo.parentID = [f numberFromString:[obj objectForKey:@"ParentID"]];
//        bookInfo.remoteID = [f numberFromString:[obj objectForKey:@"RemoteID"]];
//        bookInfo.name = [obj objectForKey:@"name"];
//        bookInfo.text = [obj objectForKey:@"text"];
//        bookInfo.picture = [obj objectForKey:@"picture"];
//        bookInfo.created = [obj objectForKey:@"created"];
//        bookInfo.modified = [obj objectForKey:@"modified"];
//        bookInfo.anotation = [obj objectForKey:@"annotation"];
//        bookInfo.bookDescription = [obj objectForKey:@"description"];
//        bookInfo.keywords = [obj objectForKey:@"keywords"];
//        bookInfo.title = [obj objectForKey:@"title"];
//        bookInfo.price = [obj objectForKey:@"price"];
//        bookInfo.old_price = [obj objectForKey:@"old_price"];
//        bookInfo.date_start = [obj objectForKey:@"date_start"];
//        bookInfo.view = [f numberFromString:[obj objectForKey:@"view"]];
//        bookInfo.pay = [f numberFromString:[obj objectForKey:@"pay"]];
//        bookInfo.social = [f numberFromString:[obj objectForKey:@"social"]];
//        bookInfo.file = [obj objectForKey:@"file"];
        
        //NSLog(@"updated book: bookID: %@; bookName: %@ж URL: %@", bookInfo.bookID, bookInfo.name, bookInfo.file);
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
}

-(void)inserDataFromArray:(NSArray *)insertArray{
    
    [insertArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        ChildBook *bookInfo = [NSEntityDescription
//                               insertNewObjectForEntityForName:@"ChildBook"
//                               inManagedObjectContext:self.managedObjectContext];
//        
//        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
//        
//        
//        bookInfo.bookID = [f numberFromString:[obj objectForKey:@"id"]];
//        bookInfo.position = [obj objectForKey:@"position"];
//        bookInfo.parentID = [f numberFromString:[obj objectForKey:@"ParentID"]];
//        bookInfo.remoteID = [f numberFromString:[obj objectForKey:@"RemoteID"]];
//        bookInfo.name = [obj objectForKey:@"name"];
//        bookInfo.text = [obj objectForKey:@"text"];
//        bookInfo.picture = [obj objectForKey:@"picture"];
//        bookInfo.created = [obj objectForKey:@"created"];
//        bookInfo.modified = [obj objectForKey:@"modified"];
//        bookInfo.anotation = [obj objectForKey:@"annotation"];
//        bookInfo.bookDescription = [obj objectForKey:@"description"];
//        bookInfo.keywords = [obj objectForKey:@"keywords"];
//        bookInfo.title = [obj objectForKey:@"title"];
//        bookInfo.price = [obj objectForKey:@"price"];
//        bookInfo.old_price = [obj objectForKey:@"old_price"];
//        bookInfo.date_start = [obj objectForKey:@"date_start"];
//        bookInfo.view = [f numberFromString:[obj objectForKey:@"view"]];
//        bookInfo.pay = [f numberFromString:[obj objectForKey:@"pay"]];
//        bookInfo.social = [f numberFromString:[obj objectForKey:@"social"]];
//        bookInfo.file = [obj objectForKey:@"file"];
//        bookInfo.isDownloaded = [NSNumber numberWithBool:NO];
//        
        //NSLog(@"bookID: %@; bookName: %@ж URL: %@", bookInfo.bookID, bookInfo.name, bookInfo.file);
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }];
}

-(void)deleteDataFromArray:(NSArray *)deleteArray{

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


@end
