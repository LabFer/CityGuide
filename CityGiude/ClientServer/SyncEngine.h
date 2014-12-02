//
//  SyncEngine.h
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 26.12.13.
//  Copyright (c) 2013 Appsgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface SyncEngine : NSObject

@property (atomic, readonly) BOOL syncInProgress;
@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) NSMutableDictionary *downloadDictionary;

+(SyncEngine*)sharedEngine;

-(void)startSync;
-(void)finishSync;
-(void)downloadJSONDataFromServer;
-(void)downloadBannersFromServer;
-(void)downloadArticleFromServer;

-(void)reloadCollectionView;

-(void)setTimeStamp:(NSNumber*)timeStamp;
-(NSNumber*)getTimeStamp;

-(BOOL)allowUseInternetConnection;
-(void)resumeDownloadingFile;

//-(void)downloadFile:(ChildBook*)aBook indexPath:(NSIndexPath*)idx;

@end
