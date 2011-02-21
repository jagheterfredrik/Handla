//
//  AddArticleListViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "AddArticleListViewController.h"


@implementation AddArticleListViewController

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

- (id)initInManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		managedObjectContext_ = managedObjectContext;
	}
	return self;
}


#pragma mark -
#pragma mark Events

- (void)addArticle {
	
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addArticle)];
    self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	
	//Setup the data source.
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:managedObjectContext_];
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
																					 ascending:YES
																					  selector:@selector(caseInsensitiveCompare:)]];
	request.predicate = nil;
	request.fetchBatchSize = 20;
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
									   initWithFetchRequest:request
									   managedObjectContext:managedObjectContext_
									   sectionNameKeyPath:nil
									   cacheName:nil];
	frc.delegate = self;
	
	[request release];
	
	[self setFetchedResultsController:frc];
	[frc release];
	
	self.titleKey = @"name";
	self.searchKey = @"name";
	
	// Set window title.
	self.title = @"Lägg till vara";
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
#pragma mark Core data table view controller overrides

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
	return UITableViewCellAccessoryDetailDisclosureButton;
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
    [super dealloc];
}


@end

