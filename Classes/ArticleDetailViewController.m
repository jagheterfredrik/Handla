//
//  ArticleDetailViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-22.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "ArticleDetailViewController.h"
#import "Article.h"

@implementation ArticleDetailViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		managedObjectContext_ = managedObjectContext;
    }
    return self;	
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil article:(Article*)article {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        article_ = article;
		managedObjectContext_ = article_.managedObjectContext;
    }
    return self;
}

- (void)doneClick {
	if ([nameField.text length] == 0) {
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Du måste ange ett namn för varan"
															delegate:nil
															cancelButtonTitle:@"OK"
															destructiveButtonTitle:nil
															otherButtonTitles:nil];
		[actionSheet showInView:[[self view] window]];
	}
	if (article_ == nil) {
		Article *article = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:managedObjectContext_];
		article.name = nameField.text;
	} else {
		article_.name = nameField.text;
	}

	[managedObjectContext_ save:NULL];
	[self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	photoButton.titleLabel.textAlignment = UITextAlignmentCenter;
	
	if (article_ != nil) {
		nameField.text = article_.name;
	}
	
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(doneClick)];
	if (article_ != nil) {
		rightButton.title = @"Ändra";
	} else {
		rightButton.title = @"Skapa";
	}

	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
	
	[nameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
