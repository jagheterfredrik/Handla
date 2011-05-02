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
- (id) initWithList:(List*) theList amountToPay:(NSDecimalNumber*)amount
{
	// Correct rounding behaviour
	NSDecimalNumberHandler *roundHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
																								  scale:0
																					   raiseOnExactness:NO
																						raiseOnOverflow:NO
																					   raiseOnUnderflow:NO
																					raiseOnDivideByZero:NO];
	amountToBePayed = [[amount decimalNumberByRoundingAccordingToBehavior:roundHandler] integerValue];
	
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
//  when the done button is pressed, display popups. these will then save
//  the list sum to the database and go to budget view if the user confirms it.
//
//=========================================================== 
- (IBAction) paymentCompleteButtonPressed: (id) sender
{
	NSInteger tempremaining=(amountToBePayed-[self getTotalSelectedAmount]);
		if (tempremaining>0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lägga till budgetpost?" 
													message:@"Vill du lägga till budgetposten och avsluta köpet direkt?" 
												   delegate:self 
										  cancelButtonTitle:@"Nej"
											  otherButtonTitles:@"Ja", nil];
		[alert show];
		[alert release];
	}
	else if (tempremaining<0){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Budgetpost tillagd" 
														message:[NSString stringWithFormat:@"Erhåll %i kr i växel.",-(amountToBePayed-[self getTotalSelectedAmount]) ]
													   delegate:nil 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[self unCheckArticles];
		[self addBudgetPostAndChangeViewToBudgetView];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Budgetpost tillagd" 
														message:[NSString stringWithFormat:@"Jämna pengar, nice!",(amountToBePayed-[self getTotalSelectedAmount]) ]
													   delegate:nil 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[self unCheckArticles];
		[self addBudgetPostAndChangeViewToBudgetView];
	}

}

//=========================================================== 
// - (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//
//=========================================================== 
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.numberOfButtons==2) {
		if (buttonIndex==1) {
			//clicked "ja"
						
			[self unCheckArticles];
			[self addBudgetPostAndChangeViewToBudgetView];
			}
	}
}

/*
 Unchecks the articles when the purchase is finished.
*/
-(void)unCheckArticles{
	NSArray *myArray = [list.articles allObjects];
	for(ListArticle *object in myArray) {
		[object setChecked:[NSNumber numberWithBool:NO]];
	}
}

-(void)addBudgetPostAndChangeViewToBudgetView{
	
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
	//TODO: it would be great if the new budgetpost was highlighted in budgetview
	[[[(UITabBarController*)self.parentViewController viewControllers] objectAtIndex:0] popViewControllerAnimated:NO]; 
	[(UITabBarController*)self.parentViewController setSelectedIndex:2];
	
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
	totalAmount.text = [NSString stringWithFormat:@"%i kr", amountToBePayed];
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
	
	//set everything to standard looks, i.e you have money left to pay
	NSInteger moneyRemaining = amountToBePayed-[self getTotalSelectedAmount];
	remaining.text = [NSString stringWithFormat:@"%i kr", (moneyRemaining)];
	if ((amountToBePayed-[self getTotalSelectedAmount])<=0) {
		
	}
	
	[self setRedBorderButton:ButtonFemhundringar withBorderSize:0];
	[self setRedBorderButton:ButtonHundringar withBorderSize:0];
	[self setRedBorderButton:ButtonFemtiolappar withBorderSize:0];
	[self setRedBorderButton:ButtonTjugolappar withBorderSize:0];
	[self setRedBorderButton:ButtonTior withBorderSize:0];
	[self setRedBorderButton:ButtonFemmor withBorderSize:0];
	[self setRedBorderButton:ButtonEnkronor withBorderSize:0];
	
	if (moneyRemaining>0) {
		[UIView animateWithDuration:0.5
							  delay:0
							options:UIViewAnimationOptionAllowUserInteraction
						 animations:^{
							 ButtonFemhundringar.alpha =1;
							 ButtonHundringar.alpha = 1;
							 ButtonFemtiolappar.alpha = 1;
							 ButtonTjugolappar.alpha = 1;
							 ButtonTior.alpha = 1;
							 ButtonFemmor.alpha = 1;
							 ButtonEnkronor.alpha = 1;	
							 
							 doneButton.style = UIBarButtonItemStylePlain;
							 change.text = @"0 kr";
							 change.alpha = 
							 changeStaticText.alpha = 0.3f;
							 remaining.alpha =
							 remainingStaticText.alpha = 1.0f;
						 } completion:nil];
		
		
	}

	
	if (moneyRemaining>=500){
		[self setRedBorderButton:ButtonFemhundringar withBorderSize:2.0f];
	}
	else if(moneyRemaining>=100){		
		[self setRedBorderButton:ButtonHundringar withBorderSize:2.0f];
	}
	else if(moneyRemaining>=50){		
		[self setRedBorderButton:ButtonFemtiolappar withBorderSize:2.0f];
	}
	else if(moneyRemaining>=20){		
		[self setRedBorderButton:ButtonTjugolappar withBorderSize:2.0f];
	}
	else if(moneyRemaining>=10){		
		[self setRedBorderButton:ButtonTior withBorderSize:2.0f];
	}
	else if(moneyRemaining>=5){		
		[self setRedBorderButton:ButtonFemmor withBorderSize:2.0f];
	}
	else if(moneyRemaining>0){		
		[self setRedBorderButton:ButtonEnkronor withBorderSize:2.0f];
	}
	else if(moneyRemaining<=0){
		//we are done picking up money
		[UIView animateWithDuration:0.5
							  delay:0
							options:UIViewAnimationOptionAllowUserInteraction
						 animations:^{
							 ButtonFemhundringar.alpha =
							 ButtonHundringar.alpha = 
							 ButtonFemtiolappar.alpha = 
							 ButtonTjugolappar.alpha = 
							 ButtonTior.alpha = 
							 ButtonFemmor.alpha = 
							 ButtonEnkronor.alpha = 0.4f;
							 
							 doneButton.style = UIBarButtonItemStyleDone;
							 change.text = [NSString stringWithFormat:@"%i kr", -(moneyRemaining)];
							 change.alpha = 
							 changeStaticText.alpha = 1.0f;
							 remaining.text = @"0 kr";
							 remaining.alpha =
							 remainingStaticText.alpha = 0.3f;
						 } completion:nil];
		
	}

} 
	

