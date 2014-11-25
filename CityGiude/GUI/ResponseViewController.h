//
//  ResponseViewController.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 25/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResponseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *responseView;
@property (weak, nonatomic) IBOutlet UIView *starView;

- (IBAction)sendResponseBtnPressed:(id)sender;


@end
