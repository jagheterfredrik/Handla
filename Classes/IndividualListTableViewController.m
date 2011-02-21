    //
//  IndividualListViewController.m
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

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
	Article *article = ((ListArticle*)managedObject).article;
	[list_.managedObjectContext deleteObject:managedObject];
	[list_.managedObjectContext deleteObject:article];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
	return UITableViewCellAccessoryDetailDisclosureButton;
}

#pragma mark -
#pragma mark Events

// Called when the add button is pressed
- (void)addArticle {
/*	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Lägg till vara" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Lägg till"];
	[alertPrompt show];*/
	AddArticleListViewController *addArticleListViewController = [[AddArticleListViewController alloc] initInManagedObjectContext:list_.managedObjectContext];
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


- (void)dealloc {
	[list_ release];
    [super dealloc];
}


@end
