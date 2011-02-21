//
//  ListsViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "ListsViewController.h"
#import "AlertPrompt.h"
#import "List.h"
#import "ListArticle.h"
#import "IndividualListViewController.h"

@implementation ListsViewController

@synthesize managedObjectContext=managedObjectContext_;

#pragma mark -
#pragma mark Core data table view overrides

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
	IndividualListViewController *individualListViewController = [[IndividualListViewController alloc] initWithNibName:@"IndividualListViewController" bundle:nil list:(List*)managedObject];
	[self.navigationController pushViewController:individualListViewController animated:YES];
	[individualListViewController release];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
	//Remove all articles
	NSSet *articles = ((List*)managedObject).articles;
	for (ListArticle *listArticle in articles) {
		[managedObjectContext_ deleteObject:listArticle];
	}
	//Remove the list
	[managedObjectContext_ deleteObject:managedObject];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add an add-button to the right on the navigationbar
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createList)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	// Add an edit-button to the left on the navigationbar
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext_];
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
	
	self.title = @"Listor";
}

#pragma mark -
#pragma mark Events

// Called when the add button is pressed
- (void)createList {
	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Döp din lista" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Lägg till"];
	[alertPrompt show];
}

#pragma mark -
#pragma mark Alert prompt delegate

#define alertViewButtonOK 1

- (void)alertView:(AlertPrompt *)alertPrompt clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertViewButtonOK) {
		List *list = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:self.managedObjectContext];
		list.name = alertPrompt.textField.text;
		list.creationDate = [NSDate date];
	}
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

