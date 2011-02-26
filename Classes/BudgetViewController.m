//
//  BudgetViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "BudgetViewController.h"
#import "BudgetPostDetailViewController.h"
#import "BudgetSettingsViewController.h"

@implementation BudgetViewController

@synthesize managedObjectContext=managedObjectContext_, displayedDate;


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


//TODO: Make it more loosely coupled? i.e remove budgetTableViewController-references
- (void)calculateBudgetSum {
	NSNumberFormatter *amountFormatter = [[NSNumberFormatter alloc] init];
	[amountFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
	
	NSDecimalNumber *amountBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
	for (NSManagedObject *object in [budgetTableViewController.fetchedResultsController fetchedObjects]) {
		NSDecimalNumber *objectExpenseNumber = [object valueForKey:@"amount"];
		amountBalance = [amountBalance decimalNumberByAdding:objectExpenseNumber];
	}
	
	totalBalance.text = [amountFormatter stringFromNumber:amountBalance];;
	if ([amountBalance compare:[NSNumber numberWithInt:0]] == NSOrderedAscending)
		totalBalance.textColor = [UIColor redColor];
	else
		totalBalance.textColor = [UIColor greenColor];
	
	[amountFormatter release];
}

- (void)budgetPostUpdated:(NSNotification*)notification {
	[self calculateBudgetSum];
}

- (void)updateCalendarLabel {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	if (isMonthView) {
		[formatter setDateFormat:@"MMMM, YYYY"];
	} else {
		[formatter setDateFormat:@"'Vecka' ww, YYYY"];
	}

	calendarLabel.text = [formatter stringFromDate:self.displayedDate];
	[formatter release];	
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Cogwheel"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    self.navigationItem.leftBarButtonItem = settingsButton;
	[settingsButton release];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPost)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	self.navigationItem.titleView = topView;
	
	[budgetTableViewController setManagedObjectContext:managedObjectContext_];

	[self calculateBudgetSum];
	
	//Observer pattern
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(budgetPostUpdated:) name:@"BudgetPostUpdated" object:nil];
	
	CGAffineTransform mirror = CGAffineTransformMakeScale(-1.f, 1.f);
	[previousCalendarButton setTransform:mirror];
	
	self.displayedDate = [NSDate date];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	isMonthView = [defaults boolForKey:@"budgetViewIsMonth"];
	[self updateCalendarLabel];
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
#pragma mark Event handling

- (void)addPost {
	budgetPostDetailViewController = [[BudgetPostDetailViewController alloc] initInManagedObjectContext:self.managedObjectContext];
	[self.navigationController pushViewController:budgetPostDetailViewController animated:YES];
	[budgetPostDetailViewController release];
}

- (void)showSettings {
	if (budgetSettingsViewController == nil) {
		budgetSettingsViewController = [[BudgetSettingsViewController alloc] initWithNibName:@"BudgetSettingsViewController" bundle:nil];
		[budgetSettingsViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	}
	[self.navigationController pushViewController:budgetSettingsViewController animated:YES];
}

- (IBAction)previousCalendarClick:(id)sender {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	if(isMonthView)
		components.month = -1;
	else
		components.day = -7;
	self.displayedDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:displayedDate options:0];
	[components release];
	[self updateCalendarLabel];
}

- (IBAction)nextCalendarClick:(id)sender {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	if(isMonthView)
		components.month = 1;
	else
		components.day = 7;
	self.displayedDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:displayedDate options:0];
	[components release];
	[self updateCalendarLabel];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[displayedDate release];
}


- (void)dealloc {
	[budgetSettingsViewController release];
    [super dealloc];
}


@end

