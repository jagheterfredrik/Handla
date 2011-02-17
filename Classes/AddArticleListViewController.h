//
//  AddArticleListViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"


@interface AddArticleListViewController : CoreDataTableViewController {
	NSManagedObjectContext *managedObjectContext_;
}

- (id)initInManagedObjectContext:(NSManagedObjectContext*)managedObjectContext;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
