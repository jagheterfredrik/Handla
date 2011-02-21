//
//  BudgetViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BudgetTableViewController.h"

@class AddBudgetPostViewController;
@class BudgetSettingsViewController;

@interface BudgetViewController : UIViewController {
	AddBudgetPostViewController *addBudgetPostViewController;
	BudgetSettingsViewController *budgetSettingsViewController;
	IBOutlet BudgetTableViewController *budgetTableViewController;
	NSManagedObjectContext *managedObjectContext_;
}

- (void)addPost;
- (void)showSettings;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
