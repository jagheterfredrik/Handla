//
//  IndividualListTableViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "IndividualListTableViewCell.h"
#import "CMPopTipView.h"

@class List;

@interface IndividualListTableViewController : CoreDataTableViewController<UIAlertViewDelegate> {
	List *list_;
	NSManagedObject * selectedManagedObject;
}

- (void)setList:(List*)list;

@property (nonatomic,retain) List *list_;
@property (nonatomic,retain) UINavigationController *navController;

@end
