//
//  CheckoutViewController.h
//  Handla
//
//  Created by viktor holmberg on 2011-02-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CheckoutViewController : UIViewController {
	NSDecimalNumber* amountToBePayed;
	IBOutlet UILabel* totalAmount;
	IBOutlet UILabel* femhundringar;
	IBOutlet UILabel* hundringar;
	IBOutlet UILabel* femtiolappar;
	IBOutlet UILabel* tjugolappar;
	IBOutlet UILabel* tior;
	IBOutlet UILabel* femmor;
	IBOutlet UILabel* enkronor;
	
}
- (id) initWithAmountToPay: (NSDecimalNumber*)amount;
@property(nonatomic, retain) NSDecimalNumber* amountToBePayed;


@end
