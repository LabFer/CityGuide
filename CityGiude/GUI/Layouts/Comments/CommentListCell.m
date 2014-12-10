//
//  CommentListCell.m
//  CityGuide
//
//  Created by Dmitry Kuznetsov on 08/12/14.
//  Copyright (c) 2014 Appsgroup. All rights reserved.
//

#import "CommentListCell.h"
#import "Constants.h"

@implementation CommentListCell


+ (NSString *)reuseId
{
    return kReuseCommentListCellID;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.commentTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.commentTextLabel.frame);
    self.userNameLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.userNameLabel.frame);
}

@end
