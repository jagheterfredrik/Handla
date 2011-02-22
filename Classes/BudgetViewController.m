//
//  BudgetViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "BudgetViewController.h"
#import "AddBudgetPostViewController.h"
#import "BudgetSettingsViewController.h"

@implementation BudgetViewController

@synthesize managedObjectContext=managedObjectContext_;


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Inställningar" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    self.navigationItem.leftBarButtonItem = settingsButton;
	[settingsButton release];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPost)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	[budgetTableViewController setManagedObjectContext:managedObjectContext_];
	
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Event handling

- (void)addPost {
	addBudgetPostViewController = [[AddBudgetPostViewController alloc] initInManagedObjectContext:self.managedObjectContext];
	[self.navigationController pushViewController:addBudgetPostViewController animated:YES];
	[addBudgetPostViewController release];
}

- (void)showSettings {
	if (budgetSettingsViewController == nil) {
		budgetSettingsViewController = [[BudgetSettingsViewController alloc] initWithNibName:@"BudgetSettingsViewController" bundle:nil];
		[budgetSettingsViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	}
	[self.navigationController pushViewController:budgetSettingsViewController animated:YES];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[budgetSettingsViewController release];
    [super dealloc];
}


@end

