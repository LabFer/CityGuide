//
//  HouseListCell.m
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 12/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "FavourPlaceListCell.h"
#import "Constants.h"

@implementation FavourPlaceListCell

//Cell.m
-(void)awakeFromNib{

    self.cellContentView.frame = self.bounds;
    self.btnDelete.hidden = YES;
    
    //add Swipe right to here
//    NSLog(@"add swipe gesture");
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

//    NSLog(@"handleSwipeRight");
    [UIView animateWithDuration:.25 animations:^
     {
         //self.cellContentView.alpha = 1;
         self.cellContentView.frame = self.bounds;
     } completion:nil];
    [self.btnDelete setHidden:YES];
}

-(void)handleSwipeLeft:(UISwipeGestureRecognizer *)swipe {

//    NSLog(@"handleSwipeLeft");
    [self.btnDelete setHidden:NO];
    [UIView animateWithDuration:.25 animations:^
     {
         //self.coverView.alpha = 0;
         CGRect frame = self.cellContentView.frame;
         frame.origin.x = -80;
         self.cellContentView.frame = frame;
     } completion:nil];
}

- (IBAction)brnDeletePressed:(id)sender {
//    NSLog(@"Cell brnDeletePressed");
    if([self.delegate respondsToSelector:@selector(btnDeletePressed:forCell:)])
        [self.delegate btnDeletePressed:sender forCell:self];
}

+ (NSString *)reuseId
{
    return kReuseFavourPlaceListCellID;
}

@end
