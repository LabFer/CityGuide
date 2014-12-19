//
//  Keys.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 13/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Places;

@interface Keys : NSManagedObject

@property (nonatomic, retain) NSNumber * keyID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Places *places;

@end
