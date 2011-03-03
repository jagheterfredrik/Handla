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

@synthesize managedObjectContext=managedObjectContext_, list=list_;

#pragma mark -
#pragma mark Core data table view overrides

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
	static NSString *cellIdentifier = @"BudgetPostCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	List* list = (List*)managedObject;
	cell.textLabel.text = list.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%i varor", [(NSSet*)list.articles count]];
	return cell;
}

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

- (void)managedObjectAccessoryTapped:(NSManagedObject *)managedObject {
	self.list = (List*) managedObject;
	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Döp om din lista" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Ändra"];
	alertPrompt.textField.text = list_.name;
	[alertPrompt show];
	
	
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
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastUsed"
																					 ascending:NO]];
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
	
	self.searchKey = @"name";
	self.title = @"Listor";
}

#pragma mark -
#pragma mark Events

// Called when the add button is pressed
- (void)createList {
	self.list = nil;
	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Döp din lista" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Lägg till"];
	[alertPrompt show];
}

#pragma mark -
#pragma mark Alert prompt delegate

#define alertViewButtonOK 1

- (void)alertView:(AlertPrompt *)alertPrompt clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertViewButtonOK && [alertPrompt.textField.text length] == 0) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Du måste ange ett namn för listan"
																 delegate:nil
														cancelButtonTitle:@"OK"
												   destructiveButtonTitle:nil
														otherButtonTitles:nil];
		[actionSheet showInView:[[self view] window]];
		AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Döp din lista" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Lägg till"];
		[alertPrompt show];
	}
	if (buttonIndex == alertViewButtonOK && [alertPrompt.textField.text length] != 0) {
		if(list_ == nil) {
			List *list = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:self.managedObjectContext];
			list.name = alertPrompt.textField.text;
			list.creationDate = [NSDate date];
		} else {
			list_.name = alertPrompt.textField.text;
		}
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
	[list_ release];
	[managedObjectContext_ release];
    [super dealloc];
	
}


@end

