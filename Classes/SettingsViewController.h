//
//  SettingsViewController.h
//  Handla
//
//  Created by Max Westermark on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BudgetSettingsViewController.h"
#import "ListSettingsViewController.h"
#import "AboutViewController.h"

@interface SettingsViewController : UITableViewController {
	IBOutlet SettingsViewController *settingsViewController;
	BudgetSettingsViewController *budgetSettingsViewController;
	ListSettingsViewController *listSettingsViewController;
	AboutViewController *aboutViewController;
	NSString *listLabel;
	NSString *budgetLabel;
	NSString *aboutLabel;
	
}


@end
