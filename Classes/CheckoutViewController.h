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
#import "UICashView.h"
#import "IndividualListTableViewController.h"



@interface CheckoutViewController : UIViewController<UIAlertViewDelegate> {
		
	NSManagedObjectContext *managedObjectContext_;

	NSInteger amountToBePayed;
	
	NSString* listName;
	BudgetPost* budgetPostToBeAdded;
	IBOutlet UILabel* totalAmount;
	IBOutlet UILabel* remaining;
	IBOutlet UILabel* change;
	IBOutlet UILabel* changeStaticText;
	IBOutlet UILabel* remainingStaticText;
	
	IBOutlet UIBarButtonItem* doneButton;
	
	
	//the counter of how much money is picked up for each value
	IBOutlet UILabel* femhundringar;
	IBOutlet UILabel* hundringar;
	IBOutlet UILabel* femtiolappar;
	IBOutlet UILabel* tjugolappar;
	IBOutlet UILabel* tior;
	IBOutlet UILabel* femmor;
	IBOutlet UILabel* enkronor;	
	IBOutlet UILabel* nameOfPurchase;
	
	//the buttons which can light up to indicate they should be pressed
	//they start with a capital B beacause fuck you, thats why.
	IBOutlet UIButton* ButtonFemhundringar;
	IBOutlet UIButton* ButtonHundringar;
	IBOutlet UIButton* ButtonFemtiolappar;
	IBOutlet UIButton* ButtonTjugolappar;
	IBOutlet UIButton* ButtonTior;
	IBOutlet UIButton* ButtonFemmor;
	IBOutlet UIButton* ButtonEnkronor;	
	IBOutlet UIButton* ButtonNameOfPurchase;

	NSInteger currentFemhundringar;
	NSInteger currentHundringar;
	NSInteger currentFemtiolappar;
	NSInteger currentTjugolappar;
	NSInteger currentTior;
	NSInteger currentFemmor;
	NSInteger currentEnkronor;	
	
	List* list_;
}

- (id)initWithList:(List*)list amountToPay:(NSDecimalNumber*)amount;
- (void)refreshSelectedValuesDisplay;
- (NSInteger) getTotalSelectedAmount;
- (void)setRedBorderButton:(UIButton*)theButton withBorderSize:(float)boarderSize;  

- (IBAction)cancelClick:(id)sender;


- (IBAction)removeCash:(UICashView*)sender;

- (IBAction)paymentCompleteButtonPressed:(id)sender;
- (void)unCheckArticles;
- (void)addBudgetPostAndChangeViewToBudgetView;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;


- (IBAction)femhundringButtonPressed:(UIButton*)sender;
- (IBAction)hundringButtonPressed:(UIButton*)sender;
- (IBAction)femtiolappButtonPressed:(UIButton*)sender;
- (IBAction)tjugolappButtonPressed:(UIButton*)sender;
- (IBAction)tiaButtonPressed:(UIButton*)sender;
- (IBAction)femmaButtonPressed:(UIButton*)sender;
- (IBAction)enkronaButtonPressed:(UIButton*)sender;

@property (nonatomic,retain) List* list;

@end
