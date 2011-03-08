//
//  CheckoutViewController.m
//  Handla
//
//  Created by viktor holmberg on 2011-02-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CheckoutViewController.h"
#import <QuartzCore/QuartzCore.h>


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

- (IBAction)cancelClick:(id)sender 
{
	[self dismissModalViewControllerAnimated:YES];
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
	
	
	//go to budget mode (TODO: fix. observer pattern?)
	[self.parentViewController.tabBarController setSelectedIndex:1];
	
	//go to list view. Maybe even listSview???
	[self dismissModalViewControllerAnimated:YES];
	
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
	femhundringar.text = [NSString stringWithFormat:@"%i",	1*currentFemhundringar];	
	hundringar.text =  [NSString stringWithFormat:@"%i",	1*currentHundringar];
	femtiolappar.text =  [NSString stringWithFormat:@"%i",	1*currentFemtiolappar];	
	tjugolappar.text =  [NSString stringWithFormat:@"%i",	1*currentTjugolappar];	
	tior.text =  [NSString stringWithFormat:@"%i",			1*currentTior];
	femmor.text =  [NSString stringWithFormat:@"%i",		1*currentFemmor];	
	enkronor.text =  [NSString stringWithFormat:@"%i",		1*currentEnkronor];
	
	NSInteger moneyRemaining = amountToBePayed-[self getTotalSelectedAmount];
	remaining.text = [NSString stringWithFormat:@"%i", (moneyRemaining)];
	if ((amountToBePayed-[self getTotalSelectedAmount])<=0) {
		doneButton.style = UIBarButtonItemStyleDone;
	}
	
	[self setRedBoarderButton:ButtonFemhundringar withBoarderSize:0];
	[self setRedBoarderButton:ButtonHundringar withBoarderSize:0];
	[self setRedBoarderButton:ButtonFemtiolappar withBoarderSize:0];
	[self setRedBoarderButton:ButtonTjugolappar withBoarderSize:0];
	[self setRedBoarderButton:ButtonTior withBoarderSize:0];
	[self setRedBoarderButton:ButtonFemmor withBoarderSize:0];
	[self setRedBoarderButton:ButtonEnkronor withBoarderSize:0];
	
	ButtonFemhundringar.alpha =1;
	ButtonHundringar.alpha = 1;
	ButtonFemtiolappar.alpha = 1;
	ButtonTjugolappar.alpha = 1;
	ButtonTior.alpha = 1;
	ButtonFemmor.alpha = 1;
	ButtonEnkronor.alpha = 1;
	

	
	
	
	if (moneyRemaining>=500){
		[self setRedBoarderButton:ButtonFemhundringar withBoarderSize:2.0];
	}
	else if(moneyRemaining>=100){		
		[self setRedBoarderButton:ButtonHundringar withBoarderSize:2.0];
	}
	else if(moneyRemaining>=50){		
		[self setRedBoarderButton:ButtonFemtiolappar withBoarderSize:2.0];
	}
	else if(moneyRemaining>=20){		
		[self setRedBoarderButton:ButtonTjugolappar withBoarderSize:2.0];
	}
	else if(moneyRemaining>=10){		
		[self setRedBoarderButton:ButtonTior withBoarderSize:2.0];
	}
	else if(moneyRemaining>=5){		
		[self setRedBoarderButton:ButtonFemmor withBoarderSize:2.0];
	}
	else if(moneyRemaining>0){		
		[self setRedBoarderButton:ButtonEnkronor withBoarderSize:2.0];
	}
	else if(moneyRemaining<=0){
		ButtonFemhundringar.alpha =0.4;
		ButtonHundringar.alpha = 0.4;
		ButtonFemtiolappar.alpha = 0.4;
		ButtonTjugolappar.alpha = 0.4;
		ButtonTior.alpha = 0.4;
		ButtonFemmor.alpha = 0.4;
		ButtonEnkronor.alpha = 0.4;
	}

} 
	

