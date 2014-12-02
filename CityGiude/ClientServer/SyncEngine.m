//
//  SyncEngine.m
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 26.12.13.
//  Copyright (c) 2013 Appsgroup. All rights reserved.
//

#import "SyncEngine.h"
#import "AFNetworking.h"
#import "DBWork.h"
#import "AppDelegate.h"

#import "Reachability.h"

#import "AFDownloadRequestOperation.h"
#import "MMDrawerController.h"
#import "Constants.h"

#import "LaunchViewController.h"

#import "SSZipArchive.h"


@implementation SyncEngine

@synthesize syncInProgress = _syncInProgress;

+(SyncEngine*)sharedEngine{
    static SyncEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[SyncEngine alloc] init];
        sharedEngine.downloadDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    });
    
    return sharedEngine;
}

-(void)startSync{
    if(!self.syncInProgress){
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self downloadJSONDataFromServer];
        });
    }
}

-(void)finishSync{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
        
    }); //TODO: add notification for sync complete
}

-(void)downloadJSONDataFromServer{

    NSNumber *timeStamp = [self getTimeStamp];
//    NSLog(@"timeStamp: %@", timeStamp);
    
    // ======== Get data from server ========

//    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:DEVICE_KEY, @"type", timeStamp, @"time", @"books", @"method", nil];
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLong:1212333333], @"time", @"update", @"method", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSLog(@"Total JSON complete!");
        [self downloadZipFile:[(NSDictionary*)responseObject objectForKey:@"data"]];
//        [[DBWork shared] inserDataFromArray:[(NSDictionary*)responseObject objectForKey:@"new"]];
//        [[DBWork shared] deleteItems:[(NSDictionary*)responseObject objectForKey:@"delete"]];
//        [[DBWork shared] updateDataFromArray:[(NSDictionary*)responseObject objectForKey:@"update"]];
        
        
        //NSLog(@"Update: %@", [(NSDictionary*)responseObject objectForKey:@"update"]);
//        [self setTimeStamp:[(NSDictionary*)responseObject objectForKey:@"time"]];

//        [[DBWork shared] setBooksArray];
        
//        [self reloadCollectionView];
                
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if([self.delegate isKindOfClass:[LaunchViewController class]])
            [self.delegate performSelector:@selector(startMainScreen)];
//        [self reloadCollectionView];
    }];
    

    
//    [self finishSync];
}


-(void)downloadMapCache{
    
    NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"mapbox" ofType:@"json"];
    NSError *error;
    NSString* tileJSON = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"Cache error %@",error);
    
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    [tileSource setCacheable:YES];
    
    //    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    //    NSString* foofile = [documentsPath stringByAppendingPathComponent:@"RMTileCache.db"];
    //    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:foofile];
    
    
    RMTileCache *dCache = [[RMTileCache alloc] init];
    
    for (id cache in dCache.tileCaches)
    {
        if ([cache isKindOfClass:[RMDatabaseCache class]])
        {
            RMDatabaseCache *dbCache = (RMDatabaseCache *)cache;
            NSLog(@"current cache size: %lld", dbCache.fileSize);
            [dCache setBackgroundCacheDelegate:self];
            NSInteger minZoom = tileSource.minZoom;
            NSInteger maxZoom = tileSource.maxZoom; // here I am fetching all but this might be too much
            [dCache beginBackgroundCacheForTileSource:tileSource
                                            southWest:CLLocationCoordinate2DMake(56.759286, 60.447637)
                                            northEast:CLLocationCoordinate2DMake(56.905416, 60.660497)
                                              minZoom:minZoom
                                              maxZoom:maxZoom];
            
            break;
        }
    }

}

- (void)tileCache:(RMTileCache *)tileCache didBeginBackgroundCacheWithCount:(NSUInteger)tileCount forTileSource:(id<RMTileSource>)tileSource {
    NSLog(@"Caching started");
}

