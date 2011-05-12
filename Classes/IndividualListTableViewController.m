//
//  IndividualListTableViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "IndividualListTableViewController.h"
#import "List.h"
#import "ListArticle.h"
#import "Article.h"
#import "AddArticleListViewController.h"
#import "ArticleDetailViewController.h"

#import "UIActionSheet+Blocks.h"
#import "PriceAlertView.h"

@implementation IndividualListTableViewController

@synthesize list_, navController;

#pragma mark -
#pragma mark Core data table view controller overrides

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults boolForKey:@"individualListSectioning"]) {
		return nil;
	} else if ([[super tableView:tableView titleForHeaderInSection:section] isEqualToString:@"0"]) {
        return @"Varor att hämta";
    } else {
        return @"Hämtade varor";
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [super controllerDidChangeContent:controller];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ListChanged" object:self];
}

- (CGFloat)tableView:(UITableView *)table heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 57.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"IndividualListCell";
	
	ListArticle *article = (ListArticle*) [self tableView:tableView managedObjectForIndexPath:indexPath];

	IndividualListTableViewCell *cell = (IndividualListTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (cell == nil) {
		cell = [[[IndividualListTableViewCell alloc] init] autorelease];
		cell.autoresizesSubviews = NO;
		cell.clipsToBounds = YES;
	}
	cell.listArticle = article;
	
	return cell;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    IndividualListTableViewCell *cell = ((IndividualListTableViewCell*)[self.tableView cellForRowAtIndexPath:path]);

    ListArticle *listArticle = (ListArticle*)managedObject;
    listArticle.checked = [NSNumber numberWithBool:![listArticle.checked boolValue]];
	if ([listArticle.checked boolValue]) {
        [cell wasChecked];
        listArticle.timeStamp = [NSDate date];
	}
    
    [cell updateView];
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
}

- (void)managedObjectAccessoryTapped:(NSManagedObject *)managedObject {
    RIButtonItem *change = [RIButtonItem itemWithLabel:@"Ändra vara"];
    change.action = ^
    {
        ArticleDetailViewController *articleDetailViewController = [[ArticleDetailViewController alloc] initWithNibName:@"ArticleDetailViewController" bundle:nil article:((ListArticle*)managedObject).article];
        [self.navController pushViewController:articleDetailViewController animated:YES];
        [articleDetailViewController release];
    };
    
    RIButtonItem *delete = [RIButtonItem itemWithLabel:@"Ta bort från listan"];
    delete.action = ^
    {
        [self deleteManagedObject:managedObject];
    };
    
    RIButtonItem *price = [RIButtonItem itemWithLabel:@"Ändra pris"];
    price.action = ^
    {
        PriceAlertView *alertPrompt = [[PriceAlertView alloc] initWithListArticle:(ListArticle*)managedObject];
        [alertPrompt show];
    };
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:((ListArticle*)managedObject).article.name cancelButtonItem:[RIButtonItem itemWithLabel:@"Avbryt"] destructiveButtonItem:delete otherButtonItems:change,price, nil];
    [sheet showInView:self.view.window];
    [sheet release];
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
	ListArticle *article = (ListArticle*)managedObject;
	[list_.managedObjectContext deleteObject:managedObject];
	[list_.managedObjectContext deleteObject:article];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject {
	return UITableViewCellAccessoryDetailDisclosureButton;
}


#pragma mark -
#pragma mark Events

// Called when the add button is pressed
- (void)addArticle {
	AddArticleListViewController *addArticleListViewController = [[AddArticleListViewController alloc] initWithList:list_];
	[addArticleListViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self.navigationController pushViewController:addArticleListViewController animated:YES];
	[addArticleListViewController release];
}

- (void)forceReload {
    if (self.tableView)
        [self.tableView reloadData];
}

- (void)updateSorting {
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"ListArticle" inManagedObjectContext:list_.managedObjectContext];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	listSortOrder = [defaults integerForKey:@"individualListSortOrder"];
	if ([defaults boolForKey:@"individualListSectioning"]) {
		NSSortDescriptor *secondaryDescriptor = nil;
		if (listSortOrder == 0) {
			secondaryDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		}
		else if (listSortOrder == 1) {
			secondaryDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES];
		}
		request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"checked"
																						  ascending:YES],
								   secondaryDescriptor,nil];
	}
	else {
		if (listSortOrder == 0) {
			request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"article.name"
																							 ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
		}
		else if (listSortOrder == 1) {
			request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
																							 ascending:YES]];
		}
		
	}
	
	request.predicate = [NSPredicate predicateWithFormat:@"list = %@", list_];
	request.fetchBatchSize = 20;
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
									   initWithFetchRequest:request
									   managedObjectContext:list_.managedObjectContext
									   sectionNameKeyPath:([defaults boolForKey:@"individualListSectioning"] ? @"checked" : nil)
									   cacheName:nil];
	frc.delegate = self;
	
	[request release];
	
	[self setFetchedResultsController:frc];
	[frc release];
	
	self.titleKey = @"article.name";
	self.searchKey = @"article.name";
}

- (void)setList:(List*)list {
	self.list_ = list;
	[self updateSorting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceReload) name:@"ArticleChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceReload) name:@"SectionSettingChanged" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSorting) name:@"IndividualListSortOrderChanged" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:0.3f animations:^{
        self.tableView.contentOffset = CGPointMake(0.0, self.searchDisplayController.searchBar.frame.size.height);
    }];
}

- (void)dealloc {
	[list_ release];
    [super dealloc];
}


@end
