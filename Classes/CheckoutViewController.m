//
//  CheckoutViewController.m
//  Handla
//
//  Created by viktor holmberg on 2011-02-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckoutViewController.h"


@implementation CheckoutViewController
@synthesize amountToBePayed;

//=========================================================== 
//  Initializes with the manegedObjectContext and the amount to be payed.
//
//=========================================================== 
- (id) initWithList:(List*) list AmountToPay: (NSDecimalNumber*)amount
{
	self.amountToBePayed = amount;
	list_ = list;
	return self;
}


//=========================================================== 
//  when the done button is pressed, save the list sum to the database and go to budget view.
//
//=========================================================== 
- (IBAction) paymentCompleteButtonPressed: (id) sender
{
	BudgetPost* newBudgetPost = [NSEntityDescription insertNewObjectForEntityForName:
					 @"BudgetPost" inManagedObjectContext:list_.managedObjectContext];
	newBudgetPost.name = list_.name;
	newBudgetPost.timeStamp = [NSDate date];
	//TODO: this should be rounded if we pay with cash; since there are no femtioörings anymore 
	newBudgetPost.amount = [amountToBePayed decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
	
	
	//TODO: add comment!
	//[NSString stringWithFormat:@"Automatiskt sparat inköp %s", [[NSDate date] description]];
	
	
	[list_.managedObjectContext save:NULL];
	
	
	//go to budget mode
	[self.tabBarController setSelectedIndex:1];
	
	//go to list view. Maybe even listSview???
	[self.navigationController popViewControllerAnimated:NO];
	
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	//TODO: remember the öres!
    [super viewDidLoad];
	NSInteger remaining = [amountToBePayed intValue];
	totalAmount.text = [amountToBePayed stringValue];
	nameOfPurchase.text = list_.name;
	
	femhundringar.text = [NSString stringWithFormat:@"%i", remaining/500];
	remaining = remaining%500;
	
	hundringar.text =  [NSString stringWithFormat:@"%i", remaining/100];
	remaining = remaining%100;
	
	femtiolappar.text =  [NSString stringWithFormat:@"%i", remaining/50];
	remaining = remaining%50;
	
	tjugolappar.text =  [NSString stringWithFormat:@"%i", remaining/20];
	remaining = remaining%20;
	
	tior.text =  [NSString stringWithFormat:@"%i", remaining/10];
	remaining = remaining%10;
	
	femmor.text =  [NSString stringWithFormat:@"%i", remaining/5];
	remaining = remaining%5;
	
	enkronor.text =  [NSString stringWithFormat:@"%i", remaining/1];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[amountToBePayed release];
    [super dealloc];
}


@end