- (void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount
{
    NSLog(@"Caching Tile %lu of Total %lu", tileIndex, totalTileCount);
}

- (void)tileCacheDidFinishBackgroundCache:(RMTileCache *)tileCache {
    NSLog(@"Cache loading has been finished");
}
-(void)downloadArticleFromServer{
    
//    //NSString *strURL = URL_API;
//    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:@"article", @"method", @"3", @"id", nil];
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    [manager GET:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        //NSLog(@"Article: %@", (NSDictionary*)responseObject);
//        [self setArticle:[(NSDictionary*)responseObject objectForKey:@"data"] ];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
    
    [self finishSync];
}

-(void)setArticle:(NSDictionary*)article{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:article forKey:@"article"];
    [userDefaults synchronize];
}

-(void)setTimeStamp:(NSNumber *)timeStamp{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:timeStamp forKey:@"timeStamp"];
    [userDefaults synchronize];
    //NSLog(@"Set timeStamp: %@", timeStamp);
}

-(NSNumber*)getTimeStamp{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *timeStamp = [userDefaults objectForKey:@"timeStamp"];
    
    if(!timeStamp)
        timeStamp = [NSNumber numberWithInt:0];
    
    //NSLog(@"Get timeStamp: %@", timeStamp);
    return timeStamp;
}

-(void)reloadCollectionView{
//    //NSLog(@"");
//    
//    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:DEVICE_STORYBOARD bundle:[NSBundle mainBundle]];;// = appDelegate.window.rootViewController.storyboard;
//    
//    
//    MMDrawerController *startController = [storyboard instantiateViewControllerWithIdentifier:@"START_SCREEN"];
//    NSLog(@"START_SCREEN");
//    appDelegate.window.rootViewController = startController;
}

//-(BOOL)allowUseInternetConnection{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSNumber *shouldUse3G = [userDefaults objectForKey:@"shouldUse3G"];
//    //NSLog(@"%@", shouldUse3G);
//    
//    if(!shouldUse3G){
//        shouldUse3G = [NSNumber numberWithBool:YES];
//        [userDefaults setObject:shouldUse3G forKey:@"shouldUse3G"];
//        [userDefaults synchronize];
//    }
//    
//    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    BOOL allowConnection = YES;
//    
//    if(appDelegate.netStatus == NotReachable){
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ChildBook"
//                                                          message:@"Нет подключения к интернету!"
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        [message show];
//        allowConnection = NO;
//    }
//    else if((appDelegate.netStatus == ReachableViaWWAN) && (shouldUse3G.boolValue == NO)){
//        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"ChildBook"
//                                                          message:@"Приложение не может использовать GPRS(3G) подключение для загрузки книг. Измените способ подключения к интернету в окне настроек."
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        [message show];
//        allowConnection = NO;
//    }
//
//    
//    return allowConnection;
//}

#pragma mark - FileDownloader

