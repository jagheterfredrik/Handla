//
//  ArrowTabBarController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-03-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TABBAR_ARROWSIZE 8

@interface ArrowTabBarController : UITabBarController<UITabBarControllerDelegate> {
	UIView *arrowView;
	CGFloat tabWidthConstant;
}

@end
