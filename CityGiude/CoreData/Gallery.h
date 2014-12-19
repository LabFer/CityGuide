//
//  Gallery.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 13/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Places;

@interface Gallery : NSManagedObject

@property (nonatomic, retain) NSNumber * galleryID;
@property (nonatomic, retain) NSString * photo_big;
@property (nonatomic, retain) NSString * photo_small;
@property (nonatomic, retain) Places *places;

@end
