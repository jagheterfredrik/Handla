//
//  CheckoutViewController.h
//  Handla
//
//  Created by viktor holmberg on 2011-02-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BudgetPost.h"
#import "list.h"


@interface CheckoutViewController : UIViewController {
	
	NSManagedObjectContext *managedObjectContext_;
	
	NSInteger amountToBePayed;
	
	NSString* listName;
	BudgetPost* budgetPostToBeAdded;
	IBOutlet UILabel* totalAmount;
	IBOutlet UILabel* remaining;
	
	IBOutlet UIBarButtonItem* doneButton;
	
	
	
	IBOutlet UILabel* femhundringar;
	IBOutlet UILabel* hundringar;
	IBOutlet UILabel* femtiolappar;
	IBOutlet UILabel* tjugolappar;
	IBOutlet UILabel* tior;
	IBOutlet UILabel* femmor;
	IBOutlet UILabel* enkronor;	
	IBOutlet UILabel* nameOfPurchase;
	
	NSInteger currentFemhundringar;
	NSInteger currentHundringar;
	NSInteger currentFemtiolappar;
	NSInteger currentTjugolappar;
	NSInteger currentTior;
	NSInteger currentFemmor;
	NSInteger currentEnkronor;	
	
	List* list_;
}

- (id)initWithList:(List*)list AmountToPay:(NSDecimalNumber*)amount;
- (void)refreshSelectedValuesDisplay;
- (NSInteger) getTotalSelectedAmount;

- (IBAction)cancelClick:(id)sender;

- (IBAction)paymentCompleteButtonPressed:(id)sender;
- (IBAction)femhundringButtonPressed:(UIButton*)sender;
- (IBAction)hundringButtonPressed:(UIButton*)sender;
- (IBAction)femtiolappButtonPressed:(UIButton*)sender;
- (IBAction)tjugolappButtonPressed:(UIButton*)sender;
- (IBAction)tiaButtonPressed:(UIButton*)sender;
- (IBAction)femmaButtonPressed:(UIButton*)sender;
- (IBAction)enkronaButtonPressed:(UIButton*)sender;

@property (nonatomic,retain) List* list;

@end