-(void)downloadZipFile:(NSString*)filePath{
    
    NSString *url = [URL_BASE stringByAppendingString:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *path = [CACHE_DIR stringByAppendingPathComponent:filePath];
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:path shouldResume:YES];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Successfully downloaded file to %@", path);
            [SSZipArchive unzipFileAtPath:path toDestination:CACHE_DIR];
        
            NSString *fileNameNoExtension = [[path lastPathComponent] stringByDeletingPathExtension];
            NSString *fileName = [fileNameNoExtension stringByAppendingString: @".json"];
            NSString *json = [CACHE_DIR stringByAppendingPathComponent:fileName];
        
            NSError *error;
            NSData *allCoursesData = [NSData dataWithContentsOfFile:json options:NSDataReadingUncached error:&error];
        
            if(error)
                NSLog(@"dataWithContentsOfFile error :%@", error);
        
            NSArray *jsonData = [NSJSONSerialization
                                           JSONObjectWithData:allCoursesData
                                           options:NSJSONReadingMutableContainers
                                           error:&error];
        
            NSLog(@"jsonData: %@", jsonData);
            if(jsonData){
                BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                if (!deleted) {
                    NSLog(@"jsonData. Unable to delete ZIP file %@, reason: %@", path, error);
                }
                
                deleted = [[NSFileManager defaultManager] removeItemAtPath:json error:&error];
                if (!deleted) {
                    NSLog(@"jsonData. Unable to delete JSON file %@, reason: %@", json, error);
                }
        
                [[DBWork shared] inserDataFromDictionary:jsonData[0]];
                NSLog(@"Inserting data is completed!!!");
            }
            else{
                BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                if (!deleted) {
                    NSLog(@"!jsonData. Unable to delete ZIP file %@, reason: %@", path, error);
                }
                
                deleted = [[NSFileManager defaultManager] removeItemAtPath:json error:&error];
                if (!deleted) {
                    NSLog(@"!jsonData. Unable to delete JSON file %@, reason: %@", json, error);
                }
            }
        
            if([self.delegate isKindOfClass:[LaunchViewController class]])
               [self.delegate performSelector:@selector(startMainScreen)];

            //NSLog(@"complete operation: %@, %@", json, allCourses);
        

        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Download zip file error: %@", error.userInfo);

    }];

    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile){
    //
    //        //CGFloat progress = totalBytesReadForFile/totalBytesExpectedToReadForFile;
        NSNumber *progress = [NSNumber numberWithFloat:(float)totalBytesReadForFile/totalBytesExpectedToReadForFile];
    //
        NSLog(@"%@", progress);
    //
    //        [self.delegate performSelector:@selector(updateDownloadProgress:progress:) withObject:[operation.userInfo objectForKey:@"bookID"]  withObject:progress];
    }];
    //    
    [operation start];
    
    
}
//-(void)downloadFile:(ChildBook*)aBook indexPath:(NSIndexPath*)idx{
//    
//    NSString *str = @"http://childbook.appsgroup.ru/";
//    NSString *url = [str stringByAppendingString:aBook.file];
//    NSString *file = [aBook.name stringByAppendingString:@".mp3"];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [CACHE_DIR stringByAppendingPathComponent:file];
//    
//    //NSArray *param = [NSArray arrayWithObjects:aBook.bookID, path, nil];
//    if(![self.downloadDictionary objectForKey:aBook.bookID]){
//        [self.downloadDictionary setObject:path forKey:aBook.bookID];
//        //NSLog(@"%@", self.downloadDictionary);
//    }
//    
//    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:path shouldResume:YES];
//    
//    //NSLog(@"start operation: %@ ==== %@", aBook.bookID, operation.userInfo);
//    operation.userInfo = [NSDictionary dictionaryWithObject:aBook.bookID forKey:@"bookID"];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //NSLog(@"Successfully downloaded file to %@", path);
//        //NSLog(@"complete operation: %@", operation);
//        
//        [self.delegate performSelector:@selector(downloadComplete:) withObject:[operation.userInfo objectForKey:@"bookID"]];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //NSLog(@"Error: %@", error.userInfo);
//        NSError *e  = [error.userInfo objectForKey:@"NSUnderlyingError"];
//        if([e code] == 17){
//            [self.delegate performSelector:@selector(downloadComplete:) withObject:[operation.userInfo objectForKey:@"bookID"]];
//        }
//    }];
//    
//    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile){
//        
//        //CGFloat progress = totalBytesReadForFile/totalBytesExpectedToReadForFile;
//        NSNumber *progress = [NSNumber numberWithFloat:(float)totalBytesReadForFile/totalBytesExpectedToReadForFile];
//        
//        //NSLog(@"%@", progress);
//        
//        [self.delegate performSelector:@selector(updateDownloadProgress:progress:) withObject:[operation.userInfo objectForKey:@"bookID"]  withObject:progress];
//    }];
//    
//    [operation start];
//}

//-(void)resumeDownloadingFile{
//    if(self.downloadDictionary.count){
//       // NSLog(@"resumeDownloadingFile");
//        for(NSString *key in [self.downloadDictionary allKeys]) {
//            NSLog(@"%@", key);
//            
//            NSString *str = [NSString stringWithFormat:@"SELF.bookID == %@", key];
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:str];//@"SELF.isDownloaded.boolValue == YES"];
//            ChildBook *aBook = [[BooksData shared].books filteredArrayUsingPredicate:predicate].lastObject;
//            [self downloadFile:aBook indexPath:nil];
//        }
//        
//    }
//}

@end
