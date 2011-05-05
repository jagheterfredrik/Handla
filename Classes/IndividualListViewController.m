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

@implementation IndividualListViewController

- (void) imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    if (![reader isMemberOfClass:[ZBarReaderViewController class]]) {
        //we are choosing a new image from library, to assign to the clicked article.
        //TODO actually save it
        NSLog(@"image chosen");
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        //newPhoto = YES;
        //[photo setImage:image];
        reader.delegate = nil;
        [reader dismissModalViewControllerAnimated:YES];
        
        [self dismissModalViewControllerAnimated:YES];
        
        
    } else {
        
        
	id<NSFastEnumeration> results =
	[info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
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
        listArticle.price = listArticle.article.lastPrice;
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ingen vara funnen!" 
                                                        message:@"Den vara du skannade finns ej bland dina tidigare varor." 
                                                       delegate:self 
                                              cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
    }
    
	[reader dismissModalViewControllerAnimated: YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.title==@"lägg till bild för vara") {
        switch (buttonIndex) {
            case 0:
            {
                    //Take picture
                    // Create image picker controller
                    UIImagePickerController *imagePicker = [UIImagePickerSingleton sharedInstance];
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
                }
                break;
            case 1:
                //Choose existing picture
                {
                    UIImagePickerController *imagePicker = [UIImagePickerSingleton sharedInstance];
                    imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                    imagePicker.delegate = self;
                    imagePicker.allowsEditing = NO;
                    [self presentModalViewController:imagePicker animated:YES];
                }
            }
    }
    else{
        //barcode mode? i dont know
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
	
}



/**
 * returns the sum of the costs in the list
 */
- (NSDecimalNumber*)calculateSumOfElementsInList {
	NSDecimalNumber *amountBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
	for (ListArticle *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
        if (object.price!=nil){
            amountBalance = [amountBalance decimalNumberByAdding:object.price];
        }
	}
	return amountBalance;
}

/**
 * returns the sum of the checked articles' costs in the list
 */
- (NSDecimalNumber*)calculateSumOfCheckedElementsInList {
	NSDecimalNumber *amountBalance = [NSDecimalNumber decimalNumberWithString:@"0"];
	for (ListArticle *object in [individualListTableViewController.fetchedResultsController fetchedObjects])
	{
		if ([[object checked] boolValue] && object.price!=nil) {
			amountBalance = [amountBalance decimalNumberByAdding:object.price];
		}
		
	}
	
	return amountBalance;
}


- (void)addListArticle {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:list_.name
															 delegate:self
													cancelButtonTitle:@"Avbryt"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Skapa ny vara",@"Lägg till tidigare vara",@"Skanna in vara", nil];
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
 * When the user clicks the "avsluta köp" button, we see if all posts are checked off
 * and if they are we go to CheckoutViewController. else we show some alerts.
 */
- (IBAction)purchase {
    if([[self calculateSumOfCheckedElementsInList] intValue] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Inget att betala!" 
                                                        message:@"Det totala beloppet av markerade varor är noll!" 
                                                       delegate:self 
                                              cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
        return;
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
			[(UITabBarController*)self.tabBarController setSelectedIndex:2];
			[self.navigationController popViewControllerAnimated:NO];
			
		}else {
			//we are all done with the list
			CheckoutViewController* checkOut = [[CheckoutViewController alloc] initWithList:list_ 
																				amountToPay:[self calculateSumOfCheckedElementsInList]];
			[self.navigationController presentModalViewController:checkOut animated:YES];
			
			[checkOut release];
		}

        
    }
    else {        
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
        CheckoutViewController* checkOut = [[CheckoutViewController alloc] initWithList:list_ 
                                                                            amountToPay:[self calculateSumOfCheckedElementsInList]];
        [self.navigationController presentModalViewController:checkOut animated:YES];
        
        [checkOut release];
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


- (void)updatePriceFields {
    
   	progressLabel.text = [NSString stringWithFormat:@"%i / %i", self.checkedElementsCount,self.elementsCount];
    
    [progressBar setProgress:(float)(self.checkedElementsCount/(float)(self.elementsCount)) animated:YES];
	if ([self elementsCount] == 0)
	{
		checkoutButton.hidden = YES;
	}
	else if([self elementsCount] > 0)
	{
		checkoutButton.hidden = NO;
	}
    
    if ([self checkedElementsCount] == [self elementsCount]) {
        [UIView animateWithDuration:0.4f animations:^{            
          
            UIImage *image = [UIImage imageNamed:@"button_red.png"];
            
            float w = image.size.width / 2, h = image.size.height / 2;
            UIImage *stretch = [image stretchableImageWithLeftCapWidth:w topCapHeight:h];
            
            // Now we'll create a button as per usual
            [checkoutButton setBackgroundImage:stretch forState:UIControlStateNormal];

        
        }];
        
    }
    else{
        [UIView animateWithDuration:0.4f animations:^{
            UIImage *image = [UIImage imageNamed:@"button_green.png"];
            
            float w = image.size.width / 2, h = image.size.height / 2;
            UIImage *stretch = [image stretchableImageWithLeftCapWidth:w topCapHeight:h];
            
            // Now we'll create a button as per usual
            [checkoutButton setBackgroundImage:stretch forState:UIControlStateNormal];

        }];
    }
}


- (void)imagePressed:(NSNotification*)notification {
	ListArticle *article = (ListArticle*)[notification object];
	if (article.article.picture) {
        EGOPhotoViewController *viewer = [[EGOPhotoViewController alloc] initWithImage:[[PhotoUtil instance] readPhoto:article.article.picture]];
        
        [self.navigationController pushViewController:viewer animated:YES];
        [viewer release];
	}
    else {
        //ask to take a new photo
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"lägg till bild för vara" delegate:self cancelButtonTitle:@"avbryt" destructiveButtonTitle:nil otherButtonTitles:@"Ta ny bild med kamera", @"Välj befintlig bild", nil];
                                      
        [actionSheet showInView:[[self view] window]];
        [actionSheet release];
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[individualListTableViewController setList:list_];
    
    individualListTableViewController.navController = self.navigationController;
    
    //TODO: This is code to make the done button fancy, shold be replaced by a cool image
	[[checkoutButton layer] setCornerRadius:8.0f];
	[[checkoutButton layer] setMasksToBounds:YES];
	[[checkoutButton layer] setBorderWidth:1.0f];
	if ([self elementsCount] == 0)
	{
		checkoutButton.hidden = YES;
	}
    //end buttoncooling part
    
    progressBar.progress = (float)(self.checkedElementsCount)/(float)(self.elementsCount);
	[self updatePriceFields];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imagePressed:) name:@"ListCellImagePressed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePriceFields) name:@"ListArticleChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePriceFields) name:@"ListChanged" object:nil];

    // Load our image normally.
    UIImage *image = [UIImage imageNamed:@"button_green.png"];
    
    // And create the stretchy version.
    float w = image.size.width / 2, h = image.size.height / 2;
    UIImage *stretch = [image stretchableImageWithLeftCapWidth:w topCapHeight:h];
    
    // Now we'll create a button as per usual.
    checkoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkoutButton.frame = CGRectMake(178.0f, 2.0f, 130.0f, 45.0f);
    [checkoutButton setBackgroundImage:stretch forState:UIControlStateNormal];
    [checkoutButton setTitle:@"Avsluta köp" forState:UIControlStateNormal];
    [bottomBar addSubview:checkoutButton];
    
    //TODO: hook up ibaction
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
