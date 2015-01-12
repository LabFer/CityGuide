//
//  SingletonMap.h
//  CityGuide
//
//  Created by Timur Khazamov on 13.01.15.
//  Copyright (c) 2015 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RMMapView.h>

@interface SingletonMap : NSObject {
    RMMapView* _map;
}

@property (strong, nonatomic) RMMapView* map;

+ (SingletonMap *)instance;
- (NSDictionary* )parseJSONwithName:(NSString* ) name;

@end
