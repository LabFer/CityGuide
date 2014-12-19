//
//  DBWork.h
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 18.11.13.
//  Copyright (c) 2013 Dmitry Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Discounts.h"
#import "Banners.h"
#import "Attributes.h"
#import "Phones.h"
#import "Keys.h"
#import "Categories.h"
#import "Favourites.h"
#import "Comments.h"
#import "Places.h"
#import "Gallery.h"
#import "Values.h"


@interface DBWork : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSNumber *timeStamp;

+(DBWork*)shared;
-(NSFetchedResultsController*)fetchedResultsController:(NSString*)entityName sortKey:(NSString*)sortKey predicate:(NSPredicate*)predicate sectionName:(NSString*)sectionName delegate:(id)delegate;

-(void)saveContext;


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

-(void)insertNewAttributeForCategory:(NSDictionary *)anAttribute;
-(NSSet*)insertNewValuesForAttributeFromArray:(NSArray *)anArray;
-(void)insertAttributesFromArray:(NSArray*)anArray;
-(NSSet*)getAttributesFromArray:(NSArray *)anArray forParent:(NSString *)parentName;
-(Attributes*)getAttributeItem:(NSNumber *)attributeID forParent:(NSString *)parentName;
-(NSSet*)getAttributeItemForParent:(NSNumber *)parentID forParent:(NSString *)parentName;
-(BOOL)isAttributeExist:(NSNumber *)attributeID forParent:(NSString *)parentName;

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
-(void)insertNewDiscount:(NSDictionary *)aDiscount;
-(BOOL)isDiscountExist:(NSNumber *)discountID;

-(void)insertNewComment:(NSDictionary *)aComment;
-(void)insertCommentsFromArray:(NSArray *)anArray;
-(BOOL)isCommentExist:(NSNumber *)commentID;

-(NSArray*)getUnsyncFavourites;
-(NSArray*)getDeletedFavourites;
-(void)insertNewFavourite:(NSDictionary*)aFavourite;
-(void)insertFavouritesFromArray:(NSArray*)anArray;
-(void)deleteFavouritesFromArray:(NSArray*)anArray;
//-(void)deleteFavouriteItem:(NSDictionary*)aFavourite;

@end
