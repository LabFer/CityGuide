//
//  Keys.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 18/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Places;

@interface Keys : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *places;
@end

@interface Keys (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(Places *)value;
- (void)removePlacesObject:(Places *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
