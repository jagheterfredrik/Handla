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
//  Initializes with the amount to be payed.
//
//=========================================================== 
- (id) initWithAmountToPay: (NSDecimalNumber*)amount
{
	self.amountToBePayed = amount;
	return self;
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
    [super viewDidLoad];
	NSInteger remaining = [self.amountToBePayed intValue];
	totalAmount.text = [self.amountToBePayed stringValue];
	
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
	remaining = remaining%1;
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


@end
