//
//  AddBudgetPostViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BudgetPost.h"

@interface AddBudgetPostViewController : UIViewController<UIActionSheetDelegate> {
	NSManagedObjectContext *managedObjectContext_;
	BudgetPost *budgetPost_;
	UIDatePicker *datePicker;
	NSDateFormatter *dateFormatter;
	IBOutlet UITextField* nameBox;
	IBOutlet UITextField* valueBox;
	IBOutlet UITextField* commentBox;
	IBOutlet UISegmentedControl* incomeOrExpense;
	IBOutlet UIButton* dateShower;
	IBOutlet UIBarItem* doneButton;
}

- (id)initInManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (id)initWithBudgetPost:(BudgetPost*)budgetPost;
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField;
- (IBAction)doneClick:(id) sender;
- (IBAction)cancelClick:(id)sender;
- (void)showMessageWithString:(NSString *) message;
- (IBAction)setDateButtonClicked:(UIButton*) sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
