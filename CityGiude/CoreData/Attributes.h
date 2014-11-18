//
//  Attributes.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 18/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Categories, Places;

@interface Attributes : NSManagedObject

@property (nonatomic, retain) NSNumber * filterable;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * require;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSData * value;
@property (nonatomic, retain) NSSet *category;
@property (nonatomic, retain) NSSet *places;
@end

@interface Attributes (CoreDataGeneratedAccessors)

- (void)addCategoryObject:(Categories *)value;
- (void)removeCategoryObject:(Categories *)value;
- (void)addCategory:(NSSet *)values;
- (void)removeCategory:(NSSet *)values;

- (void)addPlacesObject:(Places *)value;
- (void)removePlacesObject:(Places *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
