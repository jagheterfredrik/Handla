//
//  TestViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "IndividualListViewController.h"
#import "Article.h"
#import "ListArticle.h"
#import "BudgetViewController.h"
#import "AddArticleListViewController.h"
#import "ArticleDetailViewController.h"
#import "CheckoutViewController.h"
#import "IndividualListTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PhotoUtil.h"
#import "EGOPhotoGlobal.h"

#import "PhotoHandler.h"

#import "UIAlertView+Blocks.h"
#import "UIActionSheet+Blocks.h"

#define SCAN_TO_ADD 1
#define SCAN_TO_CHECK 2

@implementation IndividualListViewController

@synthesize myPopTipView;

- (void) imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
	id<NSFastEnumeration> results =
	[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    if (reader.view.tag == SCAN_TO_ADD) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:list_.managedObjectContext]; 
        
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease]; 
        
        [request setEntity:entityDescription]; 
        
        [request setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"barcode == '%@'", symbol.data]]];
        
        NSError *error = nil; 
        NSArray *array = [list_.managedObjectContext executeFetchRequest:request error:&error];
        
        if ([array count]>0) {
            ListArticle *listArticle = [NSEntityDescription insertNewObjectForEntityForName:@"ListArticle" inManagedObjectContext:list_.managedObjectContext];
            listArticle.list = list_;
            listArticle.article = (Article*)[array lastObject];
            listArticle.amount = [NSDecimalNumber one];
            listArticle.weightUnit = listArticle.article.lastWeightUnit;
            listArticle.price = listArticle.article.lastPrice;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ingen vara funnen!" 
                                                            message:@"Den vara du skannade har ingen vara kopplad till sig. Du måste koppla varan till sin steckkod först." 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    } else if (reader.view.tag == SCAN_TO_CHECK) {
        BOOL found = NO;
        NSArray *myArray = [list_.articles allObjects];
        for(ListArticle *object in myArray) {
            if ([object.article.barcode isEqualToString:symbol.data]) {
                object.checked = [NSNumber numberWithBool:YES];
                found = YES;
            }
        }
        
        if (!found) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ingen vara funnen!" 
                                                            message:@"Den vara du skannade har ingen vara kopplad till sig. Du måste koppla varan till sin steckkod först." 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    
	[reader dismissModalViewControllerAnimated: YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
		{
			ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:nil list:list_];
			[self.navigationController pushViewController:articleDetailViewController animated:YES];
			[articleDetailViewController release];
			break;
		}
		case 1:
		{
			
			AddArticleListViewController *addArticleListViewController = [[AddArticleListViewController alloc] initWithList:list_];
			[self.navigationController pushViewController:addArticleListViewController animated:YES];
			[addArticleListViewController release];
			break;
		}
        case 2:
		{
			
            ZBarReaderViewController *reader = [ZBarReaderViewController new];
            reader.readerDelegate = self;
            
            ZBarImageScanner *scanner = reader.scanner;
            
            reader.view.tag = SCAN_TO_ADD;
            
            // disable rarely used I2/5 to improve performance
            [scanner setSymbology: ZBAR_I25
                           config: ZBAR_CFG_ENABLE
                               to: 0];
            
            // present and release the controller
            [self presentModalViewController: reader
                                    animated: YES];
            [reader release];
			break;
		}
		default:
			break;
	}
	
}

- (void)dismissPopTipView {
    [self.myPopTipView dismissAnimated:NO];
    self.myPopTipView = nil;
}

- (void)showPopTipView {
    NSString *message = @"Klicka här för att lägga till varor";
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithMessage:message];
    [self dismissPopTipView];
    popTipView.backgroundColor = [UIColor blackColor];
    popTipView.delegate = self;
    [popTipView presentPointingAtView:bubblePlaceholder inView:self.view.window animated:YES];
    self.myPopTipView = popTipView;
    [popTipView release];
}



