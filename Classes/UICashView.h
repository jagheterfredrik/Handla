//
//  UICashView.h
//  Handla
// A small view for use by CheckoutVC
//
//  Created by viktor holmberg on 2011-03-07.
//  Copyright 2011 KTH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UICashView : UIButton {
	CGRect startingPlace_;
	NSInteger value_;

}

- (void)setFrameAndRememberIt:(CGRect)frame withCashValue:(NSInteger) value;
@property (assign) NSInteger value;
@property (assign) CGRect startingPlace;

@end
