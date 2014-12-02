//
//  VALabel.m
//
//  Created by Tom Parry on 23/07/13.
//  Copyright (c) 2013 b2cloud. All rights reserved.
//

#import "VALabel.h"

@implementation VALabel

@synthesize verticalAlignment;

#pragma mark -
#pragma mark Super

- (void) drawTextInRect:(CGRect)rect
{
	if(verticalAlignment == UIControlContentVerticalAlignmentTop ||
	   verticalAlignment == UIControlContentVerticalAlignmentBottom)
	{
		//	If one line, we can just use the lineHeight, faster than querying sizeThatFits
		const CGFloat height = ((self.numberOfLines == 1) ? ceilf(self.font.lineHeight) : [self sizeThatFits:self.frame.size].height);
		
		rect.origin.y = ((self.frame.size.height - height) / 2.0f) * ((verticalAlignment == UIControlContentVerticalAlignmentTop) ? -1.0f : 1.0f);
	}
	
	[super drawTextInRect:rect];
}

#pragma mark -
#pragma mark Self

- (void) setVerticalAlignment:(UIControlContentVerticalAlignment)_verticalAlignment
{
	verticalAlignment = _verticalAlignment;
	
	[self setNeedsDisplay];
}

@end
