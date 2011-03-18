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
#import <QuartzCore/QuartzCore.h>

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

/**
 * returns the sum of the costs in the list
 */
- (NSDecimalNumber*)calculateSumOfElementsInList {
	NSDecimalNumber *amountBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
	for (ListArticle *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
		amountBalance = [amountBalance decimalNumberByAdding:object.price];
	}
	
	return amountBalance;
}

/**
 * returns the sum of the checked articles' costs in the list
 */
- (NSDecimalNumber*)calculateSumOfCheckedElementsInList {
	NSDecimalNumber *amountBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
	for (ListArticle *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
		if ([[object checked] boolValue]) {
			NSLog(@"%@'s price is %@", object.article.name, [object.price description]);
			amountBalance = [amountBalance decimalNumberByAdding:object.price];
		}
		
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

//=========================================================== 
// - elementsCount property
//=========================================================== 
- (NSInteger)elementsCount
{
    return [[individualListTableViewController.fetchedResultsController fetchedObjects] count];
}
//=========================================================== 
// - checkedElementsCount property returns the number of checked articles in the list
//=========================================================== 
- (NSInteger)checkedElementsCount
{
    NSInteger count = 0;
	for (ListArticle *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
		if ([[object checked] boolValue]) {
			count++;
		}
		
	}	
	return count;    
}


/**
 * when the user clicks the "avsluta köp" button, we see if all posts are checked off
 * and if they are we go to CheckoutViewController. else we show some alerts
 */
- (IBAction)purchase {
    if (self.elementsCount == self.checkedElementsCount) {
        //we are all done with the list
        CheckoutViewController* checkOut = [[CheckoutViewController alloc] initWithList:list_ 
                                                                            amountToPay:[self calculateSumOfCheckedElementsInList]];
        [self.navigationController presentModalViewController:checkOut animated:YES];
        
        [checkOut release];
    }
    else {        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Du har inte checkat av alla varor!" 
                                                        message:@"Vill du ändå avsluta köpet?" 
                                                       delegate:self 
                                              cancelButtonTitle:@"Tillbaka"
											  otherButtonTitles:@"Ja", nil];
		[alert show];
		[alert release];
        
    }

}

//=========================================================== 
// - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//
//=========================================================== 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
		if (buttonIndex==1) {
			//clicked "ja"
            CheckoutViewController* checkOut = [[CheckoutViewController alloc] initWithList:list_ 
                                                                                amountToPay:[self calculateSumOfCheckedElementsInList]];
            [self.navigationController presentModalViewController:checkOut animated:YES];
            
            [checkOut release];
	}
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


- (void)updatePriceFields {
   	progressLabel.text = [NSString stringWithFormat:@"%i / %i", self.checkedElementsCount,self.elementsCount];
    if ((float)(self.checkedElementsCount/(float)(self.elementsCount)==1)) {
        [UIView animateWithDuration:0.4f animations:^{
            [checkoutButton setBackgroundColor:[UIColor greenColor]];
        }];
    }
    else{
        [UIView animateWithDuration:0.4f animations:^{
            [checkoutButton setBackgroundColor:[UIColor lightGrayColor]];
        }];
    }
}

/*
 * method to update the progressbar for animation
 */
-(void)updateProgressbar{
    float animationPercentagePerUpdate = 0.01f;
    float destinaion = (float)(self.checkedElementsCount/(float)(self.elementsCount));
    if (destinaion-progressBar.progress>animationPercentagePerUpdate){
        progressBar.progress += animationPercentagePerUpdate;
    } else if (destinaion-progressBar.progress<-animationPercentagePerUpdate){
        progressBar.progress -= animationPercentagePerUpdate;
    } else {
        progressBar.progress = (float)(self.checkedElementsCount)/(float)(self.elementsCount);
    }
  
}
/* Other version of this method
- (void)updatePriceFields {
    NSNumber *sumChecked = [self calculateSumOfCheckedElementsInList];
	NSNumber *sumTotal = [self calculateSumOfElementsInList];
    
	progressLabel.text = [NSString stringWithFormat:@"%@ / %@", [sumChecked stringValue], [sumTotal stringValue]];
	progressBar.progress = [sumChecked doubleValue] / [sumTotal doubleValue];
}
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[individualListTableViewController setList:list_];
    
    //TODO: This is code to make the done button fancy, shold be replaced by a cool image
    [[checkoutButton layer] setCornerRadius:8.0f];
    [[checkoutButton layer] setMasksToBounds:YES];
    [[checkoutButton layer] setBorderWidth:1.0f];
    //end buttoncooling part
    
    progressBar.progress = (float)(self.checkedElementsCount)/(float)(self.elementsCount);
	[self updatePriceFields];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePriceFields) name:@"ListArticleChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:tableView selector:@selector(reloadData) name:@"ArticleChanged" object:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateProgressbar) userInfo:nil repeats:YES];
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
