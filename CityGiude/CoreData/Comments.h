//
//  Comments.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 18/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comments : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * create_at;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * place_id;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * user_photo;

@end
