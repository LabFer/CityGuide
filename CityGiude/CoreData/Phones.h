//
//  Phones.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 13/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Places;

@interface Phones : NSManagedObject

@property (nonatomic, retain) NSNumber * phoneID;
@property (nonatomic, retain) NSString * phone_number;
@property (nonatomic, retain) Places *places;

@end
