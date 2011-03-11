//
//  SettingsViewController.m
//  Handla
//
//  Created by Max Westermark on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Inställningar";
	listLabel = @"Listinställningar";
	budgetLabel = @"Budgetinställningar";
	aboutLabel = @"Om Hjälpmedelsinstituet";
	
	
	/*
	labels1 = [[NSMutableArray alloc] initWithCapacity:2];
	[labels1 addObject:@"Listinställningar"];
	[labels1 addObject:@"Budgetinställningar"];
	labels2 = [[NSMutableArray alloc] initWithCapacity:1];
	[labels2 addObject:@"Om Hjälpmedelsinstitutet"];
	 */
	
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return 2;
	}
    if (section == 1) {
		return 1;
	}
	else {
		return 0;
	}

}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.textLabel.text = listLabel;
		}
		if (indexPath.row == 1) {
			cell.textLabel.text = budgetLabel;
		}
	}
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.textLabel.text = aboutLabel;
		}
	}
	
	
	//cell.textLabel.text = [labels1 objectAtIndex:indexPath.row];
	
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    
    
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			listSettingsViewController = [[ListSettingsViewController alloc] initWithNibName:@"ListSettingsViewController" bundle:nil];
			[self.navigationController pushViewController:listSettingsViewController animated:YES];
			[listSettingsViewController release];
		}
		if (indexPath.row == 1) {
			budgetSettingsViewController = [[BudgetSettingsViewController alloc] initWithNibName:@"BudgetSettingsViewController" bundle:nil];
			[self.navigationController pushViewController:budgetSettingsViewController animated:YES];
			[budgetSettingsViewController release];
		}
	}
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
			[self.navigationController pushViewController:aboutViewController animated:YES];
			[aboutViewController release];
		}
	}
    // ...
    // Pass the selected object to the new view controller.
    
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

