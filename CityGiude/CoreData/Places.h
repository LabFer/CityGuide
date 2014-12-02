//
//  Places.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 18/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Attributes, Categories, Gallery, Phones;

@interface Places : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSData * categories_ids;
@property (nonatomic, retain) NSString * decript;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * lattitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photo_big;
@property (nonatomic, retain) NSString * photo_small;
@property (nonatomic, retain) NSNumber * promoted;
@property (nonatomic, retain) NSData * properties;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * rate_count;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * work_time_description;
@property (nonatomic, retain) NSNumber * work_time_end;
@property (nonatomic, retain) NSNumber * work_time_start;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet *category;
@property (nonatomic, retain) NSSet *phones;
@property (nonatomic, retain) NSSet *gallery;
@property (nonatomic, retain) NSSet *keys;
@property (nonatomic, retain) NSNumber *favour;
@end

@interface Places (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(Attributes *)value;
- (void)removeAttributesObject:(Attributes *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addCategoryObject:(Categories *)value;
- (void)removeCategoryObject:(Categories *)value;
- (void)addCategory:(NSSet *)values;
- (void)removeCategory:(NSSet *)values;

- (void)addPhonesObject:(Phones *)value;
- (void)removePhonesObject:(Phones *)value;
- (void)addPhones:(NSSet *)values;
- (void)removePhones:(NSSet *)values;

- (void)addGalleryObject:(Gallery *)value;
- (void)removeGalleryObject:(Gallery *)value;
- (void)addGallery:(NSSet *)values;
- (void)removeGallery:(NSSet *)values;

- (void)addKeysObject:(NSManagedObject *)value;
- (void)removeKeysObject:(NSManagedObject *)value;
- (void)addKeys:(NSSet *)values;
- (void)removeKeys:(NSSet *)values;

@end
