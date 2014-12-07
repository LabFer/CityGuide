//
//  DBWork.h
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 18.11.13.
//  Copyright (c) 2013 Dmitry Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Attributes.h"
#import "Keys.h"
#import "Phones.h"
#import "Gallery.h"

@interface DBWork : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSNumber *timeStamp;

+(DBWork*)shared;
-(NSFetchedResultsController*)fetchedResultsController:(NSString*)entityName sortKey:(NSString*)sortKey predicate:(NSPredicate*)predicate sectionName:(NSString*)sectionName delegate:(id)delegate;

-(void)saveContext;

-(void)inserDataFromArray:(NSArray*)insertArray; // insert data for all entities
-(void)inserDataFromDictionary:(NSDictionary*)insertDictionary; // insert data for all entities

-(void)insertCategoriesFromArray:(NSArray*)anArray;
-(void)insertNewCategory:(NSDictionary*)aCategory;
-(BOOL)isCategoryExist:(NSNumber*)categoryID;
-(NSSet*)getCategoriesFromArray:(NSArray *)anArray;
-(Categories*)getCategoryItem:(NSNumber *)categoryID;
-(void)setCategoryToFavour:(NSNumber*)categoryID;
-(void)removeCategoryFromFavour:(NSNumber*)categoryID;
-(BOOL)isCategoryFavour:(NSNumber*)categoryID;
-(NSArray*)getFavourCategory;

-(void)insertAttributesFromArray:(NSArray*)anArray;
-(void)insertNewAttribute:(NSDictionary*)anAttribute;
-(Attributes*)getAttributeItem:(NSNumber*)attributeID;
-(NSSet*)getAttributesFromArray:(NSArray*)anArray;
-(BOOL)isAttributeExist:(NSNumber*)attributeID;

-(void)insertPlacesFromArray:(NSArray*)anArray;
-(void)insertNewPlace:(NSDictionary*)aPlace;
-(BOOL)isPlaceExist:(NSNumber*)placeID;
-(Places*)getPlaceByplaceID:(NSNumber*)placeID;
-(void)setPlaceToFavour:(NSNumber*)placeID;
-(void)removePlaceFromFavour:(NSNumber*)placeID;
-(BOOL)isPlaceFavour:(NSNumber*)placeID;
-(NSArray*)getFavourPlace;

-(NSSet*)insertNewKeysFromArray:(NSArray*)anArray;
-(BOOL)isKeyExist:(NSString*)keyName;
-(Keys*)getKeyByName:(NSString*)keyName;

-(NSSet*)insertNewPhonesFromArray:(NSArray *)anArray;
-(BOOL)isPhoneExist:(NSString*)phoneNum;
-(Phones*)getPhoneByNumber:(NSString*)phoneNum;

-(NSSet*)insertNewGalleryFromArray:(NSArray *)anArray;
-(BOOL)isGalleryExist:(NSString*)smallImg;
-(Gallery*)getGalleryBySmallImg:(NSString*)smallImg;

-(void)insertBannersFromArray:(NSArray*)anArray;
-(NSArray*)getArrayOfBanners;
-(BOOL)isBannerExist:(NSNumber *)bannerID;

-(void)insertDiscountsFromArray:(NSArray*)anArray;
//-(NSArray*)getArrayOfBanners;
-(BOOL)isDiscountExist:(NSNumber *)discountID;
//==========

-(void)deleteItems:(NSDictionary*)deleteDict;
-(void)deleteItem:(NSNumber*)itemID;
-(NSArray*)arrayWithObjects;


-(void)updateDataFromArray:(NSArray *)insertArray;

@end
