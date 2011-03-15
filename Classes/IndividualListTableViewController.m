//
//  IndividualListTableViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "IndividualListTableViewController.h"
#import "AlertPrompt.h"
#import "List.h"
#import "ListArticle.h"
#import "Article.h"
#import "AddArticleListViewController.h"

@implementation IndividualListTableViewController

@synthesize list_;
@synthesize cellReceiver;

- (void)setList:(List*)list {
	self.list_ = list;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"ListArticle" inManagedObjectContext:list_.managedObjectContext];
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"article.name"
																					 ascending:YES
																					  selector:@selector(caseInsensitiveCompare:)]];
	request.predicate = [NSPredicate predicateWithFormat:@"list = %@", list_];
	request.fetchBatchSize = 20;
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
									   initWithFetchRequest:request
									   managedObjectContext:list_.managedObjectContext
									   sectionNameKeyPath:nil
									   cacheName:nil];
	frc.delegate = self;
	
	[request release];
	
	[self setFetchedResultsController:frc];
	[frc release];
	
	self.titleKey = @"article.name";
	self.searchKey = @"article.name";
}

- (void)imageTouched:(id)source {
	/*
	UIButton *button = (UIButton*)source;
	UITableViewCell *cell = (UITableViewCell*)[[button superview] superview];
	NSIndexPath *path = [self.tableView indexPathForCell:cell];
	*/
}

#pragma mark -
#pragma mark Core data table view controller overrides

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == selectedIndex)
		return 101.0f;
	return 57.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"IndividualListCell";
	
	ListArticle *article = (ListArticle*) [self tableView:tableView managedObjectForIndexPath:indexPath];

	IndividualListTableViewCell *cell = (IndividualListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
		cell = [[IndividualListTableViewCell alloc] init];
		cell.autoresizesSubviews = NO;
		cell.clipsToBounds = YES;
		self.cellReceiver = nil;
	}
	cell.listArticle = article;
	
	return cell;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
	selectedManagedObject = managedObject;
	NSIndexPath *path = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:path animated:NO];
	((IndividualListTableViewCell*)[self.tableView cellForRowAtIndexPath:path]).listArticle = (ListArticle*)managedObject;
	
	NSInteger oldSelection = selectedIndex;
	if (selectedIndex == path.row)
		selectedIndex = -1;
	else {
		((IndividualListTableViewCell*)[self.tableView cellForRowAtIndexPath:path]).checked = YES;
		selectedIndex = path.row;
	}
	[self.tableView beginUpdates];
	NSMutableArray *rows = [NSMutableArray arrayWithCapacity:2];
	if (selectedIndex >= 0) [rows addObject:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
	if (oldSelection  >= 0) [rows addObject:[NSIndexPath indexPathForRow:oldSelection  inSection:0]];
	if (oldSelection == [self.tableView numberOfRowsInSection:path.section]-1 || selectedIndex == [self.tableView numberOfRowsInSection:path.section]-1) {
		[self.tableView reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
	} else {
		[self.tableView reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationNone];
	}
	[self.tableView endUpdates];
}



- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
}



- (void)deleteManagedObject:(NSManagedObject *)managedObject {
	ListArticle *article = (ListArticle*)managedObject;
	[list_.managedObjectContext deleteObject:managedObject];
	[list_.managedObjectContext deleteObject:article];
}

/*- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
	return UITableViewCellAccessoryDetailDisclosureButton;
}*/




#pragma mark -
#pragma mark Events

// Called when the add button is pressed
- (void)addArticle {
/*	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Lägg till vara" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Lägg till"];
	[alertPrompt show];*/
	AddArticleListViewController *addArticleListViewController = [[AddArticleListViewController alloc] initWithList:list_];
	[addArticleListViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self.navigationController pushViewController:addArticleListViewController animated:YES];
	[addArticleListViewController release];
}


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

- (void)viewDidLoad {
	selectedIndex = -1;
}

- (void)dealloc {
	[list_ release];
    [super dealloc];
}


@end
