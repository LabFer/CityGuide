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
#import "UIUserSettings.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


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
#pragma mark - Delegate Methods
-(void)updateStatusLabels:(NSString*)statusText withSubstatus:(NSString*)substatusTest{
    if([self.delegate isKindOfClass:[LaunchViewController class]]){
        [self.delegate performSelector:@selector(setUpdateStatusText:withSubstatus:) withObject:statusText withObject:substatusTest];
    }
}

#pragma mark - Check New Data On Server

-(void)downloadJSONDataFromServer{
    NSLog(@"downloadJSONDataFromServer");
    
    NSNumber *timeStamp = [self getTimeStamp];
    NSLog(@"timeStamp: %@", timeStamp);
    
    // ======== Get data from server ========
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:timeStamp, @"time", @"update", @"method", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [self updateStatusLabels:@"Загрузка" withSubstatus:@"Запрос обновлений с сервера"];
    
    [manager GET:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if(timeStamp.integerValue == 0){
            if([self.delegate isKindOfClass:[LaunchViewController class]]){
                LaunchViewController *launchScreen = (LaunchViewController *)self.delegate;
                launchScreen.statusView.hidden = NO;
                launchScreen.activityIndicator.hidden = YES;
                [launchScreen.activityIndicator stopAnimating];
            }
            NSNumber *time = [(NSDictionary*)responseObject objectForKey:@"time"];
            [self setTimeStamp:time];
            [self downloadZipFile:[(NSDictionary*)responseObject objectForKey:@"data"]];
        }
        else{
            if([self.delegate isKindOfClass:[LaunchViewController class]])
                [self.delegate performSelector:@selector(successCheckNewData:) withObject:(NSDictionary*)responseObject];
        }

        NSLog(@"Total JSON complete!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self updateStatusLabels:@"Загрузка" withSubstatus:@"Ошибка запроса обновлений"];
        if([self.delegate isKindOfClass:[LaunchViewController class]])
            [self.delegate performSelector:@selector(errorDownloadJSONFromServer)];
    }];
    

    
//    [self finishSync];
}

#pragma mark - Map Cache
-(void)downloadMapCache{
    
    NSLog(@"downloadMapCache");
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
    [self updateStatusLabels:@"Загрузка" withSubstatus:@"Загрузка карты"];
}

- (void)tileCache:(RMTileCache *)tileCache didBackgroundCacheTile:(RMTile)tile withIndex:(NSUInteger)tileIndex ofTotalTileCount:(NSUInteger)totalTileCount
{
    NSLog(@"Caching Tile %lu of Total %lu", tileIndex, totalTileCount);
    NSNumber *totalRead = [NSNumber numberWithInteger:tileIndex];
    NSNumber *totalExpected = [NSNumber numberWithInteger:totalTileCount];
    
    if([self.delegate isKindOfClass:[LaunchViewController class]])
        [self.delegate performSelector:@selector(setProgressValue:totalBytesExpected:) withObject:totalRead withObject:totalExpected];
}

- (void)tileCacheDidFinishBackgroundCache:(RMTileCache *)tileCache {
    NSLog(@"Cache loading has been finished");
    
    [self updateStatusLabels:@"Загрузка" withSubstatus:@"Загрузка карты завершена"];
    if([self.delegate isKindOfClass:[LaunchViewController class]]){
        [self.delegate performSelector:@selector(startMainScreen)];
    }
}

#pragma mark - Banners
-(void)downloadBannersFromServer{
    
    NSLog(@"downloadBannersFromServer");
    
    // ======== Get data from server ========
    
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:DEVICE_KEY, @"typeDevice", @"baner", @"method", nil];
    //NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys: @"banner", @"method", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [self updateStatusLabels:@"Загрузка" withSubstatus:@"Загрузка баннеров"];
    
    [manager GET:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Banner JSON: %@", responseObject);
        
        [[DBWork shared] insertBannersFromArray:[responseObject objectForKey:@"data"]];
        NSLog(@"Total Banner JSON complete!");

       // [self downloadMapCache];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self updateStatusLabels:@"Загрузка" withSubstatus:@"Ошибка загрузки баннеров"];
        if([self.delegate isKindOfClass:[LaunchViewController class]])
            [self.delegate performSelector:@selector(errorUpdateDataFromServer)];
    }];
    
    
    
    //    [self finishSync];
}

-(void)downloadArticleFromServer{
    NSLog(@"downloadArticleFromServer");
    
    
    NSURL *URL = [NSURL URLWithString:@"http://lsg.appsgroup.ru/mob.php?id=1"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", string);
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:string forKey:@"article"];
        [userDefaults synchronize];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"downloadArticleFromServer. Error: %@", error);
    }];
    [op start];
    
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
    NSLog(@"Set timeStamp: %@", timeStamp);
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

