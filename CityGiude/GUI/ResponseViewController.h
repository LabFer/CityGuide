//
//  ResponseViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 25/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"
#import "Places.h"

@interface ResponseViewController : UIViewController <UITextViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet RateView *rateView;

- (IBAction)sendResponseBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *wordCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) Places *aPlace;
@property (nonatomic, assign) id delegate;

@end
