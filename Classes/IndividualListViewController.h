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

#import "ZBarSDK.h"

#import "CMPopTipView.h"

@interface IndividualListViewController : UIViewController<UIActionSheetDelegate,UIAlertViewDelegate, ZBarReaderDelegate, CMPopTipViewDelegate> {
	IBOutlet IndividualListTableViewController *individualListTableViewController;
	IBOutlet UITableView *tableView;
	IBOutlet UILabel *progressLabel;
    IBOutlet UIButton* checkoutButton;
	List* list_;
    CMPopTipView *myPopTipView;
    IBOutlet UIView *bubblePlaceholder;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil list:(List*)list;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (IBAction)purchase;
- (void)purchaseDone;
- (void)addListArticle;
- (IBAction)scanListArticle;

@property (readonly) NSInteger elementsCount,checkedElementsCount;
@property (nonatomic, retain) CMPopTipView *myPopTipView;

@end
