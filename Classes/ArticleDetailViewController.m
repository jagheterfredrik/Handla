//
//  ArticleDetailViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-22.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "ArticleDetailViewController.h"
#import "Article.h"
#import "PhotoUtil.h"

@implementation ArticleDetailViewController

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil list:(List*)list {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        list_ = list;
		managedObjectContext_ = list_.managedObjectContext;
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
		[actionSheet release];
		return;
	}
	
	//Check if we are editing a article, if not create it
	if (article_ == nil) {
		article_ = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:managedObjectContext_];
	}
	
	//See if we're supposed to add the article to a list
	if (list_ != nil) {
		ListArticle *listArticle = [NSEntityDescription insertNewObjectForEntityForName:@"ListArticle" inManagedObjectContext:managedObjectContext_];
		listArticle.list = list_;
		listArticle.article = article_;
        listArticle.price = nil;
	}
	
	article_.name = nameField.text;
	article_.barcode = scanField.text;
	article_.comment = commentField.text;
	if (newPhoto) {
		if (article_.picture)
			[[PhotoUtil instance] deletePhoto:article_.picture];
		article_.picture = [[PhotoUtil instance] savePhoto:photo.image];
	}
	list_.lastUsed = [NSDate date];

	[managedObjectContext_ save:NULL];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ArticleChanged" object:self];
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
	id<NSFastEnumeration> results =
	[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
	
    // EXAMPLE: do something useful with the barcode data
    scanField.text = symbol.data;
	[reader dismissModalViewControllerAnimated: YES];
}

- (IBAction)scanClick:(id)sender {
	ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
	
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
	
    // disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
				   config: ZBAR_CFG_ENABLE
					   to: 0];
	
    // present and release the controller
    [self presentModalViewController: reader
							animated: YES];
    [reader release];
}

- (IBAction)cameraClick:(id)sender {
    if (!photoChooser) {
        photoChooser = [[PhotoChooserViewController alloc] initWithImage:article_.picture canChange:YES];
    }
	photoChooser.delegate = self;
	[self presentModalViewController:photoChooser animated:YES];
}

- (void)photoChooserDone:(PhotoChooserViewController *)photoChooser_ {
	[self dismissModalViewControllerAnimated:YES];
	if (photoChooser_.newImage) {
		newPhoto = YES;
		photo.image = photoChooser_.image;
	}
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
		self.title = article_.name;
		nameField.text = article_.name;
		scanField.text = article_.barcode;
		commentField.text = article_.comment;
		if (article_.picture)
			photo.image = [[PhotoUtil instance] readThumbnail:article_.picture];
	} else {
		rightButton.title = @"Lägg till";
		self.title = @"Ny vara";
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
    [photoChooser release];
    [super dealloc];
}


@end
