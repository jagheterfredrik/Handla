//
//  CheckoutViewController.m
//  Handla
//
//  Created by viktor holmberg on 2011-02-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckoutViewController.h"


@implementation CheckoutViewController
@synthesize list;


//=========================================================== 
//  Initializes with the manegedObjectContext and the amount to be payed.
//
//=========================================================== 
- (id) initWithList:(List*) theList AmountToPay: (NSDecimalNumber*)amount
{
	//TODO: FIX roundoff behaviour
	amountToBePayed = [amount integerValue];
	
	self.list = theList;
	currentFemhundringar=0;
	currentHundringar=0;
	currentFemtiolappar=0;
	currentTjugolappar=0;
	currentTior=0;
	currentFemmor=0;
	currentEnkronor=0;
	return self;
}


//=========================================================== 
//  when the done button is pressed, save the list sum to the database and go to budget view.
//
//=========================================================== 
- (IBAction) paymentCompleteButtonPressed: (id) sender
{
	BudgetPost* newBudgetPost = [NSEntityDescription insertNewObjectForEntityForName:@"BudgetPost" inManagedObjectContext:self.list.managedObjectContext];
	newBudgetPost.name = self.list.name;
	newBudgetPost.timeStamp = [NSDate date];
	//TODO: this should be rounded if we pay with cash; since there are no femtioörings anymore 
	newBudgetPost.amount = [NSDecimalNumber decimalNumberWithString:
							[NSString stringWithFormat:@"%i", (amountToBePayed*-1)]];
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
	
	//TODO: remember the öres! round up and stuff!
    [super viewDidLoad];
	totalAmount.text = [NSString stringWithFormat:@"%i", amountToBePayed];
	nameOfPurchase.text = list_.name;
	[self refreshSelectedValuesDisplay];

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
    [super dealloc];
}


//=========================================================== 
// - (void)refreshSelectedValuesDisplay
//
//=========================================================== 
- (void)refreshSelectedValuesDisplay
{
	femhundringar.text = [NSString stringWithFormat:@"%i", currentFemhundringar];	
	hundringar.text =  [NSString stringWithFormat:@"%i", currentHundringar];
	femtiolappar.text =  [NSString stringWithFormat:@"%i", currentFemtiolappar];	
	tjugolappar.text =  [NSString stringWithFormat:@"%i", currentTjugolappar];	
	tior.text =  [NSString stringWithFormat:@"%i", currentTior];
	femmor.text =  [NSString stringWithFormat:@"%i", currentFemmor];	
	enkronor.text =  [NSString stringWithFormat:@"%i", currentEnkronor];
	
	remaining.text = [NSString stringWithFormat:@"%i", (amountToBePayed-[self getTotalSelectedAmount])];
	if ((amountToBePayed-[self getTotalSelectedAmount])<=0) {
		doneButton.enabled = YES;
	}


} 

//=========================================================== 
// - (NSInteger) getTotalSelectedAmount
//
//=========================================================== 
- (NSInteger) getTotalSelectedAmount
{
	return (500*currentFemhundringar+100*currentHundringar+
	50*currentFemtiolappar+20*currentTjugolappar
	+10*currentTior+5*currentFemmor+1*currentEnkronor);
}

//=========================================================== 
// - (IBAction)femhundringButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)femhundringButtonPressed:(UIButton*)sender
{
	currentFemhundringar++;
	[self refreshSelectedValuesDisplay];
	
}
//=========================================================== 
// - (IBAction)hundringButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)hundringButtonPressed:(UIButton*)sender
{
	currentHundringar++;
	[self refreshSelectedValuesDisplay];
}
//=========================================================== 
// - (IBAction)femtiolappButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)femtiolappButtonPressed:(UIButton*)sender
{
	currentFemtiolappar++;
	[self refreshSelectedValuesDisplay];
}
//=========================================================== 
// - (IBAction)tjugolappButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)tjugolappButtonPressed:(UIButton*)sender
{
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"20.jpg"]];
	imgView.frame = CGRectMake(215, 139, 72, 37);
	[self.view addSubview:imgView];
	[UIView beginAnimations:@"slide" context:nil];
	imgView.frame = CGRectMake(10+currentTjugolappar*10, 139+(currentTjugolappar%5)*3, 72, 37);
	[UIView setAnimationDuration:1];
	[UIView commitAnimations];
	[imgView release];
	currentTjugolappar++;
	[self refreshSelectedValuesDisplay];
}
//=========================================================== 
// - (IBAction)tiaButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)tiaButtonPressed:(UIButton*)sender
{
	currentTior++;
	[self refreshSelectedValuesDisplay];
}
//=========================================================== 
// - (IBAction)femmaButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)femmaButtonPressed:(UIButton*)sender
{
	currentFemmor++;
	[self refreshSelectedValuesDisplay];
}
//=========================================================== 
// - (IBAction)enkronaButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)enkronaButtonPressed:(UIButton*)sender
{
	currentEnkronor++;
	[self refreshSelectedValuesDisplay];
}

@
end
