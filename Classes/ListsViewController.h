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

@interface ListsViewController : CoreDataTableViewController<UIAlertViewDelegate, UIActionSheetDelegate> {

@private
    NSManagedObjectContext *managedObjectContext_;
	
	List *list_;
	BOOL showHelp;
	List *selectedList;
	NSInteger listSortOrder;
}

- (void)createList;


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) List *list;

@end
