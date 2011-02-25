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
	NSDecimalNumber* amountToBePayed;
	NSString* listName;
	IBOutlet UILabel* totalAmount;
	IBOutlet UILabel* femhundringar;
	IBOutlet UILabel* hundringar;
	IBOutlet UILabel* femtiolappar;
	IBOutlet UILabel* tjugolappar;
	IBOutlet UILabel* tior;
	IBOutlet UILabel* femmor;
	IBOutlet UILabel* enkronor;
	
	IBOutlet UILabel* nameOfPurchase;
	
}

- (id) initWithList:(List*) list AmountToPay: (NSDecimalNumber*)amount;
- (IBAction) paymentCompleteButtonPressed: (id) sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, retain) NSDecimalNumber* amountToBePayed;
@property(nonatomic, retain) BudgetPost* budgetPostToBeAdded;
@property(nonatomic, retain) List* list;


@end
