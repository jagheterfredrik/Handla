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

/**
 * Calculates the sum of the budget currently displayed.
 */
//TODO: Make it more loosely coupled? i.e remove budgetTableViewController-references
- (void)calculateBudgetSum {
    NSDecimalNumber *amountBalance = budgetTableViewController.budgetSum;
    if (amountBalance) {
        NSNumberFormatter *amountFormatter = [[NSNumberFormatter alloc] init];
        [amountFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        
        totalBalance.text = [amountFormatter stringFromNumber:amountBalance];
        if ([amountBalance compare:[NSNumber numberWithInt:0]] == NSOrderedAscending)
            totalBalance.textColor = [UIColor redColor];
        else
            totalBalance.textColor = [UIColor colorWithRed:0.f green:0.55f blue:0.f alpha:1.f];
        
        [amountFormatter release];
        
        float minus = [budgetTableViewController.minusSum floatValue];
        float tot = [budgetTableViewController.budgetSum floatValue];
        plusPie.value = (tot > 0 ? tot : 0);
        minusPie.value = minus;
        [pieChart setNeedsDisplay];
    }
}

/**
 * Updates the calendar label.
 */
- (void)updateCalendarLabel {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *start, *end;
    
	if (dateInterval == YearInterval) {
		[formatter setDateFormat:@"YYYY"];
        start = [displayedDate beginningOfYear];
        end = [displayedDate endOfYear];
	} else if (dateInterval == WeekInterval) {
		[formatter setDateFormat:@"'Vecka' ww, YYYY"];
        start = [displayedDate beginningOfWeek];
        end = [displayedDate endOfWeek];
	} else {
		[formatter setDateFormat:@"MMMM, YYYY"];
        start = [displayedDate beginningOfMonth];
        end = [displayedDate endOfMonth];
	}

	[budgetTableViewController setDurationStartDate:start endDate:end];
	calendarLabel.text = [formatter stringFromDate:self.displayedDate];
	[formatter release];
    
    [self calculateBudgetSum];
}

/**
 * Called when receiving a BudgetPostUpdated notification.
 */
- (void)budgetPostUpdated:(NSNotification*)notification {
    [self updateCalendarLabel];
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    //fulhack..
    budgetTableViewController.navItem = self.navigationItem;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPost)];
	self.navigationItem.rightBarButtonItem = addButton;
	self.navigationItem.leftBarButtonItem = budgetTableViewController.editButtonItem;
	[addButton release];
	
	self.navigationItem.titleView = topView;
	
	[budgetTableViewController setManagedObjectContext:managedObjectContext_];
    
    [self calculateBudgetSum];
	
	//Observer pattern
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(budgetPostUpdated:) name:@"BudgetPostUpdated" object:nil];
    
    pieChart = [[PCPieChart alloc] initWithFrame:CGRectMake(0.f,-3.f,80.f,80.f)];
    [pieChart setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [pieChart setDiameter:45.f];
    
    //[pieChart setBackgroundColor:[UIColor blueColor]];
    
    
    
    plusPie = [[PCPieComponent alloc] initWithValue:25.f];
    [plusPie setColour:PCColorGreen];
    minusPie = [[PCPieComponent alloc] initWithValue:70.f];
    [minusPie setColour:PCColorRed];
    
    [pieChart setComponents:[NSArray arrayWithObjects:minusPie, plusPie, nil]];
    
    [bottomView addSubview:pieChart];
    [pieChart setNeedsDisplay];
	
	self.displayedDate = [NSDate date];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	dateInterval = [defaults integerForKey:@"budgetViewDateInterval"];
	[self updateCalendarLabel];
    [budgetTableViewController viewWillAppear:animated];
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

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
	//Remove the budgetpost
	[managedObjectContext_ deleteObject:managedObject];
}

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
	if(dateInterval == YearInterval)
		components.year = -1;
	else if (dateInterval == WeekInterval)
		components.day = -7;
	else
		components.month = -1;
	self.displayedDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:displayedDate options:0];
	[components release];
	[self updateCalendarLabel];
}

- (IBAction)nextCalendarClick:(id)sender {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	if(dateInterval == YearInterval)
		components.year = 1;
	else if (dateInterval == WeekInterval)
		components.day = 7;
	else
		components.month = 1;
	self.displayedDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:displayedDate options:0];
	[components release];
	[self updateCalendarLabel];
}

- (IBAction)calendarLabelClick:(id)sender {
	self.displayedDate = [NSDate date];
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
    [pieChart release];
    [plusPie release];
    [minusPie release];
}


- (void)dealloc {
	[budgetSettingsViewController release];
    [super dealloc];
}


@end

