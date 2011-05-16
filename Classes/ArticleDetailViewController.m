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

#import "DSActivityView.h"

@implementation ArticleDetailViewController

@synthesize barcode;

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

- (void)doClose {
    [self.navigationController popViewControllerAnimated:YES];
    [DSBezelActivityView removeViewAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ArticleChanged" object:nil];
}

- (void)showProgress {
    [DSBezelActivityView newActivityViewForView:[[self view] window] withLabel:@"Sparar..."];
}

/*
 * Saves the PICTURE to the database.
 */
- (void)doSave {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (article_.picture)
        [[PhotoUtil instance] deletePhoto:article_.picture];
    if (photo.image) {
        article_.picture = [[PhotoUtil instance] savePhoto:photo.image];
    } else {
        [[PhotoUtil instance] deletePhoto:article_.picture];
        article_.picture = nil;
    }
    
    [self performSelectorOnMainThread:@selector(doClose) withObject:nil waitUntilDone:NO];
    [pool release];
}

/*
 * Saves the article iff the done-button was clicked.
 */
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
    
    //Check if we are editing an article, if not create it
	if (article_ == nil) {
		article_ = [NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:managedObjectContext_];
	}
	
	//See if we're supposed to add the article to a list
	if (list_ != nil) {
		ListArticle *listArticle = [NSEntityDescription insertNewObjectForEntityForName:@"ListArticle" inManagedObjectContext:managedObjectContext_];
		listArticle.list = list_;
		listArticle.article = article_;
        listArticle.amount = [NSDecimalNumber decimalNumberWithString:@"1"];
        listArticle.weightUnit = article_.lastWeightUnit;
        listArticle.price = article_.lastPrice;
	}
	
	article_.name = nameField.text;
	article_.comment = commentField.text;
    article_.barcode = self.barcode;
	
	list_.lastUsed = [NSDate date];
    
    if (newPhoto) {
        [self showProgress];
        [self performSelectorInBackground:@selector(doSave) withObject:nil];
    } else {
        [self doClose];
    }
}

- (void) imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    if ([reader isMemberOfClass:[ZBarReaderViewController class]]) {
        id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        
        barCodeCheckBox.hidden=NO;
        [reader dismissModalViewControllerAnimated: YES];
        self.barcode = symbol.data;
        
    } else {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        newPhoto = YES;
        [photo setImage:image];
        reader.delegate = nil;
        [reader dismissModalViewControllerAnimated:YES];
    }
}

/*
 * Allows the user to add barcode to the article.
 */
- (IBAction)scanClick:(id)sender {
	barcodeReader = [ZBarReaderViewController new];
    barcodeReader.readerDelegate = self;
	
    ZBarImageScanner *scanner = barcodeReader.scanner;
    // disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
				   config: ZBAR_CFG_ENABLE
					   to: 0];
	
    // present and release the controller
    [self presentModalViewController: barcodeReader
							animated: YES];
    [barcodeReader release];
}

/*
 * Allows the user to take a new picture, choose an existing one or remove the one
 * currently assigned to the article.
 */
- (IBAction)cameraClick:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
													cancelButtonTitle:@"Avbryt"
											   destructiveButtonTitle:@"Ta bort"
													otherButtonTitles:@"Ta ny bild med kamera", @"Välj befintlig bild", nil];
    
	[actionSheet showInView:[[self view] window]];
	[actionSheet release];
}

#pragma mark -
#pragma Text field delegate

- (BOOL)textField:(UITextField *)textField_ shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField_.text length] + [string length] - range.length;
    return (newLength > 30) ? NO : YES;
}

#pragma mark -
#pragma Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            //Ta bort bild
            if (article_.picture) {
                photo.image = nil;
                newPhoto = YES;
            }
            break;
        case 1:
        {
            //Take picture
            // Create image picker controller
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ingen kamera tillgänglig" message:@"Funktionen kräver att din enhet har en kamera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                break;
            }
            imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            [self presentModalViewController:imagePicker animated:YES];
            [imagePicker release];
        }
            break;
        case 2:
            //Choose existing picture
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            [self presentModalViewController:imagePicker animated:YES];
            [imagePicker release];
        }
            break;
        default:
            break;
    }
}

- (void)setBarcode:(NSString *)barcode_ {
    [barcode release];
    barcode = [barcode_ retain];
    barCodeCheckBox.hidden = (barcode_ == nil);
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
		rightButton.title = @"Spara";
		self.title = article_.name;
		nameField.text = article_.name;
        self.barcode = article_.barcode;
		commentField.text = article_.comment;
		if (article_.picture)
			photo.image = [[PhotoUtil instance] readThumbnail:article_.picture];
	} else {
		rightButton.title = @"Lägg till";
		self.title = @"Ny vara";
	}

	self.navigationItem.rightBarButtonItem = rightButton;
	[rightButton release];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doClose)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [leftButton release];
    
	[nameField becomeFirstResponder];
    nameField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [super viewDidUnload];
}


- (void)dealloc {
    [photo release];
    [super dealloc];
}


@end
