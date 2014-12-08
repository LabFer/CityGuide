//
//  Comments.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 08/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comments : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * placeID;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photo;

@end
