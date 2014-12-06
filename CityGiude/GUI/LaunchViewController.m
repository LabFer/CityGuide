//
//  LaunchViewController.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 15/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "LaunchViewController.h"
#import "SyncEngine.h"
#import "Constants.h"

@implementation LaunchViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.statusView.layer.cornerRadius = kImageViewCornerRadius;
    self.progressBar.progress = 0.0f;
    
    [SyncEngine sharedEngine].delegate = self;

    [[SyncEngine sharedEngine] downloadJSONDataFromServer];
}


-(void)startMainScreen{

    [self performSegueWithIdentifier:@"segueFromLaunchToDrawer" sender:self];
}

-(void)startCacheMap{
    [[SyncEngine sharedEngine] downloadMapCache];
}

-(void)setProgressValueMb:(NSNumber*)totalRead totalBytesExpected:(NSNumber*)totalBytesExpected{
    self.progressBar.progress = totalRead.floatValue / totalBytesExpected.floatValue;
    self.progressLabel.text = [NSString stringWithFormat:@"%@ / %@", totalRead, totalBytesExpected];
}

-(void)setProgressValue:(NSNumber*)totalRead totalBytesExpected:(NSNumber*)totalBytesExpected{
    self.progressBar.progress = totalRead.floatValue / totalBytesExpected.floatValue;
    self.progressLabel.text = [NSString stringWithFormat:@"%@ / %@", totalRead, totalBytesExpected];
}

-(void)setStatusLabelText:(NSString*)text{
    NSLog(@"setStatusLabelText: %@", text);
    [self.statusLabel setText:text];
}

-(void)setSubStatusLabelText:(NSString*)text{
    NSLog(@"setSubStatusLabelText: %@", text);
    [self.substatusLabel setText:text];
}

@end
