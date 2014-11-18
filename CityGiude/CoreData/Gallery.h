//
//  Gallery.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 18/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Places;

@interface Gallery : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * photo_small;
@property (nonatomic, retain) NSString * photo_big;
@property (nonatomic, retain) NSSet *places;
@end

@interface Gallery (CoreDataGeneratedAccessors)

- (void)addPlacesObject:(Places *)value;
- (void)removePlacesObject:(Places *)value;
- (void)addPlaces:(NSSet *)values;
- (void)removePlaces:(NSSet *)values;

@end