#pragma mark CMPopTipViewDelegate methods
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    // User can tap CMPopTipView to dismiss it
    self.myPopTipView = nil;
    [self addListArticle];
}

/**
 * Returns the sum of the costs in the list
 */
- (NSDecimalNumber*)calculateSumOfElementsInList {
	NSDecimalNumber *amountBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
	for (ListArticle *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
        if (object.price!=nil){
            amountBalance = [amountBalance decimalNumberByAdding:[object.price decimalNumberByMultiplyingBy:object.amount]];
        }
	}
	return amountBalance;
}

/**
 * Returns the sum of the checked articles costs in the list
 */
- (NSDecimalNumber*)calculateSumOfCheckedElementsInList {
	NSDecimalNumber *amountBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
	for (ListArticle *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
		if ([[object checked] boolValue] && object.price!=nil) {
			amountBalance = [amountBalance decimalNumberByAdding:[object.price decimalNumberByMultiplyingBy:object.amount]];
		}
		
	}
	
	return amountBalance;
}

/*
 * Asks the user if s/he wants to create a new list, select a previous item
 * or scan in an item.
 */
- (void)addListArticle {
    RIButtonItem *cancel = [RIButtonItem itemWithLabel:@"Avbryt"];
    cancel.action = ^
    {
        if([self elementsCount]==0) {
            [self showPopTipView];
        }
    };
    
    RIButtonItem *create = [RIButtonItem itemWithLabel:@"Skapa ny vara"];
    create.action = ^
    {
        ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:nil list:list_];
        [self.navigationController pushViewController:articleDetailViewController animated:YES];
        [articleDetailViewController release];
    };
    
    RIButtonItem *existing = [RIButtonItem itemWithLabel:@"Lägg till tidigare vara"];
    existing.action = ^
    {
        AddArticleListViewController *addArticleListViewController = [[AddArticleListViewController alloc] initWithList:list_];
        [self.navigationController pushViewController:addArticleListViewController animated:YES];
        [addArticleListViewController release];
    };
    
    RIButtonItem *scan = [RIButtonItem itemWithLabel:@"Skanna in vara"];
    scan.action = ^
    {
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        
        ZBarImageScanner *scanner = reader.scanner;
        
        reader.view.tag = SCAN_TO_ADD;
        
        // disable rarely used I2/5 to improve performance
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
        // present and release the controller
        [self presentModalViewController: reader
                                animated: YES];
        [reader release];
    };
    
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:list_.name cancelButtonItem:cancel destructiveButtonItem:nil otherButtonItems:create, existing, scan, nil];
	[actionSheet showInView:[[self view] window]];
	[actionSheet release];
    
    
    
    
    
}

/**
 * Returns the number of elements in the list. Both checked or unchecked.
 */
- (NSInteger)elementsCount
{
    return [[individualListTableViewController.fetchedResultsController fetchedObjects] count];
}

/**
 * Returns the number of checked elements in the list.
 */
- (NSInteger)checkedElementsCount
{
    NSInteger count = 0;
	for (ListArticle *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
		if ([[object checked] boolValue]) {
			++count;
		}
		
	}	
	return count;    
}

/**
 *  When the user clicks the scan-button a barcode scan should commence and
 *  when a barcode is found it should be cross-refernced and checked-off
 *  the list.
 */
- (IBAction)scanListArticle {
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    reader.view.tag = SCAN_TO_CHECK;
    
    // disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader
                            animated: YES];
    [reader release];
}

/*
 * Handles the click of the purchase-done button. Checks if the user has checked
 * all items, wanrs if not, and then shows the checkout-view (if the user has the
 * setting turned on).
 */
