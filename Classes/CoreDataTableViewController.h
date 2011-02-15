//
//  CoreDataTableViewController.h
//
//  Created for Stanford CS193p Spring 2010
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate>
{
	NSPredicate *normalPredicate;
	NSString *currentSearchText;
	NSString *titleKey;
	NSString *subtitleKey;
	NSString *searchKey;
	NSFetchedResultsController *fetchedResultsController;
}

// the controller (this class does nothing if this is not set)
@property (retain) NSFetchedResultsController *fetchedResultsController;

// key to use when displaying items in the table; defaults to the first sortDescriptor's key
@property (copy) NSString *titleKey;
// key to use when displaying items in the table for the subtitle; defaults to nil
@property (copy) NSString *subtitleKey;
// key to use when searching the table (should usually be the same as displayKey); if nil, no searching allowed
@property (copy) NSString *searchKey;

// gets accessory type (e.g. disclosure indicator) for the given managedObject (default DisclosureIndicator)
- (UITableViewCellAccessoryType)accessoryTypeForManagedObject:(NSManagedObject *)managedObject;

// returns an image (small size) to display in the cell (default is nil)
- (UIImage *)thumbnailImageForManagedObject:(NSManagedObject *)managedObject;

// this is the CoreDataTableViewController's version of tableView:cellForRowAtIndexPath:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject;

// called when a cell representing the specified managedObject is selected (does nothing by default)
- (void)managedObjectSelected:(NSManagedObject *)managedObject;

// called to see if the specified managed object is allowed to be deleted (default is NO)
- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject;

// called when the user commits a delete by hitting a Delete button in the user-interface (default is to do nothing)
// this method does not necessarily have to delete the object from the database
// (e.g. it might just change the object so that it does not match the fetched results controller's predicate anymore)
- (void)deleteManagedObject:(NSManagedObject *)managedObject;

@end
