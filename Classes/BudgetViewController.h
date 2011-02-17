//
//  BudgetViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddBudgetPostViewController;
@class BudgetSettingsViewController;

@interface BudgetViewController : UITableViewController {
	AddBudgetPostViewController *addBudgetPostViewController;
	BudgetSettingsViewController *budgetSettingsViewController;
	NSManagedObjectContext *managedObjectContext;
}

- (void)addPost;
- (void)showSettings;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
