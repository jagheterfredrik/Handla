//
//  AddBudgetPostViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BudgetPost.h"

@interface AddBudgetPostViewController : UIViewController {
	NSManagedObjectContext *managedObjectContext_;
	IBOutlet UITextField* nameBox;
	IBOutlet UITextField* valueBox;
	IBOutlet UITextField* commentBox;
	IBOutlet UISegmentedControl* incomeOrExpense;
	
}

- (id)initInManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField;
- (IBAction)doneClick:(id) sender;
- (IBAction)cancelClick:(id)sender;
- (void)showMessageWithString:(NSString *) message;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
