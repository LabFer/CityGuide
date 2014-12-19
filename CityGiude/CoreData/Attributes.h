//
//  Attributes.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 13/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Categories, Places, Values;

@interface Attributes : NSManagedObject

@property (nonatomic, retain) NSNumber * attributeID;
@property (nonatomic, retain) NSNumber * filterable;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSNumber * require;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * parentType;
@property (nonatomic, retain) NSNumber * parentID;
@property (nonatomic, retain) Places *places;
@property (nonatomic, retain) NSSet *values;
@property (nonatomic, retain) Categories *category;
@end

@interface Attributes (CoreDataGeneratedAccessors)

- (void)addValuesObject:(Values *)value;
- (void)removeValuesObject:(Values *)value;
- (void)addValues:(NSSet *)values;
- (void)removeValues:(NSSet *)values;

@end
