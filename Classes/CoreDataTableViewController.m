//
//  CoreDataTableViewController.m
//
//  Created for Stanford CS193p Spring 2010
//  Modified by Fredrik Gustafsson 2011
//  With added support for sorting by relationproperties
//  and a small bugfix
//

#import "CoreDataTableViewController.h"

@implementation CoreDataTableViewController

@synthesize fetchedResultsController;
@synthesize titleKey, subtitleKey, searchKey;

- (void)createSearchBar
{
	if (self.searchKey.length) {
		if (self.tableView && !self.tableView.tableHeaderView) {
			UISearchBar *searchBar = [[[UISearchBar alloc] init] autorelease];
			[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
			self.searchDisplayController.searchResultsDelegate = self;
			self.searchDisplayController.searchResultsDataSource = self;
			self.searchDisplayController.delegate = self;
			searchBar.frame = CGRectMake(0, 0, 0, 38);
			self.tableView.tableHeaderView = searchBar;
		}
	} else {
		self.tableView.tableHeaderView = nil;
	}
}

- (void)setSearchKey:(NSString *)aKey
{
	[searchKey release];
	searchKey = [aKey copy];
	[self createSearchBar];
}

- (NSString *)titleKey
{
	if (!titleKey) {
		NSArray *sortDescriptors = [self.fetchedResultsController.fetchRequest sortDescriptors];
		if (sortDescriptors.count) {
			return [[sortDescriptors objectAtIndex:0] key];
		} else {
			return nil;
		}
	} else {
		return titleKey;
	}
}

- (void)performFetchForTableView:(UITableView *)tableView
{
	NSError *error = nil;
	[self.fetchedResultsController performFetch:&error];
	if (error) {
		NSLog(@"[CoreDataTableViewController performFetchForTableView:] %@ (%@)", [error localizedDescription], [error localizedFailureReason]);
	}
	[tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
	if (tableView == self.tableView) {
		if (self.fetchedResultsController.fetchRequest.predicate != normalPredicate) {
			[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
			self.fetchedResultsController.fetchRequest.predicate = normalPredicate;
			[self performFetchForTableView:tableView];
		}
		[currentSearchText release];
		currentSearchText = nil;
	} else if ((tableView == self.searchDisplayController.searchResultsTableView) && self.searchKey && ![currentSearchText isEqual:self.searchDisplayController.searchBar.text]) {
		[currentSearchText release];
		currentSearchText = [self.searchDisplayController.searchBar.text copy];
		NSString *searchPredicateFormat = [NSString stringWithFormat:@"%@ contains[c] %@", self.searchKey, @"%@"];
		NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:searchPredicateFormat, self.searchDisplayController.searchBar.text];
		[NSFetchedResultsController deleteCacheWithName:self.fetchedResultsController.cacheName];
		self.fetchedResultsController.fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:searchPredicate, normalPredicate , nil]];
		[self performFetchForTableView:tableView];
	}
	return self.fetchedResultsController;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
	// reset the fetch controller for the main (non-searching) table view
	[self fetchedResultsControllerForTableView:self.tableView];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)controller
{
	fetchedResultsController.delegate = nil;
	[fetchedResultsController release];
	fetchedResultsController = [controller retain];
	controller.delegate = self;
	normalPredicate = [self.fetchedResultsController.fetchRequest.predicate retain];
	if (!self.title) self.title = controller.fetchRequest.entity.name;
	[self performFetchForTableView:self.tableView];
}

- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject
{
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject
{
	return nil;
}

- (void)configureCell:(UITableViewCell *)cell forManagedObject:(NSManagedObject *)managedObject
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject
{
    static NSString *ReuseIdentifier = @"CoreDataTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier];
    if (cell == nil) {
		UITableViewCellStyle cellStyle = self.subtitleKey ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
        cell = [[[UITableViewCell alloc] initWithStyle:cellStyle reuseIdentifier:ReuseIdentifier] autorelease];
    }
	
	if (self.titleKey) {
		NSArray *subObjects = [self.titleKey componentsSeparatedByString:@"."];
		NSManagedObject *tempObject = managedObject;
		for (int i = 0; i<subObjects.count-1; ++i) {
			tempObject = [tempObject valueForKey:[subObjects objectAtIndex:i]];
		}
		cell.textLabel.text = [tempObject valueForKey:[subObjects lastObject]];
	}
	if (self.subtitleKey) {
		NSArray *subObjects = [self.subtitleKey componentsSeparatedByString:@"."];
		NSManagedObject *tempObject = managedObject;
		for (int i = 0; i<subObjects.count-1; ++i) {
			tempObject = [tempObject valueForKey:[subObjects objectAtIndex:i]];
		}
		cell.detailTextLabel.text = [tempObject valueForKey:[subObjects lastObject]];
	}
	cell.accessoryType = [self accessoryTypeForManagedObject:managedObject];
	UIImage *thumbnail = [self thumbnailImageForManagedObject:managedObject];
	if (thumbnail) cell.imageView.image = thumbnail;
	
	return cell;
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];
}

- (void)managedObjectAccessoryTapped:(NSManagedObject *)managedObject
{
    // Navigation logic may go here. Create and push another view controller.
    // AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
    // [self.navigationController pushViewController:anotherViewController];
    // [anotherViewController release];	
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject
{
}

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
	return [self canDeleteManagedObject:managedObject];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSManagedObject *managedObject = [[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
	[self deleteManagedObject:managedObject];
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
	[self createSearchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self performFetchForTableView:self.tableView];
	self.tableView.contentOffset = CGPointMake(0.0, 40.0);
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsControllerForTableView:tableView] sections] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return [[self fetchedResultsControllerForTableView:tableView] sectionIndexTitles];
}

#pragma mark UITableViewDelegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self tableView:tableView cellForManagedObject:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self managedObjectSelected:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self managedObjectAccessoryTapped:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[[[self fetchedResultsControllerForTableView:tableView] sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [[self fetchedResultsControllerForTableView:tableView] sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{	
    UITableView *tableView = self.tableView;
	
    switch(type)
	{
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeUpdate:
			[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
			
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
	self.tableView.contentOffset = CGPointMake(0.0, 40.0);
}

#pragma mark dealloc

- (void)dealloc
{
	fetchedResultsController.delegate = nil;
	[fetchedResultsController release];
	[searchKey release];
	[titleKey release];
	[currentSearchText release];
	[normalPredicate release];
    [super dealloc];
}

@end

