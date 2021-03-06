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

@synthesize previousBudgetSum, budgetSum, plusSum, minusSum;
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
    
    plusSign = [[UIImage imageNamed:@"PlusSign"] retain];
    minusSign = [[UIImage imageNamed:@"MinusSign"] retain];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"budgetHistory"]) {
        self.tableView.tableHeaderView = prevCell;
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

/**
 * Sets the managedObjectContext to be used for getting/setting data.
 * This function also initializes the CoreDataTableViewController.
 */
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

/**
 * Sets the tableview into/outof editing mode and disables/enables the add button.
 */
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    self.navItem.rightBarButtonItem.enabled = !editing;
    [super setEditing:editing animated:animated];
}

/**
 *  Adds to the variables plusSum, minusSum. To plus if the value is
 * positive and to minus if it is negative.
 */
- (void)addDiffSum:(NSDecimalNumber*)num {

    NSComparisonResult res = [[NSDecimalNumber zero] compare:num];
    if (res == NSOrderedAscending) {
        self.plusSum = [self.plusSum decimalNumberByAdding:num];
    } else {
        self.minusSum = [self.minusSum decimalNumberByAdding:[num decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]]];
    }
}

- (void)calculateBudgetData {
    //Budget before the set date
    self.plusSum = [NSDecimalNumber zero];
    self.minusSum = [NSDecimalNumber zero];
    self.previousBudgetSum = [NSDecimalNumber zero];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"budgetHistory"]) {
        sumResultController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(timeStamp < %@)", startDate];
        [sumResultController performFetch:NULL];
        for (BudgetPost *post in sumResultController.fetchedObjects) {
            // TODO: add code for repeatID >= 0
            if (post.amount) {
                self.previousBudgetSum = [previousBudgetSum decimalNumberByAdding:post.amount];
            }
        }
    }
    
    sumResultController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(timeStamp >= %@) AND (timeStamp <= %@)", startDate, endDate];
    [sumResultController performFetch:NULL];
    
    self.budgetSum = [[NSDecimalNumber zero] decimalNumberByAdding:self.previousBudgetSum];
    [self addDiffSum:self.previousBudgetSum];
    
    
    for (BudgetPost *post in sumResultController.fetchedObjects) {
        // TODO: add code for repeatID >= 0
        if (post.amount) {
            self.budgetSum = [budgetSum decimalNumberByAdding:post.amount];
            [self addDiffSum:post.amount];
        }
    }
}

/**
 * Sets the time interval to display and fetches BudgetPosts from it.
 */
- (void)setDurationStartDate:(NSDate*)startDate_ endDate:(NSDate*)endDate_ {
    [startDate release];
    [endDate release];
	startDate = [startDate_ retain];
	endDate = [endDate_ retain];
	
    [self calculateBudgetData];
    
    prevCell.nameLabel.text = @"Tidigare budget";
    prevCell.center = CGPointMake(prevCell.center.x, prevCell.frame.size.height / 2.f);
    prevCell.dateLabel.text = [NSString stringWithFormat:@"Före %@", [dateFormatter stringFromDate:startDate]];
    prevCell.accessoryType = UITableViewCellAccessoryNone;
    prevCell.priceLabel.text = [amountFormatter stringFromNumber:previousBudgetSum];
    if ([previousBudgetSum compare:[NSNumber numberWithInt:0]] == NSOrderedAscending) {
        prevCell.symbolView.image = minusSign;
    } else {
        prevCell.symbolView.image = plusSign;
    }
    
	normalPredicate = [NSPredicate predicateWithFormat:@"(timeStamp >= %@) AND (timeStamp <= %@)", startDate_, endDate_];
	[self.tableView reloadData];
}

#pragma mark - Core data tableview controller overrides

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
	}
	BudgetPost *budgetPost = (BudgetPost*)managedObject;
	cell.nameLabel.text = budgetPost.name;
	cell.dateLabel.text = [dateFormatter stringFromDate:budgetPost.timeStamp];
	cell.priceLabel.text = [amountFormatter stringFromNumber:budgetPost.amount];
	if ([budgetPost.amount compare:[NSNumber numberWithInt:0]] == NSOrderedAscending) {
        cell.symbolView.image = minusSign;
	} else {
        cell.symbolView.image = plusSign;
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 36.f;
}

#pragma mark - Life cycle stuff

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [prevCell release];
    [minusSign release];
    [plusSign release];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
