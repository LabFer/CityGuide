//
//  Favourites.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 13/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favourites : NSManagedObject

@property (nonatomic, retain) NSNumber * favourID;
@property (nonatomic, retain) NSString * favourType;
@property (nonatomic, retain) NSNumber * parentID;
@property (nonatomic, retain) NSString * userToken;
@property (nonatomic, retain) NSNumber * favourStatus;//needSync;
@end
