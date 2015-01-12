//
//  EstimateView.h
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 30/03/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *imageBkg;
@property (strong, nonatomic) IBOutlet UIImageView *imageShare;

@property (nonatomic, strong) UIButton *btnNever;
@property (nonatomic, strong) UIButton *btnLater;
@property (nonatomic, strong) UIButton *btnEstimate;

@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblSubTitle;

@property (nonatomic, strong) NSNumber *parentID;
@property (nonatomic, strong) NSString *parentType;
@property (nonatomic, strong) UIViewController *destinationViewController;

-(id)initWithFrame:(CGRect)frame andDestinationViewController:(UIViewController*)vc;

- (void)showInView:(UIViewController*)aViewController animated:(BOOL)anAnimated;
-(void)setAlertText:(NSString*)alertText;
-(void)setAlertImage:(NSString*)alertImageUrl;

-(void)setAlertParetnID:(NSNumber*)parentID;
-(void)setAlertParentType:(NSString*)parentType;
-(void)setActivityDestinationVC:(UIViewController*)dest;

@end
