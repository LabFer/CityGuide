//
//  Banners.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 13/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Banners : NSManagedObject

@property (nonatomic, retain) NSNumber * bannerID;
@property (nonatomic, retain) NSString * bannerName;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * showName;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;

@end
