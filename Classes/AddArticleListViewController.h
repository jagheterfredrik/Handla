//
//  AddArticleListViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "List.h"


@interface AddArticleListViewController : CoreDataTableViewController {
	List *list_;
}

- (id)initWithList:(List*)list;

@end
