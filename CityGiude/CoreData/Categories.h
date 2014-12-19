//
//  Categories.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 13/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Attributes, Places;

@interface Categories : NSManagedObject

@property (nonatomic, retain) NSNumber * favour;
@property (nonatomic, retain) NSData * filters;
@property (nonatomic, retain) NSNumber * categoryID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parent_id;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) NSSet *places;
@property (nonatomic, retain) NSSet *attributes;
@end

@interface Categories (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(Places *)value;
- (void)removePlacesObject:(Places *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

- (void)addAttributesObject:(Attributes *)value;
- (void)removeAttributesObject:(Attributes *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

@end
