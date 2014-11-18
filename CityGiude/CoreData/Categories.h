//
//  Categories.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 18/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Attributes, Places;

@interface Categories : NSManagedObject

@property (nonatomic, retain) NSData * filters;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parent_id;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) NSSet *attributes;
@property (nonatomic, retain) NSSet *places;
@end

@interface Categories (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(Attributes *)value;
- (void)removeAttributesObject:(Attributes *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

- (void)addPlacesObject:(Places *)value;
- (void)removePlacesObject:(Places *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
