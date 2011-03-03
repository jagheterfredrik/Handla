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

@synthesize startDate, endDate;

- (void)viewDidLoad {
	//Setup the date formatter
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	

	//Setup the amount formatter	
	amountFormatter = [[NSNumberFormatter alloc] init];
	[amountFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
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
}

- (void)setDurationStartDate:(NSDate*)startDate_ endDate:(NSDate*)endDate_ {
	self.startDate = startDate_;
	self.endDate = endDate_;
	
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
	}
	BudgetPost *budgetPost = (BudgetPost*)managedObject;
	cell.nameLabel.text = budgetPost.name;
	cell.dateLabel.text = [dateFormatter stringFromDate:budgetPost.timeStamp];
	cell.priceLabel.text = [amountFormatter stringFromNumber:budgetPost.amount];
	if ([budgetPost.amount compare:[NSNumber numberWithInt:0]] == NSOrderedAscending)
		cell.priceLabel.textColor = [UIColor redColor];
	else
		cell.priceLabel.textColor = [UIColor colorWithRed:0.f green:0.55f blue:0.f alpha:1.f];

	return cell;
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
	[startDate release];
	[endDate release];
	[dateFormatter release];
    [super dealloc];
}


@end
