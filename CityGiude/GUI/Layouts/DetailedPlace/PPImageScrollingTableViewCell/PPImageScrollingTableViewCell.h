//
//  PPScrollingTableViewCell.h
//  PPImageScrollingTableViewControllerDemo
//
//  Created by popochess on 13/8/10.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPImageScrollingCellView.h"
@class PPImageScrollingTableViewCell;

@protocol PPImageScrollingTableViewCellDelegate <NSObject>

// Notifies the delegate when user click image
- (void)scrollingTableViewCell:(PPImageScrollingTableViewCell *)scrollingTableViewCell didSelectImageAtIndexPath:(NSIndexPath*)indexPathOfImage atCategoryRowIndex:(NSInteger)categoryRowIndex;

@end

@interface PPImageScrollingTableViewCell : UITableViewCell

@property (weak, nonatomic) id<PPImageScrollingTableViewCellDelegate> delegate;
@property (nonatomic) CGFloat height;
@property(strong, nonatomic) PPImageScrollingCellView *imageScrollingView;

- (void) setImageData:(NSDictionary*) image;
- (void) setCollectionViewBackgroundColor:(UIColor*) color;
- (void) setCategoryLabelText:(NSString*)text withColor:(UIColor*)color;
- (void) setImageTitleLabelWitdh:(CGFloat)width withHeight:(CGFloat)height;
- (void) setImageTitleTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)bgColor;
- (void) setScrollViewWidth:(CGFloat)width;

+ (NSString *)reuseId;


@end