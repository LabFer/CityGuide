//
//  LaunchViewController.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 15/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LaunchViewController : UIViewController

-(void)startMainScreen;
-(void)startCacheMap;
-(void)setProgressValueMb:(NSNumber*)totalRead totalBytesExpected:(NSNumber*)totalBytesExpected;
-(void)setProgressValue:(NSNumber*)totalRead totalBytesExpected:(NSNumber*)totalBytesExpected;

-(void)setUpdateStatusText:(NSString*)statusLabelText withSubstatus:(NSString*)substatusLabelText;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *substatusLabel;

-(void)checkNewDataOnServer;
-(void)errorDownloadJSONFromServer;

-(void)errorUpdateDataFromServer;

-(void)successCheckNewData:(NSDictionary*)jsonData;

@end
