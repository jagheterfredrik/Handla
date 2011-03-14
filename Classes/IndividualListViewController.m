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
#import "ArticleDetailViewController.h"
#import "CheckoutViewController.h"
#import "IndividualListTableViewController.h"

@implementation IndividualListViewController


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
		{
			ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:nil list:list_];
			[self.navigationController pushViewController:articleDetailViewController animated:YES];
			[articleDetailViewController release];
			break;
		}
		case 1:
		{
			
			AddArticleListViewController *addArticleListViewController = [[AddArticleListViewController alloc] initWithList:list_];
			[self.navigationController pushViewController:addArticleListViewController animated:YES];
			[addArticleListViewController release];
			break;
		}
		default:
			break;
	}
	
}

- (NSDecimalNumber*)calculateSumOfElementsInList {
	//TODO: Does not work
	NSDecimalNumber *amountBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
	for (NSManagedObject *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
		NSDecimalNumber *objectExpenseNumber = [object valueForKey:@"amount"];
		NSLog(objectExpenseNumber.stringValue);
		amountBalance = [amountBalance decimalNumberByAdding:objectExpenseNumber];
	}
	
	return amountBalance;
}


- (void)addListArticle {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:list_.name
															 delegate:self
													cancelButtonTitle:@"Avbryt"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Skapa ny vara",@"Lägg till tidigare vara",nil];
	[actionSheet showInView:[[self view] window]];
	[actionSheet release];
}

/**
 * when the user clicks the "avsluta köp" button, we go to CheckoutViewController.
 */
- (IBAction)purchase {
	CheckoutViewController* checkOut = [[CheckoutViewController alloc] initWithList:list_ 
																		amountToPay:[NSDecimalNumber decimalNumberWithString:@"612.50"]];
	[self.navigationController presentModalViewController:checkOut animated:YES];

	[checkOut release];
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
	progressLabel.text = [[self calculateSumOfElementsInList] stringValue];

	[[NSNotificationCenter defaultCenter] addObserver:tableView selector:@selector(reloadData) name:@"ArticleChanged" object:nil];
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
	[[NSNotificationCenter defaultCenter] removeObserver:tableView];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[individualListTableViewController release];
    [super dealloc];
}


@end
