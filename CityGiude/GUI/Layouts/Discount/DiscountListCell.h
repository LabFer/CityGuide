//
//  DiscountListCell.h
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 22/11/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscountListCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *discountImage;
@property (weak, nonatomic) IBOutlet UILabel *discountTitle;
@property (weak, nonatomic) IBOutlet UILabel *discountText;
@property (weak, nonatomic) IBOutlet UILabel *discountTime;


+ (NSString *)reuseId;

@end