-(BOOL)allowUseInternetConnection{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *shouldUse3G = [userDefaults objectForKey:@"shouldUse3G"];
    //NSLog(@"%@", shouldUse3G);
    
    if(!shouldUse3G){
        shouldUse3G = [NSNumber numberWithBool:YES];
        [userDefaults setObject:shouldUse3G forKey:@"shouldUse3G"];
        [userDefaults synchronize];
    }
    
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    BOOL allowConnection = YES;
    
    if(appDelegate.netStatus == NotReachable){
//        //UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"CityGuide"
//                                                          message:@"Нет подключения к интернету!"
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        //[message show];
        allowConnection = NO;
    }
    else if((appDelegate.netStatus == ReachableViaWWAN) && (shouldUse3G.boolValue == NO)){
//        //UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"CityGuide"
//                                                          message:@"Приложение не может использовать GPRS(3G) подключение для загрузки книг. Измените способ подключения к интернету в окне настроек."
//                                                         delegate:nil
//                                                cancelButtonTitle:@"OK"
//                                                otherButtonTitles:nil];
//        [message show];
        allowConnection = NO;
    }

    
    return allowConnection;
}

#pragma mark - FileDownloader

-(void)downloadZipFile:(NSString*)filePath{
    
    NSLog(@"downloadZipFile");
    
    NSString *url = [URL_BASE stringByAppendingString:filePath];
    NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
    url = [url stringByAppendingString:[NSString stringWithFormat:@"?%f", timeInMiliseconds]];
    NSLog(@"downloadZipFile: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *path = [CACHE_DIR stringByAppendingPathComponent:filePath];
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:path shouldResume:YES];
    operation.shouldOverwrite = YES;
    
    [self updateStatusLabels:@"Загрузка" withSubstatus:@"Загрузка архива с сервера"];
    
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
        
            //NSLog(@"jsonData: %@", jsonData);
            if(jsonData){
                BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                if (!deleted) {
                    NSLog(@"jsonData. Unable to delete ZIP file %@, reason: %@", path, error);
                }
                
                deleted = [[NSFileManager defaultManager] removeItemAtPath:json error:&error];
                if (!deleted) {
                    NSLog(@"jsonData. Unable to delete JSON file %@, reason: %@", json, error);
                }
        
                [self updateStatusLabels:@"Обработка" withSubstatus:@"Обработка данных"];
                
                [[DBWork shared] inserDataFromDictionary:jsonData[0]];
                NSLog(@"Inserting data is completed!!!");
                [self updateStatusLabels:@"Обработка" withSubstatus:@"Обработка данных завершена"];
                
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
        
            [self downloadBannersFromServer];
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Download zip file error: %@", error.userInfo);
            [self updateStatusLabels:@"Загрузка" withSubstatus:@"Ошибка запроса обновлений"];
            if([self.delegate isKindOfClass:[LaunchViewController class]])
                [self.delegate performSelector:@selector(errorUpdateDataFromServer)];
    }];

    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile){
    //
    //        //CGFloat progress = totalBytesReadForFile/totalBytesExpectedToReadForFile;
        NSNumber *progress = [NSNumber numberWithFloat:(float)totalBytesReadForFile/totalBytesExpectedToReadForFile];
        
        NSNumber *totalRead = [NSNumber numberWithLongLong:totalBytesReadForFile];
        NSNumber *totalExpected = [NSNumber numberWithLongLong:totalBytesExpectedToReadForFile];
        
        if([self.delegate isKindOfClass:[LaunchViewController class]])
            [self.delegate performSelector:@selector(setProgressValueMb:totalBytesExpected:) withObject:totalRead withObject:totalExpected];
    //
        NSLog(@"%@", progress);
    //
    //        [self.delegate performSelector:@selector(updateDownloadProgress:progress:) withObject:[operation.userInfo objectForKey:@"bookID"]  withObject:progress];
    }];
    //    
    [operation start];
    
    
}