//=========================================================== 
// - (void)setRedBoarderButton:(UIButton theButton)
//
//=========================================================== 
- (void)setRedBoarderButton:(UIButton*)theButton withBoarderSize:(float)boarderSize  
{	
	[theButton.layer setBorderColor: [[UIColor redColor] CGColor]];
	[theButton.layer setBorderWidth: boarderSize];
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
// - (IBAction)removeCash:(UICashView*)sender
//
//=========================================================== 
- (IBAction)removeCash:(UICashView*)sender
{
	switch (sender.value) {
		case 500:
			currentFemhundringar--;
			break;
		case 100:
			currentHundringar--;
			break;
		case 50:
			currentFemtiolappar--;
			break;
		case 20:
			currentTjugolappar--;
			break;
		case 10:
			currentTior--;
			break;
		case 5:
			currentFemmor--;
			break;
		case 1:
			currentEnkronor--;
			break;
	}
	[self refreshSelectedValuesDisplay];
	
	sender.enabled = NO;
	
	[UIView animateWithDuration:0.1 
					 animations:^{
						 sender.frame = sender.startingPlace;
					 }
	 
					 completion:^(BOOL  completed){
						 [sender removeFromSuperview];
					 }
	 ];
	
}


- (void)addMoneyPressed:(UIButton*)sender withMoneyInStack:(NSInteger)currentlyInStack border:(BOOL)border {
	UICashView *movingButton = [UICashView buttonWithType:UIButtonTypeCustom];
	[movingButton setImage:sender.currentImage forState:UIControlStateNormal];
	[movingButton setFrameAndRememberIt:sender.frame withCashValue:[sender tag]];
	if (border) {
		[movingButton.layer setBorderColor: [[UIColor blackColor] CGColor]];
		[movingButton.layer setBorderWidth: 1];
	}
	[movingButton addTarget:self action:@selector(removeCash:)
		   forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:movingButton];
	
	[UIView animateWithDuration:0.4
						  delay:0
						options:UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 movingButton.frame = CGRectMake(50+((currentlyInStack-1)%5)*20, 
														 sender.frame.origin.y+(((currentlyInStack-1)%5))*2,
														 sender.frame.size.width, 
														 sender.frame.size.height);
					 } completion:nil];
	[self refreshSelectedValuesDisplay];
}

//=========================================================== 
// - (IBAction)femhundringButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)femhundringButtonPressed:(UIButton*)sender
{
	[self addMoneyPressed:sender withMoneyInStack:++currentFemhundringar border:YES];
}
//=========================================================== 
// - (IBAction)hundringButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)hundringButtonPressed:(UIButton*)sender
{
	[self addMoneyPressed:sender withMoneyInStack:++currentHundringar border:YES];
}
//=========================================================== 
// - (IBAction)femtiolappButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)femtiolappButtonPressed:(UIButton*)sender
{
	[self addMoneyPressed:sender withMoneyInStack:++currentFemtiolappar border:YES];
}
//=========================================================== 
// - (IBAction)tjugolappButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)tjugolappButtonPressed:(UIButton*)sender
{
		[self addMoneyPressed:sender withMoneyInStack:++currentTjugolappar border:YES];
}
//=========================================================== 
// - (IBAction)tiaButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)tiaButtonPressed:(UIButton*)sender
{
		[self addMoneyPressed:sender withMoneyInStack:++currentTior border:NO];
}
//=========================================================== 
// - (IBAction)femmaButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)femmaButtonPressed:(UIButton*)sender
{	
		[self addMoneyPressed:sender withMoneyInStack:++currentFemmor border:NO];
}
//=========================================================== 
// - (IBAction)enkronaButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)enkronaButtonPressed:(UIButton*)sender
{
		[self addMoneyPressed:sender withMoneyInStack:++currentEnkronor border:NO];
}

@end
