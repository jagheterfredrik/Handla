//
//  BudgetTableViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-21.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "BudgetTableViewCell.h"

@class BudgetViewController;

@interface BudgetTableViewController : CoreDataTableViewController {
	NSManagedObjectContext *managedObjectContext_;
	NSDateFormatter *dateFormatter;
	NSNumberFormatter *amountFormatter;
	IBOutlet BudgetViewController *budgetViewController;
    NSFetchedResultsController *sumResultController;
    NSDecimalNumber *previousBudgetSum;
    NSDecimalNumber *budgetSum, *plusSum, *minusSum;
	NSDate *startDate;
	NSDate *endDate;
    UIImage *plusSign, *minusSign;
    
    BudgetTableViewCell *prevCell;
    UINavigationItem *navItem;
}

- (void)setManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (void)setDurationStartDate:(NSDate*)startDate endDate:(NSDate*)endDate;
- (void)calculateBudgetData;

@property (nonatomic, retain) UINavigationItem *navItem;
@property (nonatomic, retain) NSDecimalNumber *previousBudgetSum;
@property (nonatomic, retain) NSDecimalNumber *budgetSum, *plusSum, *minusSum;

@end
