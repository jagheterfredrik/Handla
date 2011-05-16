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

#import "UIActionSheet+Blocks.h"

@implementation ListsViewController

@synthesize managedObjectContext=managedObjectContext_, list=list_, myPopTipView;

#pragma mark - Pop tip view helper functions

/*
 * Shows the tip-view for creating a new list
 */
- (void)showPopTipView {
    NSString *message = @"Klicka här för att skapa en ny matlista";
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    popTipView.backgroundColor = [UIColor blackColor];
    popTipView.delegate = self;
    [popTipView presentPointingAtBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
    self.myPopTipView = popTipView;
    [popTipView release];
}

/*
 * Hides the displaying tip-view.
 */
- (void)dismissPopTipView {
    [self.myPopTipView dismissAnimated:NO];
    self.myPopTipView = nil;
}

#pragma mark -
#pragma mark Core data table view overrides

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
	static NSString *cellIdentifier = @"BudgetPostCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	List* list = (List*)managedObject;
	cell.textLabel.text = list.name;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%i varor", [(NSSet*)list.articles count]];
	return cell;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller 	
{
    [UIView animateWithDuration:0.4f animations:^{
        self.tableView.contentOffset = CGPointMake(0.0, self.searchDisplayController.searchBar.frame.size.height);
    }];
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
	List* selList = (List  *) managedObject;
    
    RIButtonItem *delete = [RIButtonItem itemWithLabel:@"Ta bort"];
    delete.action = ^
    {
        [self deleteManagedObject:selList];
    };
    
    RIButtonItem *rename = [RIButtonItem itemWithLabel:@"Ändra namn"];
    rename.action = ^
    {
        AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Döp om din lista" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"OK"];
        alertPrompt.textField.text = selList.name;
        list_ = selList;
        alertPrompt.tag = RENAME_LIST;
        [alertPrompt show];
        [alertPrompt release];
    };
    
    RIButtonItem *duplicate = [RIButtonItem itemWithLabel:@"Skapa kopia"];
    duplicate.action = ^
    {
        List *cloned = [NSEntityDescription
                                   insertNewObjectForEntityForName:@"List"
                                   inManagedObjectContext:managedObjectContext_];
        
        cloned.name = [NSString stringWithFormat:@"Kopia av %@", selList.name];
        cloned.creationDate = [NSDate date];
        
        for (ListArticle *listArticle in selList.articles) {
            ListArticle *clonedArticle = [NSEntityDescription
                            insertNewObjectForEntityForName:@"ListArticle"
                            inManagedObjectContext:managedObjectContext_];
            clonedArticle.list = cloned;
            clonedArticle.article = listArticle.article;
            clonedArticle.amount = listArticle.amount;
            clonedArticle.price = listArticle.price;
            clonedArticle.timeStamp = listArticle.timeStamp;
            clonedArticle.weightUnit = listArticle.weightUnit;
            clonedArticle.checked = listArticle.checked;
        }
    };
    
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:selList.name
                                            cancelButtonItem:[RIButtonItem itemWithLabel:@"Avbryt"]
                                            destructiveButtonItem:delete
                                            otherButtonItems:duplicate, rename, nil];
	[actionSheet showInView:[[self view] window]];
	[actionSheet release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger numRows = [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    if (self.searchDisplayController.searchBar.showsCancelButton) {
        tableView.scrollEnabled = YES;
    } else if (numRows == 0) {
        self.searchDisplayController.searchBar.hidden = YES;
        [self showPopTipView];
	} else {
        [self dismissPopTipView];
        self.searchDisplayController.searchBar.hidden = NO;
	}
	return numRows;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.navigationItem.rightBarButtonItem.enabled = !editing;
    [super setEditing:editing animated:animated];
}


#pragma mark CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // User can tap CMPopTipView to dismiss it
    self.myPopTipView = nil;
    [self createList];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Add an add-button to the right on the navigationbar
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createList)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
    //Add an edit-button to the left on the navigationbar
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(turnOnEditing)];

		
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext_];
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastUsed"
																					 ascending:YES]];
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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	listSortOrder = [defaults integerForKey:@"listSortOrder"];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext_];
	if (listSortOrder == 0) {
		request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
																						 ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
	}
	else if (listSortOrder == 1) {
		request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastUsed"
																						 ascending:NO]];
	}
	else if (listSortOrder == 2) {
		request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate"
																						 ascending:NO]];
	}
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

- (void)viewDidAppear:(BOOL)animated {
    if([self.fetchedResultsController.fetchedObjects count]==0) {
        self.searchDisplayController.searchBar.hidden = YES;
        [self showPopTipView];
    }
    [UIView animateWithDuration:0.4f animations:^{
        self.tableView.contentOffset = CGPointMake(0.0, self.searchDisplayController.searchBar.frame.size.height);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self dismissPopTipView];
}

#pragma mark -
#pragma mark Events

/*
 * Called when the add button is pressed, asks for a new name for the new list.
 */
- (void)createList {
	self.list = nil;
	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Döp din nya lista" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"OK"];
    alertPrompt.tag = CREATE_LIST;
    alertPrompt.maxLength = 30;
    [self dismissPopTipView];
	[alertPrompt show];
	[alertPrompt release];
}

/*
 * Helper function for turning on editing of the table and disabling the add-button.
 */
- (void)turnOnEditing {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(turnOffEditing)];
	self.navigationItem.rightBarButtonItem = nil;
	[self.tableView setEditing:YES animated:YES];
	[self.navigationItem.leftBarButtonItem release];
    
    [self dismissPopTipView];
}

/*
 * Helper function for turning off editing of the table and enabling the add-button.
 */
- (void)turnOffEditing {
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(turnOnEditing)];
	[self.tableView setEditing:NO animated:YES];
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createList)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	[self.navigationItem.leftBarButtonItem release];
    
    if([self.fetchedResultsController.fetchedObjects count]==0) {
        self.searchDisplayController.searchBar.hidden = YES;
        [self showPopTipView];
    }
}
#pragma mark -
#pragma mark Alert prompt delegate



- (void)alertView:(AlertPrompt *)alertPrompt clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertPromptButtonOK) {
        if ([alertPrompt.enteredText length] == 0) {
            return;
        }
		switch (alertPrompt.tag) {
            case CREATE_LIST:
            {
                List *list = [NSEntityDescription insertNewObjectForEntityForName:@"List" inManagedObjectContext:self.managedObjectContext];
                list.name = alertPrompt.textField.text;
                list.creationDate = [NSDate date];
                self.editing = NO;
                IndividualListViewController *individualListViewController = [[IndividualListViewController alloc] initWithNibName:@"IndividualListViewController" bundle:nil list:list];
                [self.navigationController pushViewController:individualListViewController animated:YES];
                [individualListViewController release];
                
            }
                break;
            case RENAME_LIST:
                list_.name = alertPrompt.textField.text;
                break;
            default:
                break;
        }
	} else {
        if([self.fetchedResultsController.fetchedObjects count]==0) {
            self.searchDisplayController.searchBar.hidden = YES;
            [self showPopTipView];
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

