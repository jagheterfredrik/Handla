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
	/*Fetching intervall for the budget table list
	 *
	 *TODO: Fixa med månad/vecko-intervall för att fetcha rätt budgetposter. 
	 *
	 
	NSDate *startIntervall = [[NSDate alloc] initWithString:@"2011-02-18 00:00:00 +0100"];
	NSDate *endIntervall = [[NSDate alloc] initWithString:@"2011-02-22 23:59:59 +0100"];
	request.predicate = [NSPredicate predicateWithFormat:@"(timeStamp >= %@) AND (timeStamp <= %@)", startIntervall, endIntervall];
*/
	request.predicate = nil;
	
	request.fetchBatchSize = 20;
	
	NSFetchedResultsController *frc = [[NSFetchedResultsController alloc]
									   initWithFetchRequest:request
									   managedObjectContext:managedObjectContext_
									   sectionNameKeyPath:nil
									   cacheName:nil];
	frc.delegate = self;
	
	[request release];
//	[startIntervall release];
//	[endIntervall release];
	
	[self setFetchedResultsController:frc];
	[frc release];
	
	self.titleKey = @"name";
	self.searchKey = @"name";
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
		cell.priceLabel.textColor = [UIColor greenColor];

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
	[dateFormatter release];
    [super dealloc];
}


@end
