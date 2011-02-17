    //
//  IndividualListViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "IndividualListViewController.h"
#import "AlertPrompt.h"
#import "List.h"
#import "ListArticle.h"
#import "Article.h"
#import "AddArticleListViewController.h"

@implementation IndividualListViewController

- (id)initWithList:(List*)list {
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		list_ = list;
		
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addArticle)];
		self.navigationItem.rightBarButtonItem = addButton;
		[addButton release];
		
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
	return self;
}

#pragma mark -
#pragma mark Core data table view overrides

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
	Article *article = ((ListArticle*)managedObject).article;
	[list_.managedObjectContext deleteObject:managedObject];
	[list_.managedObjectContext deleteObject:article];
}

#pragma mark -
#pragma mark Events

// Called when the add button is pressed
- (void)addArticle {
/*	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Lägg till vara" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Lägg till"];
	[alertPrompt show];*/
	AddArticleListViewController *addArticleListViewController = [[AddArticleListViewController alloc] initInManagedObjectContext:list_.managedObjectContext];
	[addArticleListViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self.navigationController presentModalViewController:addArticleListViewController animated:YES];
	[addArticleListViewController release];
}

#pragma mark -
#pragma mark Alert prompt delegate

#define alertViewButtonOK 1

- (void)alertView:(AlertPrompt *)alertPrompt clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertViewButtonOK) {
		Article *article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:list_.managedObjectContext];
		article.name = alertPrompt.textField.text;
		ListArticle *listArticle = [NSEntityDescription insertNewObjectForEntityForName:@"ListArticle" inManagedObjectContext:list_.managedObjectContext];
		listArticle.article = article;
		listArticle.list = list_;
	}
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
    [super dealloc];
}


@end
