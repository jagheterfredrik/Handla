//
//  BudgetViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BudgetTableViewController.h"

@class BudgetPostDetailViewController;
@class BudgetSettingsViewController;

@interface BudgetViewController : UIViewController {
	BudgetPostDetailViewController *budgetPostDetailViewController;
	BudgetSettingsViewController *budgetSettingsViewController;
	IBOutlet BudgetTableViewController *budgetTableViewController;
	IBOutlet UILabel *totalBalance;
	IBOutlet UIView *topView;
	IBOutlet UIButton *previousCalendarButton;
	IBOutlet UILabel *calendarLabel;
	NSManagedObjectContext *managedObjectContext_;
}

- (void)addPost;
- (void)showSettings;

- (IBAction)previousCalendarClick:(id)sender;
- (IBAction)nextCalendarClick:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
