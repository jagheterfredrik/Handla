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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil listArticle:(ListArticle*)listArticle {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    listArticle_ = listArticle;
    article_ = listArticle_.article;
    managedObjectContext_ = article_.managedObjectContext;
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

- (void)updateLabels {
  if (listArticle_ != nil) {
    return;
  }
  if (weightUnitSwitch.selectedSegmentIndex == 0) {
    priceField.placeholder = @"Styckpris";
    amountField.placeholder = @"Antal";
  } else {
    priceField.placeholder = @"Kilopris";
    amountField.placeholder = @"Vikt (kg)";
  }
}

- (void)handlePrice {
  NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
  [f setGeneratesDecimalNumbers:YES];
  [f setNumberStyle:NSNumberFormatterDecimalStyle];
  
  if ([priceField.text length] != 0) {
    listArticle_.price = (NSDecimalNumber*)[f numberFromString:priceField.text];
    listArticle_.article.lastPrice = listArticle_.price;
  }
  
  listArticle_.article.lastWeightUnit = listArticle_.weightUnit = [NSNumber numberWithBool:(weightUnitSwitch.selectedSegmentIndex == 1)];
  
  if ([amountField.text length] != 0) {
    NSDecimalNumber *amount = (NSDecimalNumber*)[f numberFromString:amountField.text];
    if (!listArticle_.weightUnit) {
      NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSNumberFormatterRoundFloor scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
      amount = [amount decimalNumberByRoundingAccordingToBehavior:behavior];
    }
    
    listArticle_.amount = (amount ? amount : [NSDecimalNumber one]);
  } else {
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSNumberFormatterRoundFloor scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *amount = [(NSDecimalNumber*)[f numberFromString:amountField.placeholder]decimalNumberByRoundingAccordingToBehavior:behavior];
    
    listArticle_.amount = (amount ? amount : [NSDecimalNumber one]);
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"listArticleChanged" object:nil];
  [f release];
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
		listArticle_ = [NSEntityDescription insertNewObjectForEntityForName:@"ListArticle" inManagedObjectContext:managedObjectContext_];
    listArticle_.list = list_;
    listArticle_.article = article_;
	}
  
  if (listArticle_ != nil) {
    [self handlePrice];
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

- (void)viewWillAppear:(BOOL)animated {
  self.edgesForExtendedLayout = UIRectEdgeNone;
  
  [weightUnitSwitch addTarget:self action:@selector(updateLabels) forControlEvents:UIControlEventValueChanged];
  
  weightUnitSwitch.selectedSegmentIndex = [listArticle_.weightUnit boolValue] ? 1 : 0;
  
  [self updateLabels];
  
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  
  if (listArticle_.price != nil) {
    priceField.placeholder = [formatter stringFromNumber:listArticle_.price];
  }
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  if (listArticle_.amount != nil) {
    amountField.placeholder = [formatter stringFromNumber:listArticle_.amount];
  }
  [formatter release];
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

    [self updateLabels];
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
