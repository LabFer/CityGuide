//
//  Banners.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 18/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Banners : NSManagedObject

@property (nonatomic, retain) NSString * endpoint;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * transaction_type;

@end
