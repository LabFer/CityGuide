//
//  Discounts.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 07/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Discounts : NSManagedObject

@property (nonatomic, retain) NSNumber * dateEnd;
@property (nonatomic, retain) NSNumber * dateStart;
@property (nonatomic, retain) NSString * descript;
@property (nonatomic, retain) NSNumber * discountID;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * placeID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameType;
@property (nonatomic, retain) NSNumber * slider;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * viewCount;
@property (nonatomic, retain) NSNumber * viewItem;

@end
