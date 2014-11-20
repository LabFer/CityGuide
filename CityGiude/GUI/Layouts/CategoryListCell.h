//
//  CategoryCell.h
//  CityGiude
//
//  Created by Dmitry Kuznetsov on 10/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCircle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCategoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelCategoryName;
@property (weak, nonatomic) IBOutlet UIButton *btnCellHeart;
- (IBAction)btnCellHeartPressed:(id)sender;

+ (NSString *)reuseId;

@end
