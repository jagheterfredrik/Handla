//
//  AddArticleListViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "AddArticleListViewController.h"
#import "ArticleDetailViewController.h"
#import "PhotoUtil.h"

#import "HandlaAppDelegate.h"

@implementation AddArticleListViewController

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


- (id)initWithList:(List*)list {
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		list_ = list;
		list.lastUsed = [NSDate	date];
	}
	return self;
}


#pragma mark -
#pragma mark Events

- (void)addArticle {
	ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:nil managedObjectContext:context_];
	[self.navigationController pushViewController:articleDetailViewController animated:YES];
	[articleDetailViewController release];
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
    
    context_ = [(HandlaAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	request.entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:context_];
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
																					 ascending:YES
																					  selector:@selector(caseInsensitiveCompare:)]];
	request.predicate = nil;
	request.fetchBatchSize = 20;
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
									   initWithFetchRequest:request
									   managedObjectContext:context_
									   sectionNameKeyPath:@"name"
									   cacheName:nil];
	frc.delegate = self;
	
	[request release];
	
	[self setFetchedResultsController:frc];
	[frc release];
	
	self.titleKey = @"name";
	self.searchKey = @"name";
	
	// Set window title.
    if (list_) {
        self.title = @"Lägg till vara";
    } else {
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        self.title = @"Artiklar";
    }
    
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
#pragma mark Events

- (void)performRemoval {
	for (id object in selectedArticle.listArticles)
		[context_ deleteObject:object];
	[context_ deleteObject:selectedArticle];
	[[PhotoUtil instance] deletePhoto:selectedArticle.picture];
	selectedArticle = nil;
}

#pragma mark -
#pragma mark Core data table view controller overrides
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}
- (void)managedObjectAccessoryTapped:(NSManagedObject *)managedObject {
	selectedArticle = (Article *) managedObject;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:selectedArticle.name
															 delegate:self
													cancelButtonTitle:@"Avbryt"
											   destructiveButtonTitle:@"Ta bort"
													otherButtonTitles:@"Redigera",nil];
	[actionSheet showInView:[[self view] window]];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self deleteManagedObject:selectedArticle];
	}
	else if (buttonIndex == 1)
	{
		ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:nil article:(Article*)selectedArticle];
		[self.navigationController pushViewController:articleDetailViewController animated:YES];
		[articleDetailViewController release];
	}
	
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    if (!list_) {
        return;
    }
	ListArticle *listArticle = [NSEntityDescription insertNewObjectForEntityForName:@"ListArticle" inManagedObjectContext:list_.managedObjectContext];
	listArticle.list = list_;
	listArticle.article = (Article*)managedObject;
	NSDate *latest = nil;
	NSArray *myArray = [listArticle.article.listArticles allObjects];
	for (ListArticle *object in myArray) {
		if(!latest) {
			latest = object.timeStamp;
		}
		if ([object.timeStamp compare:latest] == NSOrderedDescending || object.timeStamp == latest)
		{
			latest = object.timeStamp;
			if(object.price != nil)
			{
				listArticle.price = object.price;
			}
			else 
			{
				listArticle.price = nil;
			}
		}
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
	return UITableViewCellAccessoryDetailDisclosureButton;
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
	selectedArticle = (Article*)managedObject;
	NSUInteger listArticleCount = [selectedArticle.listArticles count];
	if (listArticleCount > 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bekräfta borttagning" 
												message:[NSString stringWithFormat:@"Varan du vill ta bort finns redan i %i listor, tar du bort denna vara kommer den tas bort från de listorna.", listArticleCount]
												delegate:self
												cancelButtonTitle:@"Avbryt"
												  otherButtonTitles:@"Ta bort", nil];
		[alertView show];
		[alertView release];
		return;
	}
	[self performRemoval];
}

#pragma mark -
#pragma mark Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self performRemoval];
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

