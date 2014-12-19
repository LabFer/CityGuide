//
//  Values.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 13/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Attributes;

@interface Values : NSManagedObject

@property (nonatomic, retain) NSNumber * valueID;
@property (nonatomic, retain) NSString * valueName;
@property (nonatomic, retain) Attributes *attributes;

@end
