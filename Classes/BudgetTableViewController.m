//
//  BudgetTableViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-21.
//  Harald Hartwig och Wilhelm Kärde
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "BudgetTableViewController.h"
#import "BudgetTableViewCell.h"
#import "BudgetViewController.h"
#import "BudgetPost.h"
#import "BudgetPostDetailViewController.h"


@implementation BudgetTableViewController

@synthesize startDate, endDate, budgetSum;

- (void)viewDidLoad {
	//Setup the date formatter
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	
    
	//Setup the amount formatter	
	amountFormatter = [[NSNumberFormatter alloc] init];
	[amountFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    
    self.budgetSum = [NSDecimalNumber decimalNumberWithString:@"0"];
}

- (void)setManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	managedObjectContext_ = managedObjectContext;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"BudgetPost" inManagedObjectContext:managedObjectContext_];
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
																					 ascending:YES
																					  selector:@selector(compare:)]];
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
	self.searchKey = @"name";
    
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

- (void)setDurationStartDate:(NSDate*)startDate_ endDate:(NSDate*)endDate_ {
	self.startDate = startDate_;
	self.endDate = endDate_;
	
    sumResultController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(timeStamp < %@)", startDate_];
    [sumResultController performFetch:NULL];
    self.budgetSum = [[NSDecimalNumber decimalNumberWithString:@"0"] retain];
    for (BudgetPost *post in sumResultController.fetchedObjects) {
        // TODO: add code for repeatID >= 0
        self.budgetSum = [budgetSum decimalNumberByAdding:post.amount];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([budgetSum compare:[NSDecimalNumber decimalNumberWithString:@"0"]] != NSOrderedSame) {
        if (indexPath.row == 0 && indexPath.section == 0) {
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
            cell.nameLabel.text = @"Tidigare budget";
            cell.dateLabel.text = @"";
            cell.priceLabel.text = [amountFormatter stringFromNumber:budgetSum];
            if ([budgetSum compare:[NSNumber numberWithInt:0]] == NSOrderedAscending) {
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
        } else {
            NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            return [super tableView:tableView cellForRowAtIndexPath:newPath];
        }
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([budgetSum compare:[NSDecimalNumber decimalNumberWithString:@"0"]] != NSOrderedSame) {
            if (indexPath.row == 0) {
                return;
            } else {
                NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                return [super tableView:tableView didSelectRowAtIndexPath:newPath];
            }
        } else {
            return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
    } else {
        return [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        if ([budgetSum compare:[NSDecimalNumber decimalNumberWithString:@"0"]] != NSOrderedSame) {
            if (indexPath.row == 0) {
                return NO;
            } else {
                NSIndexPath *newPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
                return [super tableView:tableView canEditRowAtIndexPath:newPath];
            }
        } else {
            return [super tableView:tableView canEditRowAtIndexPath:indexPath];
        }
    } else {
        return [super tableView:tableView canEditRowAtIndexPath:indexPath];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && [budgetSum compare:[NSDecimalNumber decimalNumberWithString:@"0"]] != NSOrderedSame) {
        return [super tableView:tableView numberOfRowsInSection:section]+1;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40.f;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
	
    
}


- (void)dealloc {
    [sumResultController release];
    [budgetSum release];
	[startDate release];
	[endDate release];
	[dateFormatter release];
    [super dealloc];
}


@end
