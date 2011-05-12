//
//  ArticleDetailViewController.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-22.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"
#import "ListArticle.h"
#import "List.h"

#import "ZBarSDK.h"

#import "BrutalUIImageView.h"

@interface ArticleDetailViewController : UIViewController<ZBarReaderDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate> {
	Article *article_;
	List *list_;
	NSManagedObjectContext *managedObjectContext_;
	IBOutlet UIButton *photoButton;
	IBOutlet UITextField *nameField;
	IBOutlet BrutalUIImageView *photo;
	IBOutlet UITextField *commentField;
    IBOutlet UIImageView* barCodeCheckBox;
	ZBarReaderViewController *barcodeReader;
	UIImagePickerController *picturePicker;
	BOOL newPhoto;
}

- (IBAction)scanClick:(id)sender;
- (IBAction)cameraClick:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil article:(Article*)article;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil list:(List*)list;

@end
