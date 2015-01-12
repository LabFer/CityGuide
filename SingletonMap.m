//
//  SingletonMap.m
//  CityGuide
//
//  Created by Timur Khazamov on 13.01.15.
//  Copyright (c) 2015 Appsgroup. All rights reserved.
//

#import "SingletonMap.h"
#import <RMMBTilesSource.h>

@implementation SingletonMap

static SingletonMap *_singletonMap;

- (id)init {
    self = [super init];
    if (self) {
        _map = [[RMMapView alloc] init];
    }
    return self;
}

+ (SingletonMap *)instance {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _singletonMap = [[SingletonMap alloc] init];
    });
    
    NSLog(@"Map has been initialised");
    return _singletonMap;
}

- (NSDictionary* )parseJSONwithName:(NSString* ) name {
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSError *error;
    //NSString* tileJSON = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    NSData* JSON = [[NSData alloc] initWithContentsOfFile:fullPath];
    id object = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
    NSDictionary *mapViewParams = object;
    return mapViewParams;
}

@end