-(void)registerUser{

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
    
    if(userProfile){
        
        NSString *socialName = @"";
        if([[userProfile objectForKey:kSocialType] isEqualToString:kSocialFacebookProfile]){
            socialName = @"facebook";
        }
        else if([[userProfile objectForKey:kSocialType] isEqualToString:kSocialVKontakteProfile]){
            socialName = @"vkontakte";
        }
        else if([[userProfile objectForKey:kSocialType] isEqualToString:kSocialTwitterProfile]){
            socialName = @"twitter";
        }
        
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    DEVICE_KEY, @"typeDevice",
                                    [userProfile objectForKey:kSocialUserPhone], @"phone",
                                    [userProfile objectForKey:kSocialUserEmail], @"email",
                                    [userProfile objectForKey:kSocialUserPhoto], @"photo",
                                    [NSString stringWithFormat:@"%@ %@", [userProfile objectForKey:kSocialUserFirstName], [userProfile objectForKey:kSocialUserLastName]], @"name",
                                    socialName, @"socialName",
                                    [userProfile objectForKey:kSocialUserID], @"socialID",
                                    @"userlogin", @"method", nil];
        
        //NSString* URL_API = @"http://opros.appsgroup.ru/api/ios_v1/api.php";
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"UserLogin. Validation responceDict: %@", responseObject);
            NSDictionary *responce = (NSDictionary*)responseObject;
            NSNumber *code = [responce objectForKey:@"code"];
            NSLog(@"code: %@", code);
            if(code.intValue == 0){
                
                NSDictionary *updateUser = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [userProfile objectForKey:kSocialType], kSocialType,
                                            [userProfile objectForKey:kSocialUserFirstName], kSocialUserFirstName,
                                            [userProfile objectForKey:kSocialUserLastName], kSocialUserLastName,
                                            [userProfile objectForKey:kSocialUserID], kSocialUserID,
                                            [userProfile objectForKey:kSocialUserEmail], kSocialUserEmail,
                                            [userProfile objectForKey:kSocialUserPhone], kSocialUserPhone,
                                            [responce objectForKey:@"data"], kSocialUserToken,
                                            [userProfile objectForKey:kSocialUserPhoto], kSocialUserPhoto, nil];
                
                [userDefaults removeObjectForKey:kSocialUserProfile];
                [userDefaults synchronize];
                
                [userDefaults setObject:updateUser forKey:kSocialUserProfile];
                [userDefaults synchronize];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                NSLog(@"UserLogin success!");
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                                  message:kAlertRegisterUserSuccess
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
                [self uploadFavourites];
            }
            else{
                NSLog(@"UserLogin Error: %@", [responseObject objectForKey:@"errorText"]);
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                                  message:kAlertRegisterUserError
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [message show];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"UserLogin connection Error: %@", error);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:kApplicationTitle
                                                              message:kAlertRegisterUserError
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        }];
    }
}

#pragma mark - Favourites

-(void)uploadFavourites{
    
    
    NSArray *favourites = [[DBWork shared] getUnsyncFavourites];
    
    //NSLog(@"uploadFavourites: %lu", (unsigned long)favourites.count);
    if(favourites.count == 0){
        //NSLog(@"Have no favourites for upload!");
        [self getFavourites];
        return;
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(Favourites *f in favourites){
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:f.userToken, @"usertoken", f.favourType, @"favoritetype", f.parentID, @"favoriteid", nil];
        
        [items addObject:d];
      
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:items
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *JSONString = @"";
    if (!jsonData) {
        NSLog(@"uploadFavourites. JSON error: %@", error);
    }
    else {
        JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        //NSLog(@"syncFavourites. JSON OUTPUT: %@",JSONString);
    }
    
//    
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                /*DEVICE_KEY, @"typeDevice",*/
                                JSONString, @"favorites",
                                @"addfavorite", @"method", nil];
    
    //NSLog(@"uploadFavourites. parameters: %@", parameters);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"uploadFavourites. Validation responceDict: %@", responseObject);
        NSDictionary* arr = (NSDictionary*)responseObject;
        NSNumber *code = [arr objectForKey:@"code"];
        if(code.integerValue == 0){
            NSLog(@"uploadFavourites. Sync OK");
            [self getFavourites];

        }
        else{
            NSLog(@"uploadFavourites. Sync NOT OK");
            
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"uploadFavourites. Validation connection Error: %@", error);
    }];
}

-(void)getFavourites{
    //NSLog(@"getFavourites");
    
    
    UIUserSettings *us = [[UIUserSettings alloc] init];
    if(![us isUserAuthorized]){
        //NSLog(@"User not authorized");
        [self deleteFavourites];
        return;
    }    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userProfile = [userDefaults objectForKey:kSocialUserProfile];
    NSString *userToken = [userProfile objectForKey:kSocialUserToken];
    
    if(![userToken isEqualToString:@""]){
    
        // ======== Get data from server ========
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:userToken, @"usertoken", @"getfavorite", @"method", nil];
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager GET:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"getFavourites JSON: %@", responseObject);
            NSDictionary* arr = (NSDictionary*)responseObject;
            NSNumber *code = [arr objectForKey:@"code"];
            if(code.integerValue == 0){
                NSArray *data = [arr objectForKey:@"data"];
                [[DBWork shared] insertFavouritesFromArray:data];
                [self deleteFavourites];
            }
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"getFavourites. Error: %@", error);
        
        }];
    }
    else{
        NSLog(@"userToken is empty");
    }
    
}

