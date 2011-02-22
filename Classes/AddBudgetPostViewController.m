//
//  AddBudgetPostViewController.m
//  Handla
//  
//  Handles the view responsible for adding new posts in the budget. 
//  It prompts the user for the relevant data, and stores it in the database.
//
//	Viktor Holmberg and Fredrik Gustafsson
//  
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "AddBudgetPostViewController.h"


@implementation AddBudgetPostViewController

@synthesize managedObjectContext=managedObjectContext_;


#pragma mark -
#pragma mark Initialization

/**
 * Should not be called, use initInManagedObjectContext instead.
 */
- (id)init
{
	[self dealloc];
	@throw [NSException exceptionWithName:@"WrongInitializerException" reason:@"use initInManagedObjectContext instead" userInfo:nil];
	return nil;
}

/**
 * Initializes with the mangedObjectContext needed to acces the database.
 * This init method is used when the view is to be used to make a new BudgetPost.
 */
- (id)initInManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	{
		managedObjectContext_ = managedObjectContext;
		budgetPost_ = nil;
	}
	return self;
}

/**
 * Initializes the view with an already existing BudgetPost.
 */
- (id)initWithBudgetPost:(BudgetPost*)budgetPost {
	{
		managedObjectContext_ = budgetPost.managedObjectContext;
		budgetPost_ = budgetPost;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (budgetPost_ == nil) {
		self.title = @"Ny budgetpost";
		doneButton.title = @"Skapa";
	} else {
		self.title = budgetPost_.name;
		nameBox.text = budgetPost_.name;
		if ([budgetPost_.amount compare:[NSNumber numberWithInt:0]] == NSOrderedAscending) {
			valueBox.text = [[budgetPost_.amount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]] description];
			incomeOrExpense.selectedSegmentIndex = 1;
		} else {
			valueBox.text = [budgetPost_.amount description];
			incomeOrExpense.selectedSegmentIndex = 0;
		}
		doneButton.title = @"Ändra";
		
	}
	
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	valueBox.keyboardType = UIKeyboardTypeDecimalPad;
	[nameBox becomeFirstResponder];
}

#pragma mark -
#pragma mark View lifecycle

/**
 * Changes to next keyboard when the next button is clicked.
 * If the name input is first responder then the comment
 * box becomes first responder. If the comment box is the
 * first responder, the value box becomes first responder.
 */
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if ([theTextField isEqual:nameBox]) {
		[commentBox becomeFirstResponder];
	} else if ([theTextField isEqual:commentBox]) {
		[valueBox becomeFirstResponder];
	}
    return YES;
}

/**
 * When cancel button is clicked, the view should be dismissed.
 */
- (IBAction)cancelClick:(id) sender {
	[self dismissModalViewControllerAnimated:YES];
}

/**
 * When done button is clicked, the values in the view shoud be stored in the database.
 */
- (IBAction)doneClick:(id) sender{
	if (([valueBox.text length]==0)&&([nameBox.text length]==0)){
		[self showMessageWithString:@"Du måste ange ett namn och en summa för budgetposten!"];
		return;
	}
	if ([nameBox.text length]==0){
		[self showMessageWithString:@"Du måste ange ett namn på budgetposten!"];
		return;
	}
	if ([valueBox.text length]==0){
		[self showMessageWithString:@"Du måste ange en summa för budgetposten!"];
		return;
	}
	BudgetPost* newBudgetPost;
	if (budgetPost_ == nil) {
		newBudgetPost = [NSEntityDescription insertNewObjectForEntityForName:@"BudgetPost" inManagedObjectContext:self.managedObjectContext];
	} else {
		newBudgetPost = budgetPost_;
	}


	
	newBudgetPost.name = nameBox.text;
	
	//TODO: Check for valid number! i.e only 2 decimals
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setGeneratesDecimalNumbers:YES];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDecimalNumber * value = (NSDecimalNumber*)[f numberFromString:valueBox.text];
	[f release];
	if ([incomeOrExpense selectedSegmentIndex] == 1) {
		value = [value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
	}
	newBudgetPost.amount = value;
	newBudgetPost.comment = commentBox.text;
	
	if (budgetPost_ == nil) {
		newBudgetPost.timeStamp = [NSDate date];
	}

	[self.managedObjectContext save:NULL];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)setDateButtonClicked:(UIButton*) sender {
	//TODO: Fix.
}

/**
 * Visar ett meddelande "actionsheet" med en ok-knapp.
 */
-(void) showMessageWithString:(NSString *) message {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:message
															 delegate:nil
													cancelButtonTitle:@"OK"
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];
	[actionSheet showInView:[[self view] window]];
	[actionSheet autorelease];
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
	[valueBox release];
	[commentBox release];
	[nameBox release];
	[incomeOrExpense release];
    [super dealloc];
}


@end

