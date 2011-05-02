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
#import "PhotoChooserViewController.h"

#import "ZBarSDK.h"

@interface ArticleDetailViewController : UIViewController<ZBarReaderDelegate, UIImagePickerControllerDelegate, PhotoChooserDelegate> {
	Article *article_;
	List *list_;
	NSManagedObjectContext *managedObjectContext_;
	IBOutlet UIButton *photoButton;
	IBOutlet UITextField *nameField;
	IBOutlet UITextField *scanField;
	IBOutlet UIImageView *photo;
	IBOutlet UITextField *commentField;
	ZBarReaderViewController *barcodeReader;
	UIImagePickerController *picturePicker;
    PhotoChooserViewController *photoChooser;
	BOOL newPhoto;
}

- (IBAction)scanClick:(id)sender;
- (IBAction)cameraClick:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil article:(Article*)article;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil list:(List*)list;

@end
