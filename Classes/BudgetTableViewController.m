//
//  BudgetTableViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-21.
//  Harald Hartwig och Wilhelm Kärde
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "BudgetTableViewController.h"
#import "BudgetViewController.h"
#import "BudgetPost.h"
#import "BudgetPostDetailViewController.h"


@implementation BudgetTableViewController

@synthesize previousBudgetSum, budgetSum;
@synthesize navItem;

- (void)viewDidLoad {
	//Setup the date formatter
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
	//Setup the amount formatter	
	amountFormatter = [[NSNumberFormatter alloc] init];
	[amountFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];

    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BudgetTableViewCell" owner:nil options:nil];
    for (id currentObject in topLevelObjects)
        if ([currentObject isKindOfClass:[BudgetTableViewCell class]]) {
            prevCell = [currentObject retain];
            break;
        }
    
    self.tableView.tableHeaderView = prevCell;
}

- (void)setManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	managedObjectContext_ = managedObjectContext;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"BudgetPost" inManagedObjectContext:managedObjectContext_];
	request.sortDescriptors = [NSArray arrayWithObjects:
        [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES selector:@selector(compare:)],
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)],
        nil];
    
	request.predicate = nil;
	
	request.fetchBatchSize = 20;
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
									   initWithFetchRequest:request
									   managedObjectContext:managedObjectContext_
									   sectionNameKeyPath:nil
									   cacheName:nil];
	frc.delegate = self;
	
	[request release];
	
	[self setFetchedResultsController:frc];
	[frc release];
	
	self.titleKey = @"name";
//	self.searchKey = @"name";
    
    // Setup sum-counting-request
    [sumResultController release];
    NSFetchRequest *sumRequest = [[NSFetchRequest alloc] init];
	sumRequest.entity = [NSEntityDescription entityForName:@"BudgetPost" inManagedObjectContext:managedObjectContext_];
	
	sumResultController = [[NSFetchedResultsController alloc]
                           initWithFetchRequest:request
                           managedObjectContext:managedObjectContext_
                           sectionNameKeyPath:nil
                           cacheName:nil];
	[sumRequest release];
	
	[self setFetchedResultsController:frc];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.navItem.rightBarButtonItem.enabled = !editing;
    [super setEditing:editing animated:animated];
}

- (void)setDurationStartDate:(NSDate*)startDate_ endDate:(NSDate*)endDate_ {
    [startDate release];
    [endDate release];
	startDate = [startDate_ retain];
	endDate = [endDate_ retain];
	
    sumResultController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(timeStamp < %@)", startDate_];
    [sumResultController performFetch:NULL];
    self.previousBudgetSum = [NSDecimalNumber decimalNumberWithString:@"0"];
    for (BudgetPost *post in sumResultController.fetchedObjects) {
        // TODO: add code for repeatID >= 0
        if (post.amount) {
            self.previousBudgetSum = [previousBudgetSum decimalNumberByAdding:post.amount];
        }
    }
    
    sumResultController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(timeStamp >= %@) AND (timeStamp <= %@)", startDate_, endDate_];
    [sumResultController performFetch:NULL];
    self.budgetSum = [NSDecimalNumber decimalNumberWithString:@"0"];
    self.budgetSum = [self.budgetSum decimalNumberByAdding:self.previousBudgetSum];
    for (BudgetPost *post in sumResultController.fetchedObjects) {
        // TODO: add code for repeatID >= 0
        if (post.amount) {
            self.budgetSum = [budgetSum decimalNumberByAdding:post.amount];
        }
    }
    
    prevCell.symbolLabel.textAlignment = UITextAlignmentCenter;
    
    prevCell.nameLabel.text = @"Tidigare budget";
    prevCell.center = CGPointMake(prevCell.center.x, prevCell.frame.size.height / 2.f);
    prevCell.dateLabel.text = [NSString stringWithFormat:@"Före %@", [dateFormatter stringFromDate:startDate]];
    prevCell.accessoryType = UITableViewCellAccessoryNone;
    prevCell.priceLabel.text = [amountFormatter stringFromNumber:previousBudgetSum];
    if ([previousBudgetSum compare:[NSNumber numberWithInt:0]] == NSOrderedAscending) {
        prevCell.symbolLabel.text = @"-";
        prevCell.symbolLabel.font = [UIFont fontWithName:@"Helvetica" size:40.f];
        prevCell.symbolLabel.textColor = [UIColor redColor];
        prevCell.priceLabel.textColor = [UIColor redColor];
    } else {
        prevCell.symbolLabel.text = @"+";
        prevCell.symbolLabel.font = [UIFont fontWithName:@"Helvetica" size:34.f];
        prevCell.symbolLabel.textColor = [UIColor colorWithRed:0.f green:0.55f blue:0.f alpha:1.f];
        prevCell.priceLabel.textColor = [UIColor colorWithRed:0.f green:0.55f blue:0.f alpha:1.f];
    }
    
	normalPredicate = [NSPredicate predicateWithFormat:@"(timeStamp >= %@) AND (timeStamp <= %@)", startDate_, endDate_];
	[self.tableView reloadData];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[super controllerDidChangeContent:controller];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BudgetPostUpdated" object:self];
}

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
	BudgetPostDetailViewController *budgetPostDetailViewController = [[BudgetPostDetailViewController alloc] initWithBudgetPost:(BudgetPost*)managedObject];
	[budgetViewController.navigationController pushViewController:budgetPostDetailViewController animated:YES];
	[budgetPostDetailViewController release];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

/*
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
 return @"Vecka/Månad placeholder";
 }
 */

- (BOOL)canDeleteManagedObject:(NSManagedObject *)managedObject {
	return YES;
}

- (void)deleteManagedObject:(NSManagedObject *)managedObject {
	[managedObjectContext_ deleteObject:managedObject];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForManagedObject:(NSManagedObject *)managedObject {
	static NSString *cellIdentifier = @"BudgetPostCell";
	BudgetTableViewCell *cell = (BudgetTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"BudgetTableViewCell" owner:nil options:nil];
		for (id currentObject in topLevelObjects)
			if ([currentObject isKindOfClass:[BudgetTableViewCell class]]) {
				cell = currentObject;
				break;
			}
		cell.symbolLabel.textAlignment = UITextAlignmentCenter;
	}
	BudgetPost *budgetPost = (BudgetPost*)managedObject;
	cell.nameLabel.text = budgetPost.name;
	cell.dateLabel.text = [dateFormatter stringFromDate:budgetPost.timeStamp];
	cell.priceLabel.text = [amountFormatter stringFromNumber:budgetPost.amount];
	if ([budgetPost.amount compare:[NSNumber numberWithInt:0]] == NSOrderedAscending) {
		cell.symbolLabel.text = @"-";
		cell.symbolLabel.font = [UIFont fontWithName:@"Helvetica" size:40.f];
		cell.symbolLabel.textColor = [UIColor redColor];
		cell.priceLabel.textColor = [UIColor redColor];
	} else {
		cell.symbolLabel.text = @"+";
		cell.symbolLabel.font = [UIFont fontWithName:@"Helvetica" size:34.f];
		cell.symbolLabel.textColor = [UIColor colorWithRed:0.f green:0.55f blue:0.f alpha:1.f];
		cell.priceLabel.textColor = [UIColor colorWithRed:0.f green:0.55f blue:0.f alpha:1.f];
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 36.f;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [prevCell release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	
    
}

- (void)dealloc {
    [sumResultController release];
    [previousBudgetSum release];
	[startDate release];
	[endDate release];
	[dateFormatter release];
    [super dealloc];
}


@end
