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

#pragma mark -
#pragma mark Core data table view controller overrides

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ListChanged" object:self];
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 57.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"IndividualListCell";
	
	ListArticle *article = (ListArticle*) [self tableView:tableView managedObjectForIndexPath:indexPath];

	IndividualListTableViewCell *cell = (IndividualListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
		cell = [[[IndividualListTableViewCell alloc] init] autorelease];
		cell.autoresizesSubviews = NO;
		cell.clipsToBounds = YES;
	}
	cell.listArticle = article;
	
	return cell;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    IndividualListTableViewCell *cell = ((IndividualListTableViewCell*)[self.tableView cellForRowAtIndexPath:path]);

    ListArticle *listArticle = (ListArticle*)managedObject;
    listArticle.checked = [NSNumber numberWithBool:![listArticle.checked boolValue]];
    
    [cell updateView];
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
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad {
}

- (void)dealloc {
	[list_ release];
    [super dealloc];
}


@end
