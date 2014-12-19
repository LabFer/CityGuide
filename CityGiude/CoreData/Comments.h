//
//  Comments.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 13/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comments : NSManagedObject

@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSNumber * commentID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * placeID;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * text;

@end
