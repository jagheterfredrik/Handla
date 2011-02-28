//
//  BudgetSettingsViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum Date_Interval {
	WeekInterval,
	MonthInterval,
	YearInterval
} Date_Interval;

@interface BudgetSettingsViewController : UIViewController {
	
	IBOutlet UISegmentedControl* dateInterval;

}

@end
