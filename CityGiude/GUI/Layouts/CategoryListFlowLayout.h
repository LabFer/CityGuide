//
//  CatalogiPhoneFlowLayout.h
//  AppsPublisher
//
//  Created by Dmitry Kuznetsov on 17/06/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryListFlowLayout : UICollectionViewFlowLayout


@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) UIEdgeInsets itemInsets;
@property (nonatomic) CGFloat interItemSpacingY;
@property (nonatomic) CGFloat headerViewHeight;

@end
