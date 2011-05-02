//
//  ListSettingsViewController.m
//  Handla
//
//  Created by Max Westermark on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ListSettingsViewController.h"


@implementation ListSettingsViewController
@synthesize checkoutSwitch;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Listor";
	
	
	optionSortOrder = [[NSMutableArray alloc] initWithCapacity:3];
	[optionSortOrder addObject:@"Namn"];
	[optionSortOrder addObject:@"Senast använd"];
	[optionSortOrder addObject:@"Senast skapad"];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)doneClick {
	[self.navigationController popViewControllerAnimated:YES];
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
	if(section == 0){
		return 3;
	}else if(section == 1){
		return 1;
	}else {
		return 0;
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Sorteringsordning";
	}else if (section == 1) {
		return @"Övrigt";
	}
	return @"";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    // Configure the cell...
	
	if (indexPath.section == 0) {
		NSInteger lso = [defaults integerForKey:@"listSortOrder"];
		cell.textLabel.text = [optionSortOrder objectAtIndex:indexPath.row];
		if (indexPath.row == lso) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}else if (indexPath.section == 1) {
		cell.textLabel.text = @"Betalningsvy";
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		checkoutSwitch = [[UISwitch alloc] init];
		cell.accessoryView = checkoutSwitch;
		[cell addSubview:checkoutSwitch];
		[checkoutSwitch addTarget:self action:@selector(checkoutSwitchChanged) forControlEvents:UIControlEventValueChanged];
		if ([defaults integerForKey:@"listCheckoutViewOn"] == 1) {
			[checkoutSwitch setOn:YES animated:NO];
		}else {
			[checkoutSwitch setOn:NO animated:NO];
		}

		
	}
    return cell;
}


-(void) checkoutSwitchChanged{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	if(checkoutSwitch.on)
	{
		[defaults setBool:YES forKey:@"listCheckoutViewOn"];
		NSLog(@"ON");
	}
	else
	{
		[defaults setBool:NO forKey:@"listCheckoutViewOn"];
		NSLog(@"OFF");
	}
	
	[defaults synchronize];
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
        [tableView deleteRowsAtIndexPaths:[NSArray option1WithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the option1, and add a new row to the table view.
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
	
	UITableViewCell *cell;
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	
	
	if (indexPath.section == 0) {
		NSInteger lso = [defaults integerForKey:@"listSortOrder"];
		
		NSUInteger tmpArray[] = {0, lso};		
		NSIndexPath *ip = [NSIndexPath indexPathWithIndexes:tmpArray length:2];
		
		UITableViewCell *lastCheckedCell = [tableView cellForRowAtIndexPath:ip];
		lastCheckedCell.accessoryType = UITableViewCellAccessoryNone;
		
		cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		
		[defaults setInteger:indexPath.row forKey:@"listSortOrder"];
	}else if (indexPath.section == 1) {
		
			
	}
	
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
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

