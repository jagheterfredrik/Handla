//
//  BudgetPostDetailViewController.m
//  Handla
//  
//  Handles the view responsible for adding new posts in the budget. 
//  It prompts the user for the relevant data, and stores it in the database.
//
//	Viktor Holmberg and Fredrik Gustafsson
//  
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "BudgetPostDetailViewController.h"


@implementation BudgetPostDetailViewController

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
	if ((self = [super init])) {
		self.managedObjectContext = managedObjectContext;
		budgetPost_ = nil;
	}
	return self;
}

/**
 * Initializes the view with an already existing BudgetPost. Since the budgetPost 
 * contains the managedObjectContext, no need to provide this as well.
 */
- (id)initWithBudgetPost:(BudgetPost*)budgetPost {
	if ((self = [super init])) {
		self.managedObjectContext = budgetPost.managedObjectContext;
		budgetPost_ = budgetPost;
	}
	return self;
}

/**
 * Initializes the view.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(doneClick)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	
	NSNumberFormatter *amountFormatter = [[NSNumberFormatter alloc] init];
	[amountFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
	[amountFormatter setMinusSign:@""];
	[amountFormatter setMinimumFractionDigits:2];
	
	if (budgetPost_ == nil) {
		self.title = @"Ny budgetpost";
		self.navigationItem.rightBarButtonItem.title = @"Skapa";
		//initialize the date picker
		datePicker = [[UIDatePicker alloc] init];
		datePicker.datePickerMode = UIDatePickerModeDate;
		[datePicker setDate:[NSDate date]];
		[dateShower setTitle:[dateFormatter stringFromDate:[NSDate date]] forState:UIControlStateNormal];
		
	} else {
		self.title = budgetPost_.name;
		nameBox.text = budgetPost_.name;
		commentBox.text = budgetPost_.comment;
		if ([budgetPost_.amount compare:[NSNumber numberWithInt:0]] == NSOrderedAscending) {
			incomeOrExpense.selectedSegmentIndex = 1;
		} else {
			incomeOrExpense.selectedSegmentIndex = 0;
		}
		valueBox.text = [amountFormatter stringFromNumber:budgetPost_.amount];
		self.navigationItem.rightBarButtonItem.title = @"Ändra";
		datePicker = [[UIDatePicker alloc] init];
		datePicker.datePickerMode = UIDatePickerModeDate;
		[datePicker setDate:budgetPost_.timeStamp];
		[dateShower setTitle:[dateFormatter stringFromDate:budgetPost_.timeStamp] forState:UIControlStateNormal];
	}
	[amountFormatter release];
    
    nameBox.delegate = self;
}

#pragma mark -
#pragma mark Text field delegate methods

- (BOOL)textField:(UITextField *)textField_ shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField_.text length] + [string length] - range.length;
    return (newLength > 30) ? NO : YES;
}

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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	[dateShower setTitle:[dateFormatter stringFromDate:datePicker.date] forState:UIControlStateNormal];
}

/**
 * When done button is clicked, the values in the view should be stored in the database.
 */
- (IBAction)doneClick {
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
	NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
	[f setGeneratesDecimalNumbers:YES];
	[f setNumberStyle:NSNumberFormatterDecimalStyle];
	NSDecimalNumber * value = (NSDecimalNumber*)[f numberFromString:valueBox.text];
	if (value == nil){
		[self showMessageWithString:@"Du måste ange en korrekt kostnad!"];
		[f release];
		return;
	}
	[f release];
	
	
	BudgetPost* newBudgetPost;
	if (budgetPost_ == nil) {
		newBudgetPost = [NSEntityDescription insertNewObjectForEntityForName:@"BudgetPost" inManagedObjectContext:self.managedObjectContext];
	} else {
		newBudgetPost = budgetPost_;
	}

	newBudgetPost.name = nameBox.text;
    newBudgetPost.repeatID = [NSNumber numberWithInt:-1];
	
	if ([incomeOrExpense selectedSegmentIndex] == 1) {
		value = [value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
	}
	
	newBudgetPost.amount = value;
	newBudgetPost.comment = commentBox.text;
	
	newBudgetPost.timeStamp = [datePicker.date beginningOfDay];

	[self.managedObjectContext save:NULL];
	[self.navigationController popViewControllerAnimated:YES];
	
}

/**
 * Gets called when the date button is clicked.
 */
- (IBAction)setDateButtonClicked:(UIButton*) sender {
	UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"Välj datum"
													  delegate:self
											 cancelButtonTitle:nil
										destructiveButtonTitle:nil
											 otherButtonTitles:@"OK", nil];    
	// Add the picker
	[menu addSubview:datePicker];
	[menu showFromTabBar:self.tabBarController.tabBar];
	
	CGRect menuRect = menu.frame;
	CGFloat orgHeight = menuRect.size.height;
	menuRect.origin.y -= 214;
	menuRect.size.height = orgHeight+214;
	menu.frame = menuRect;
	
	CGRect pickerRect = datePicker.frame;
	pickerRect.origin.y = orgHeight;
	datePicker.frame = pickerRect;
	
	[menu release]; 
}

/**
 * Shows a UIActionSheet with an OK button
 */
-(void) showMessageWithString:(NSString *) message {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:message
															 delegate:nil
													cancelButtonTitle:@"OK"
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];
	[actionSheet showInView:[[self view] window]];
	[actionSheet release];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	valueBox.keyboardType = UIKeyboardTypeDecimalPad;
	[nameBox becomeFirstResponder];
}

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
	[datePicker release];
	[managedObjectContext_ release];
	[dateFormatter release];
    [super dealloc];
}


@end