- (void)purchaseDone
{
	//if checkout view is off, add new budget post and change view to budget, else goto checkoutview
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults boolForKey:@"listCheckoutViewOn"]) {
		BudgetPost* newBudgetPost = [NSEntityDescription insertNewObjectForEntityForName:@"BudgetPost" inManagedObjectContext:list_.managedObjectContext];
		newBudgetPost.name = list_.name;
		newBudgetPost.timeStamp = [NSDate date];
		//TODO: this should be rounded if we pay with cash; since there are no femtioörings anymore
		NSDecimalNumber *amount = [self calculateSumOfCheckedElementsInList];
		amount = [amount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
		newBudgetPost.amount = amount;
		//TODO: add comment!
		//[NSString stringWithFormat:@"Automatiskt sparat inköp %s", [[NSDate date] description]];
		
		
		NSArray *myArray = [list_.articles allObjects];
		for(ListArticle *object in myArray) {
			[object setChecked:[NSNumber numberWithBool:NO]];
		}
		
		[list_.managedObjectContext save:NULL];
		
		//go to budget mode
		[(UITabBarController*)self.tabBarController setSelectedIndex:1];
		[self.navigationController popViewControllerAnimated:NO];
		
	}else {
		//we are all done with the list
		CheckoutViewController* checkOut = [[CheckoutViewController alloc] initWithList:list_ 
																			amountToPay:[self calculateSumOfCheckedElementsInList]];
		[self.navigationController presentModalViewController:checkOut animated:YES];
		
		[checkOut release];
	}
}

/**
 * When the user clicks the "avsluta köp" button, we see if all posts are checked off
 * and if they are we go to CheckoutViewController. else we show some alerts.
 */
- (IBAction)purchase {
    if([[self calculateSumOfCheckedElementsInList] doubleValue] == 0) {
        if ([self checkedElementsCount] > 0) {
            RIButtonItem *uncheck = [RIButtonItem itemWithLabel:@"Avmarkera"];
            uncheck.action = ^
            {
                for (ListArticle *la in list_.articles)
                    la.checked = [NSNumber numberWithBool:NO];
            };
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beloppet är noll"
                                                            message:@"Summan av de markerade varorna är noll. Vill du avmarkera samtliga varor i listan?"
                                                   cancelButtonItem:[RIButtonItem itemWithLabel:@"Nej"] otherButtonItems:uncheck, nil];
            [alert show];
            [alert release];
            return;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Inget att betala!" 
                                                            message:@"Inga varor är markerade!" 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
    }
    
    //look for checked articles with no price set
    for (ListArticle *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
		if ([[object checked] boolValue] && object.price==nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Det finns avbockade varor utan pris angivet!" 
                                                            message:@"Vill du ändå avsluta köpet?" 
                                                           delegate:self 
                                                  cancelButtonTitle:@"Tillbaka"
                                                  otherButtonTitles:@"Ja", nil];
            [alert show];
            [alert release];
            return;
		}
		
	}
    
    if ([self elementsCount] == [self checkedElementsCount]) {
		
		[self purchaseDone];

        
    }else {        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Du har inte checkat av alla varor!" 
                                                        message:@"Vill du ändå avsluta köpet?" 
                                                       delegate:self 
                                              cancelButtonTitle:@"Tillbaka"
											  otherButtonTitles:@"Ja", nil];
		[alert show];
		[alert release];
    }
    
}

/**
 * Called when an alertViews is dismissed using any of the buttons.
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        //clicked "ja"
		
        [self purchaseDone];
		
		/*
        CheckoutViewController* checkOut = [[CheckoutViewController alloc] initWithList:list_ 
                                                                            amountToPay:[self calculateSumOfCheckedElementsInList]];
        [self.navigationController presentModalViewController:checkOut animated:YES];
        
        [checkOut release];
		 */
	}
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil list:(List*)list {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization	
		UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addListArticle)];
		self.navigationItem.rightBarButtonItem = addButton;
		[addButton release];
		
		list_ = [list retain];
		
		self.title = list_.name;
    }
    return self;
}

/*
 * Updates all the price fields. Called when a listarticle's price is changed.
 */