//=========================================================== 
// - (void)setRedBorderButton:(UIButton theButton)
//
//=========================================================== 
- (void)setRedBorderButton:(UIButton*)theButton withBorderSize:(float)boarderSize  
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
	sender.enabled = NO;
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
	
	//fuck stacks, lets iterate
	UICashView *curr = sender;
	for (id view_ in [self.view subviews]) {
		if ([view_ isKindOfClass:[UICashView class]]) {
			if (((UICashView*)view_).value == sender.value) {
				curr = view_;
			}
		}
	}
	
	curr.enabled = NO;
	if (sender != curr) {
		sender.enabled = YES;
	}
	
	[UIView animateWithDuration:0.1f
						  delay:0.f
						options:0
					 animations:^{
						 curr.frame = curr.startingPlace;
					 }
	 
					 completion:^(BOOL  completed){
						 [curr removeFromSuperview];
					 }
	 ];
	
}


- (void)addMoneyPressed:(UIButton*)sender withMoneyInStack:(NSInteger)currentlyInStack coin:(BOOL)coin {
	UICashView *movingButton = [UICashView buttonWithType:UIButtonTypeCustom];
	[movingButton setImage:sender.currentImage forState:UIControlStateNormal];
	[movingButton setFrameAndRememberIt:sender.frame withCashValue:[sender tag]];
	if (!coin) {
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
						 NSInteger now = currentlyInStack - 1;
						 movingButton.frame = CGRectMake(50 + (coin ? (now%10)*10 : (now%5)*20), 
														 sender.frame.origin.y + (coin ? 0 : ((now%5))*2),
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
	[self addMoneyPressed:sender withMoneyInStack:++currentFemhundringar coin:NO];
}
//=========================================================== 
// - (IBAction)hundringButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)hundringButtonPressed:(UIButton*)sender
{
	[self addMoneyPressed:sender withMoneyInStack:++currentHundringar coin:NO];
}
//=========================================================== 
// - (IBAction)femtiolappButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)femtiolappButtonPressed:(UIButton*)sender
{
	[self addMoneyPressed:sender withMoneyInStack:++currentFemtiolappar coin:NO];
}
//=========================================================== 
// - (IBAction)tjugolappButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)tjugolappButtonPressed:(UIButton*)sender
{
		[self addMoneyPressed:sender withMoneyInStack:++currentTjugolappar coin:NO];
}
//=========================================================== 
// - (IBAction)tiaButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)tiaButtonPressed:(UIButton*)sender
{
		[self addMoneyPressed:sender withMoneyInStack:++currentTior coin:YES];
}
//=========================================================== 
// - (IBAction)femmaButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)femmaButtonPressed:(UIButton*)sender
{	
		[self addMoneyPressed:sender withMoneyInStack:++currentFemmor coin:YES];
}
//=========================================================== 
// - (IBAction)enkronaButtonPressed:(UIButton*)sender
//
//=========================================================== 
- (IBAction)enkronaButtonPressed:(UIButton*)sender
{
		[self addMoneyPressed:sender withMoneyInStack:++currentEnkronor coin:YES];
}

@end
