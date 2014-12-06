//
//  SyncEngine.h
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 26.12.13.
//  Copyright (c) 2013 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import <Mapbox.h>

@interface SyncEngine : NSObject <RMTileCacheBackgroundDelegate>

@property (atomic, readonly) BOOL syncInProgress;
@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) NSMutableDictionary *downloadDictionary;

+(SyncEngine*)sharedEngine;

-(void)startSync;
-(void)finishSync;
-(void)downloadJSONDataFromServer;
-(void)downloadBannersFromServer;
-(void)downloadArticleFromServer;
-(void)downloadMapCache;

-(void)reloadCollectionView;

-(void)setTimeStamp:(NSNumber*)timeStamp;
-(NSNumber*)getTimeStamp;

-(BOOL)allowUseInternetConnection;


//-(void)downloadFile:(ChildBook*)aBook indexPath:(NSIndexPath*)idx;

@end