- (void)updatePriceFields {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSDecimalNumber *total = [self calculateSumOfCheckedElementsInList];
    progressLabel.text = [formatter stringFromNumber:total];
    if (latestTotal && [total compare:latestTotal] == NSOrderedDescending) {
        //progressLabel.textColor = [UIColor redColor];
        //Show minus
        symbolView.image = plusSign;
        symbolView.alpha = 1.0f;
        [UIView animateWithDuration:0.8f
                              delay:0.f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             symbolView.alpha = 0.f;
                         } completion:nil];
    } else if(latestTotal && [total compare:latestTotal] == NSOrderedAscending) {
        symbolView.image = minusSign;
        symbolView.alpha = 1.0f;
        [UIView animateWithDuration:0.8f
                              delay:0.f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             symbolView.alpha = 0.f;
                         } completion:nil];
    }
    [latestTotal release];
    latestTotal = [total retain];
    [formatter release];
    
//    [progressBar setProgress:(float)(self.checkedElementsCount/(float)(self.elementsCount)) animated:YES];
	if ([self elementsCount] == 0)
	{
		checkoutButton.hidden = YES;
        [self showPopTipView];
	}
	else if([self elementsCount] > 0)
	{
		checkoutButton.hidden = NO;
	}
    
    if ([self checkedElementsCount] == [self elementsCount]) {
        // Load our image normally.
        UIImage *image = [UIImage imageNamed:@"GreenButton.png"];
        
        // And create the stretchy version.
        float w = image.size.width / 2, h = image.size.height / 2;
        UIImage *stretch = [image stretchableImageWithLeftCapWidth:w topCapHeight:h];
        
        // Now we'll create a button as per usual.
        [checkoutButton setBackgroundImage:stretch forState:UIControlStateNormal];
        
        [checkoutButton addTarget:self action:@selector(purchase) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else{
        // Load our image normally.
        UIImage *image = [UIImage imageNamed:@"RedButton.png"];
        
        // And create the stretchy version.
        float w = image.size.width / 2, h = image.size.height / 2;
        UIImage *stretch = [image stretchableImageWithLeftCapWidth:w topCapHeight:h];
        
        // Now we'll create a button as per usual.
        [checkoutButton setBackgroundImage:stretch forState:UIControlStateNormal];
        
        [checkoutButton addTarget:self action:@selector(purchase) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([self elementsCount] == 0)
	{
		checkoutButton.hidden = YES;
        [self showPopTipView];
	}
	else if([self elementsCount] > 0)
	{
		checkoutButton.hidden = NO;
	}
}


/*
 * Called when an thumbnail image in the list is pressed. If the pressed image was
 * the has-no-image image the user is asked if it wants to take a new picture or
 * choose an existing.
 */
- (void)imagePressed:(NSNotification*)notification {
	ListArticle *article = (ListArticle*)[notification object];
	if (article.article.picture) {
        EGOPhotoViewController *viewer = [[EGOPhotoViewController alloc] initWithImage:[[PhotoUtil instance] readPhoto:article.article.picture]];
        
        [self.navigationController pushViewController:viewer animated:YES];
        [viewer release];
	} else {
        PhotoHandler *handler = [[PhotoHandler alloc] initWithViewController:self article:article.article];
        [handler showAlternatives];
        [handler release];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    individualListTableViewController.navController = self.navigationController;
    [individualListTableViewController setList:list_];

    
    //end buttoncooling part
    
	//progressBar.progress = (float)(self.checkedElementsCount)/(float)(self.elementsCount);
	[self updatePriceFields];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imagePressed:) name:@"ListCellImagePressed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePriceFields) name:@"ListArticleChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePriceFields) name:@"ListChanged" object:nil];
    
    minusSign = [[UIImage imageNamed:@"MinusSign"] retain];
    plusSign = [[UIImage imageNamed:@"PlusSign"] retain];
}

- (void)viewDidAppear:(BOOL)animated {
    if([self elementsCount]==0) {
        [self showPopTipView];
    }
    [individualListTableViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self dismissPopTipView];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[individualListTableViewController release];
    [list_ release];
    [super dealloc];
}


@end
