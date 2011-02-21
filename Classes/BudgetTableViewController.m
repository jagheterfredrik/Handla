    //
//  BudgetTableViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-21.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "BudgetTableViewController.h"
#import "BudgetTableViewCell.h"
#import "BudgetViewController.h"
#import "BudgetPost.h"
#import "AddBudgetPostViewController.h"

@implementation BudgetTableViewController

- (void)setManagedObjectContext:(NSManagedObjectContext*)managedObjectContext {
	managedObjectContext_ = managedObjectContext;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"BudgetPost" inManagedObjectContext:managedObjectContext_];
	request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timeStamp"
																					 ascending:YES
																					  selector:@selector(compare:)]];
	request.predicate = nil;//[NSPredicate predicateWithFormat:@"list = %@", list_];
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

- (void)managedObjectSelected:(NSManagedObject *)managedObject
{
	AddBudgetPostViewController *addBudgetPostViewController = [[AddBudgetPostViewController alloc] initWithBudgetPost:(BudgetPost*)managedObject];
	[budgetViewController presentModalViewController:addBudgetPostViewController animated:YES];
	[addBudgetPostViewController release];
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
	cell.dateLabel.text = [budgetPost.timeStamp description];
	cell.priceLabel.text = [budgetPost.amount stringValue];
	if ([budgetPost.amount compare:[NSNumber numberWithInt:0]] == NSOrderedAscending)
		cell.priceLabel.textColor = [UIColor redColor];
	else
		cell.priceLabel.textColor = [UIColor greenColor];

	return cell;
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


- (void)dealloc {
    [super dealloc];
}


@end
