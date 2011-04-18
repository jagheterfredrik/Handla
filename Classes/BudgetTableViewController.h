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
    NSFetchedResultsController *sumResultController;
    NSDecimalNumber *previousBudgetSum;
    NSDecimalNumber *budgetSum;
	NSDate *startDate;
	NSDate *endDate;
}

- (void)setManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (void)setDurationStartDate:(NSDate*)startDate endDate:(NSDate*)endDate;

@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDecimalNumber *previousBudgetSum;
@property (nonatomic, retain) NSDecimalNumber *budgetSum;

@end
