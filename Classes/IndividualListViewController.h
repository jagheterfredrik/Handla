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

@interface IndividualListViewController : CoreDataTableViewController<UIAlertViewDelegate> {
	List* list_;
}

- (id)initWithList:(List*)list;

@end
