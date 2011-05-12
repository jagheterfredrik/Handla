//
//  ListsViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "List.h"

#import "CMPopTipView.h"

#define CREATE_LIST 0
#define RENAME_LIST 1

@interface ListsViewController : CoreDataTableViewController<UIAlertViewDelegate, UIActionSheetDelegate, CMPopTipViewDelegate> {

@private
    NSManagedObjectContext *managedObjectContext_;
	
	List *list_;
	NSInteger listSortOrder;
    CMPopTipView *myPopTipView;
}

- (void)createList;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) List *list;
@property (nonatomic, retain) CMPopTipView *myPopTipView;

@end
