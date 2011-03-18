//
//  TestViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-17.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndividualListTableViewController.h"
#import "List.h"


@interface IndividualListViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate> {
	IBOutlet IndividualListTableViewController *individualListTableViewController;
	IBOutlet UITableView *tableView;
	IBOutlet UILabel *progressLabel;
	IBOutlet UIProgressView *progressBar;
    IBOutlet UIButton* checkoutButton;
	List* list_;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil list:(List*)list;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (IBAction)purchase;

@property (readonly) NSInteger elementsCount,checkedElementsCount;

@end
