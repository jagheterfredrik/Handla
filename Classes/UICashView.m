//
//  UICashView.m
//  Handla
//
//  Created by viktor holmberg on 2011-03-07.
//  Copyright 2011 KTH. All rights reserved.
//

#import "UICashView.h"


@implementation UICashView
@synthesize value=value_,startingPlace=startingPlace_;

//=========================================================== 
// - setFrameAndRememberIt:(GCRect) frame
//
//=========================================================== 
- (void)setFrameAndRememberIt:(CGRect)frame withCashValue:(NSInteger) value;
{
	self.value=value;
	super.frame=frame;
	self.startingPlace=frame;
}

@end
