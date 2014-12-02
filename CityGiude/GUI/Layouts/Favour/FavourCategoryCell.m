//
//  FavourCategoryCell.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 23/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "FavourCategoryCell.h"
#import "Constants.h"

@implementation FavourCategoryCell


-(void)awakeFromNib{
    
    self.cellContentView.frame = self.bounds;
    self.btnDeleteCategory.hidden = YES;
    
    //add Swipe right to here
    NSLog(@"add swipe gesture");
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    leftSwipe.delegate = self;
    leftSwipe.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
    rightSwipe.numberOfTouchesRequired = 1;
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:rightSwipe];
    
}
-(void)handleSwipeRight:(UISwipeGestureRecognizer *)swipe {
    
    NSLog(@"handleSwipeRight");
    [UIView animateWithDuration:.25 animations:^
     {
         //self.cellContentView.alpha = 1;
         self.cellContentView.frame = self.bounds;
     } completion:nil];
    [self.btnDeleteCategory setHidden:YES];
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)swipe {
    
    NSLog(@"handleSwipeLeft");
    [self.btnDeleteCategory setHidden:NO];
    [UIView animateWithDuration:.25 animations:^
     {
         //self.coverView.alpha = 0;
         CGRect frame = self.cellContentView.frame;
         frame.origin.x = -80;
         self.cellContentView.frame = frame;
     } completion:nil];
}

- (IBAction)btnDeleteCategoryPressed:(id)sender {
    NSLog(@"Cell brnDeletePressed");
    if([self.delegate respondsToSelector:@selector(btnDeleteCategoryPressed:forCell:)])
        [self.delegate btnDeleteCategoryPressed:sender forCell:self];
}

+ (NSString *)reuseId
{
    return kReuseFavourCategoryCellID;
}

@end
