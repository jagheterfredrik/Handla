//
//  ArrowTabBarController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-03-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "ArrowTabBarController.h"


@implementation ArrowTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
	//Catch item selections
	super.delegate = self;

	//The center point of the first button
	tabWidthConstant = (320.f/[self.tabBar.items count])/2;
	
	//Make and add arrow
	arrowView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, TABBAR_ARROWSIZE, TABBAR_ARROWSIZE)];
	arrowView.center = CGPointMake(tabWidthConstant, 431.f);
	arrowView.backgroundColor = [UIColor blackColor];
	CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI/4);
	arrowView.transform = rotation;
	[self.view insertSubview:arrowView atIndex:1];
}

/**
 *	Called when the user changes tab.
 */
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{	
	[UIView beginAnimations:nil context:nil];
	//Calculate new centerpoint
	arrowView.center = CGPointMake(tabWidthConstant*((self.selectedIndex+1)*2-1), 431.f);
	[UIView commitAnimations];
	
}

@end
