//
//  FavourCategoryCell.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 23/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FavourCategoryListCellDelegate <NSObject>
@optional
- (void)btnDeleteCategoryPressed:(id)sender forCell:(UICollectionViewCell *)cell;
@end

@interface FavourCategoryCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *categoryTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;
@property (weak, nonatomic) IBOutlet UIView *cellContentView;

@property (weak, nonatomic) IBOutlet UIButton *btnDeleteCategory;
- (IBAction)btnDeleteCategoryPressed:(id)sender;

@property (weak, nonatomic) id<FavourCategoryListCellDelegate> delegate;

+ (NSString *)reuseId;


@end
