//
//  IndividualListViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@class List;

@interface IndividualListTableViewController : CoreDataTableViewController<UIAlertViewDelegate> {
	List *list_;
	NSInteger selectedIndex;
	NSManagedObject * selectedManagedObject;
	
	//Receives the cell created by tableView:cellForManagedObject: and then is set to nil
	IBOutlet UITableViewCell *cellReceiver;
}

- (void)setList:(List*)list;

- (void)imageTouched:(id)source;
- (IBAction)changePriceButtonPressed:(UIButton*) sender;

@property (nonatomic,retain) List *list_;
@property (nonatomic,assign) IBOutlet UITableViewCell *cellReceiver;

@end
