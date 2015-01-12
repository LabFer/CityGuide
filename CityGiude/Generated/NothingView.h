//
//  NothingView.h
//  ChildBook
//
//  Created by Dmitry Kuznetsov on 17.01.14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NothingView : UIView

@property (nonatomic, strong) UILabel *lblTitle;

- (void)showInView:(UIView*)aView animated:(BOOL)anAnimated;
- (void)hideWithAnimation:(BOOL)anAnimation;

-(void)setInfoLabel:(NSString*)infoText;

@end
