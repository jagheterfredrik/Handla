//
//  AddBudgetPostViewController.m
//  Handla
//  
//  Handles the view responsible for adding new posts in the budget. 
//  It prompts the user for the relevant data, and stores it in the database.
//
//
//  Created by Fredrik Gustafsson on 2011-02-17.
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
 */
- (id)initInManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	{
		managedObjectContext_ = managedObjectContext;
	}
	return self;
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
	BudgetPost* newBudgetPost = [NSEntityDescription insertNewObjectForEntityForName:@"BudgetPost" inManagedObjectContext:self.managedObjectContext];
	
	newBudgetPost.name = nameBox.text;
	
	//TODO: Check for valid number! i.e only 2 decimals
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setGeneratesDecimalNumbers:YES];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDecimalNumber * value = (NSDecimalNumber*)[f numberFromString:valueBox.text];
	[f release];
	if ([incomeOrExpense isEnabledForSegmentAtIndex:1]) {
		
		value = [value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
	}
	newBudgetPost.amount = value;

	
	newBudgetPost.comment = commentBox.text;
	
	NSDate* tempDate = [[NSDate alloc] init];
	newBudgetPost.timeStamp = tempDate;
	[tempDate release];
	[self.managedObjectContext save:NULL];	
	[self dismissModalViewControllerAnimated:YES];
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


- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Ny budgetpost";
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	valueBox.keyboardType = UIKeyboardTypeDecimalPad;
	[nameBox becomeFirstResponder];
}

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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
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

