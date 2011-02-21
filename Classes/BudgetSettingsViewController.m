//
//  BudgetSettingsViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "BudgetSettingsViewController.h"


@implementation BudgetSettingsViewController

#pragma mark -
#pragma mark Lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClick)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
}


#pragma mark -
#pragma mark Events

- (void)doneClick {
	//TODO: Apply settings? Implement delegate?
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
