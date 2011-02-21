//
//  TestViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "IndividualListViewController.h"
#import "Article.h"
#import "ListArticle.h"
#import "BudgetViewController.h"
#import "AddArticleListViewController.h"

@implementation IndividualListViewController

- (void)addListArticle {
	AddArticleListViewController *addArticleListViewController = [[AddArticleListViewController alloc] initInManagedObjectContext:list_.managedObjectContext];
	[self.navigationController pushViewController:addArticleListViewController animated:YES];
	[addArticleListViewController release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil list:(List*)list {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization	
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addListArticle)];
		self.navigationItem.rightBarButtonItem = addButton;
		[addButton release];
		
		list_ = list;
		
		self.title = list_.name;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[individualListTableViewController setList:list_];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Memory management

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
	[individualListTableViewController release];
    [super dealloc];
}


@end
