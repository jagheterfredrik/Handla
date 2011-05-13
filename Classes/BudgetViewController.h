//
//  BudgetViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BudgetTableViewController.h"

#import "NSDate+Helper.h"
#import "PCPieChart.h"

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
    IBOutlet UIView *bottomView;
	NSManagedObjectContext *managedObjectContext_;
	NSDate *displayedDate;
	NSInteger dateInterval;
    PCPieChart *pieChart;
    PCPieComponent *plusPie, *minusPie;
}

- (void)addPost;
- (void)showSettings;

- (IBAction)previousCalendarClick:(id)sender;
- (IBAction)nextCalendarClick:(id)sender;
- (IBAction)calendarLabelClick:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSDate *displayedDate;

@end
