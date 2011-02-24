//
//  BudgetTableViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-21.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
@class BudgetViewController;

@interface BudgetTableViewController : CoreDataTableViewController {
	NSManagedObjectContext *managedObjectContext_;
	NSDateFormatter *dateFormatter;
	NSNumberFormatter *amountFormatter;
	IBOutlet BudgetViewController *budgetViewController;
}

- (void)setManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@end
