//
//  AppDelegate.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 09/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Reachability.h"
#import "iLink.h"
#import "Flurry.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, iLinkDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *testArray;

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;

//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
//
//- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;

@property (assign, nonatomic) NetworkStatus netStatus;
@property (strong, nonatomic) Reachability  *hostReach;

- (void)updateInterfaceWithReachability: (Reachability*) curReach;


@end

