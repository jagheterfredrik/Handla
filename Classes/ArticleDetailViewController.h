//
//  ArticleDetailViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-22.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import "ListArticle.h"

@interface ArticleDetailViewController : UIViewController {
	Article *article_;
	NSManagedObjectContext *managedObjectContext_;
	IBOutlet UIButton *photoButton;
	IBOutlet UITextField *nameField;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil article:(Article*)article;

@end
