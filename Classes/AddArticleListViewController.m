//
//  AddArticleListViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "AddArticleListViewController.h"
#import "ArticleDetailViewController.h"
#import "PhotoUtil.h"

#import "HandlaAppDelegate.h"

//Hack to get first letters from database entries
@interface NSManagedObject (FirstLetter)
- (NSString *)uppercaseFirstLetterOfName;
@end

@implementation NSManagedObject (FirstLetter)
- (NSString *)uppercaseFirstLetterOfName {
    [self willAccessValueForKey:@"uppercaseFirstLetterOfName"];
    NSString *aString = [[self valueForKey:@"name"] uppercaseString];
    
    // support UTF-16:
    NSString *stringToReturn = [aString substringWithRange:[aString rangeOfComposedCharacterSequenceAtIndex:0]];
    
    // OR no UTF-16 support:
    //NSString *stringToReturn = [aString substringToIndex:1];
    
    [self didAccessValueForKey:@"uppercaseFirstLetterOfName"];
    return stringToReturn;
}
@end





@implementation AddArticleListViewController

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


- (id)initWithList:(List*)list {
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		list_ = list;
		list.lastUsed = [NSDate	date];
	}
	return self;
}


#pragma mark -
#pragma mark Events

/*
 * Handles clicks from the add-button and allows the user to create a new article.
 */
- (void)addArticle {
	ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:nil managedObjectContext:context_];
	[self.navigationController pushViewController:articleDetailViewController animated:YES];
	[articleDetailViewController release];
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addArticle)];
    self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	
	//Setup the data source.
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    context_ = [(HandlaAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
	request.entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:context_];
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name"
																					 ascending:YES
																					  selector:@selector(localizedCaseInsensitiveCompare:)]];
	request.predicate = nil;
	request.fetchBatchSize = 20;
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
									   initWithFetchRequest:request
									   managedObjectContext:context_
									   sectionNameKeyPath:@"uppercaseFirstLetterOfName"
									   cacheName:nil];
	frc.delegate = self;
	
	[request release];
	
	[self setFetchedResultsController:frc];
	[frc release];
	
	self.titleKey = @"name";
	self.searchKey = @"name";
	
	// Set window title.
    if (list_) {
        self.title = @"Lägg till vara";
    } else {
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        self.title = @"Tidigare varor";
    }
    
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark Events

/*
 * Called if the user confirms the removal in the alert view. The alert view
 * is only showed if the user is trying to remove an item that is included in
 * any list. All list-items belonging to the article is then also removed.
 */
- (void)performRemoval {
	for (id object in selectedArticle.listArticles)
		[context_ deleteObject:object];
	[context_ deleteObject:selectedArticle];
	[[PhotoUtil instance] deletePhoto:selectedArticle.picture];
	selectedArticle = nil;
}

#pragma mark -
#pragma mark Core data table view controller overrides

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0f;
}
  

 - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
     NSArray* sections = self.fetchedResultsController.sections;
     
     if ([title isEqualToString:@"#"] || [sections count]==1) {
         //symbols at the top. this is hardcoded.
         return 0;
     }
     if (index == 0) {
         [tableView setContentOffset:CGPointZero animated:NO];
         return NSNotFound;
     }
     
     for (NSInteger i = 0; i<[sections count]; i++) {
         id <NSFetchedResultsSectionInfo> thisSection = [sections objectAtIndex:i];
         
         if ([title localizedCaseInsensitiveCompare:thisSection.name]==NSOrderedSame) {
             return i;
         }
         if ([title localizedCaseInsensitiveCompare:thisSection.name]==NSOrderedAscending) {
             return i-1;
         }
     }
     //TODO: no sections maybe fucks up this piece of code? test that
     return 0; //we should not get here,but this supresses warnings.
 } 



- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (super.searchDisplayController.active){
        return nil;
    } else {
        return [NSArray arrayWithArray:
                                 [@"{search}|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|Å|Ä|Ö"
                                  componentsSeparatedByString:@"|"]];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)managedObjectAccessoryTapped:(NSManagedObject *)managedObject {
	selectedArticle = (Article *) managedObject;
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:selectedArticle.name
															 delegate:self
													cancelButtonTitle:@"Avbryt"
											   destructiveButtonTitle:@"Ta bort"
													otherButtonTitles:@"Redigera",nil];
	[actionSheet showInView:[[self view] window]];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0) {
		[self deleteManagedObject:selectedArticle];
	}
	else if (buttonIndex == 1)
	{
		ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:nil article:(Article*)selectedArticle];
		[self.navigationController pushViewController:articleDetailViewController animated:YES];
		[articleDetailViewController release];
	}
	
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    if (list_) {
        ListArticle *listArticle = [NSEntityDescription insertNewObjectForEntityForName:@"ListArticle" inManagedObjectContext:list_.managedObjectContext];
        listArticle.list = list_;
        listArticle.article = (Article*)managedObject;
        listArticle.amount = [NSDecimalNumber decimalNumberWithString:@"1"];
        listArticle.weightUnit = listArticle.article.lastWeightUnit;
        listArticle.price = listArticle.article.lastPrice;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:nil article:(Article*)managedObject];
		[self.navigationController pushViewController:articleDetailViewController animated:YES];
		[articleDetailViewController release];   
    }
}

- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject {
    return [[PhotoUtil instance] readThumbnail:((Article*)managedObject).picture];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
    if(list_)
        return UITableViewCellAccessoryDetailDisclosureButton;
    else
        return UITableViewCellAccessoryDisclosureIndicator;
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
	selectedArticle = (Article*)managedObject;
	NSUInteger listArticleCount = [selectedArticle.listArticles count];
	if (listArticleCount > 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bekräfta borttagning" 
												message:[NSString stringWithFormat:@"Varan du vill ta bort finns redan i %i listor, tar du bort denna vara kommer den tas bort från de listorna.", listArticleCount]
												delegate:self
												cancelButtonTitle:@"Avbryt"
												  otherButtonTitles:@"Ta bort", nil];
		[alertView show];
		[alertView release];
		return;
	}
	[self performRemoval];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.navigationItem.rightBarButtonItem.enabled = !editing;
    [super setEditing:editing animated:animated];
}

#pragma mark -
#pragma mark Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self performRemoval];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

