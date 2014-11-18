//
//  LaunchViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 15/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "LaunchViewController.h"
#import "SyncEngine.h"

@implementation LaunchViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [SyncEngine sharedEngine].delegate = self;
    [[SyncEngine sharedEngine] downloadJSONDataFromServer];
}


-(void)startMainScreen{

    [self performSegueWithIdentifier:@"segueFromLaunchToDrawer" sender:self];
}
@end
