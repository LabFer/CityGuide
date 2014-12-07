//
//  Favourites.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 07/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favourites : NSManagedObject

@property (nonatomic, retain) NSString * favourType;
@property (nonatomic, retain) NSNumber * favourID;
@property (nonatomic, retain) NSNumber * parentID;

@end