-(void)deleteFavourites{
    
    
    NSArray *favourites = [[DBWork shared] getDeletedFavourites];
    
    //NSLog(@"deleteFavourites: %lu", (unsigned long)favourites.count);
    if(favourites.count == 0){
        NSLog(@"Have no favourites for deleting!");
        return;
    }
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(Favourites *f in favourites){
        NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:f.favourID, @"id", nil];
        
        [items addObject:d];
        
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:items
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *JSONString = @"";
    if (!jsonData) {
        NSLog(@"deleteFavourites. JSON error: %@", error);
    }
    else {
        JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        //NSLog(@"deleteFavourites. JSON OUTPUT: %@",JSONString);
    }
    
    //
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                /*DEVICE_KEY, @"typeDevice",*/
                                JSONString, @"delfavid",
                                @"delfavorite", @"method", nil];
    
    //NSLog(@"deteletFavourites. parameters: %@", parameters);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"deleteFavourites. Validation responceDict: %@", responseObject);
        NSDictionary* arr = (NSDictionary*)responseObject;
        NSNumber *code = [arr objectForKey:@"code"];
        if(code.integerValue == 0){
            NSLog(@"deleteFavourites. Sync OK");
            
            [[DBWork shared] deleteFavouritesFromArray:items];
            
        }
        else{
            NSLog(@"deleteFavourites. Sync NOT OK");
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"deleteFavourites. Validation connection Error: %@", error);
    }];
}

-(void)downloadPlaceItemFromServer:(NSNumber*)placeID{
    NSLog(@"downloadPlaceItemFromServer");
    
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if(appDelegate.netStatus == ReachableViaWWAN){
        CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
        if(telephonyInfo.currentRadioAccessTechnology == CTRadioAccessTechnologyEdge) //если EDGE, то ничего не делаем
            return;
    }
    
    // ======== Get data from server ========
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys: placeID, @"placeID", @"place", @"method", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"getFavourites JSON: %@", responseObject);
        NSDictionary* arr = (NSDictionary*)responseObject;
        NSNumber *code = [arr objectForKey:@"code"];
        if(code.integerValue == 0){
            NSDictionary *data = [arr objectForKey:@"data"];
            NSArray *places = [data objectForKey:@"place"];
            [[DBWork shared] insertPlacesFromArray:places];
            NSLog(@"downloadPlaceItemFromServer. Success!");
        }
        else{
            NSLog(@"downloadPlaceItemFromServer. Error code: %@", code);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"downloadPlaceItemFromServer. Error: %@", error);
        
    }];
}

-(void)downloadDiscountItemFromServer:(NSNumber*)discountID{
    
    NSLog(@"downloadDiscountItemFromServer");
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if(appDelegate.netStatus == ReachableViaWWAN){
        CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
        if(telephonyInfo.currentRadioAccessTechnology == CTRadioAccessTechnologyEdge) //если EDGE, то ничего не делаем
            return;
    }
    
    // ======== Get data from server ========
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys: discountID, @"eventID", @"event", @"method", nil];
        
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
    [manager GET:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"getFavourites JSON: %@", responseObject);
        NSDictionary* arr = (NSDictionary*)responseObject;
        NSNumber *code = [arr objectForKey:@"code"];
        if(code.integerValue == 0){
            NSDictionary *data = [arr objectForKey:@"data"];
            NSArray *discounts = [data objectForKey:@"action"];
            [[DBWork shared] insertDiscountsFromArray:discounts];
            NSLog(@"downloadDiscountItemFromServer. Success!");
        }
        else{
            NSLog(@"downloadDiscountItemFromServer. Error code: %@", code);
        }
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"downloadDiscountItemFromServer. Error: %@", error);
            
    }];
}

-(void)downloadAllDiscountsFromServer{
    
    NSLog(@"downloadAllDiscountsFromServer");
    // ======== Get data from server ========
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys: @"events", @"method", nil];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:URL_API parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"downloadAllDiscountsFromServer: %@", responseObject);
        NSDictionary* arr = (NSDictionary*)responseObject;
        NSNumber *code = [arr objectForKey:@"code"];
        if(code.integerValue == 0){
            NSDictionary *data = [arr objectForKey:@"data"];
            NSArray *discounts = [data objectForKey:@"action"];
            [[DBWork shared] deleteDiscounts];
            [[DBWork shared] insertDiscountsFromArray:discounts];
            NSLog(@"downloadAllDiscountsFromServer. Success!");
        }
        else{
            NSLog(@"downloadAllDiscountsFromServer. Error code: %@", code);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"downloadAllDiscountsFromServer. Error: %@", error);
        
    }];
}


@end
