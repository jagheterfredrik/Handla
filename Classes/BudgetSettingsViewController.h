//
//  BudgetSettingsViewController.h
//  Handla
//
//  Created by Max Westermark on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum Date_Interval {
	WeekInterval,
	MonthInterval,
	YearInterval
} Date_Interval;


@interface BudgetSettingsViewController : UITableViewController {
	NSMutableArray *optionDateInterval;
	UITableViewCell *lastCheckedDateInterval;
	
	
}

@end
