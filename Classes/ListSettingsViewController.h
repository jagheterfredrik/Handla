//
//  ListSettingsViewController.h
//  Handla
//
//  Created by Max Westermark on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListSettingsViewController : UITableViewController {
	NSMutableArray *optionSortOrder;
	UITableViewCell *lastCheckedSortOrder;	
	UISwitch *checkoutSwitch;


}

@property (nonatomic, retain) UISwitch *checkoutSwitch;

-(void) checkoutSwitchChanged;

@end
