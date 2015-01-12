//
//  NothingView.m
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 17.01.14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "NothingView.h"
#import "Constants.h"

@implementation NothingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

//        CGSize screenSize = frame.size;
//        CGFloat screenWidth = screenSize.width;
//        CGFloat screenHeight = screenSize.height;
        
        UIView *insetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];

        [insetView setBackgroundColor:kDefaultNavBarColor];
        
        insetView.alpha = 0.5f;
        insetView.layer.cornerRadius = 5;
        [self addSubview:insetView];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, insetView.frame.size.width - 5, insetView.frame.size.height)];
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.clipsToBounds = YES;
        [self.lblTitle setNumberOfLines:0];
        [self.lblTitle setBackgroundColor:[UIColor clearColor]];
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            [self.lblTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20.0]];
        }
        else{
            [self.lblTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0]];
        }
        
        self.lblTitle.textColor = [UIColor whiteColor];
        
        //self.lblTitle.text = @"Не загружено ни одной книги";
        [insetView addSubview:self.lblTitle];
 

    }
    return self;
}

- (void)showInView:(UIView*)aView animated:(BOOL)anAnimated
{
    //CGRect endFrame = aView.frame;
    self.center = aView.center;
    
    //self.frame = endFrame;
    if (anAnimated)
    {
        self.alpha = 0.0f;
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             self.alpha = 1.0f;
         }
                         completion:^(BOOL finished)
         {
         }];
    }
    
    [aView addSubview:self];
}

- (void)hideWithAnimation:(BOOL)anAnimation
{
    if (anAnimation)
    {
        [UIView animateWithDuration:1.0
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             [self removeFromSuperview];
         }];
    }
    else
    {
        [self removeFromSuperview];
    }
}

-(void)setInfoLabel:(NSString*)infoText{
    self.lblTitle.text = infoText;
}

@end
