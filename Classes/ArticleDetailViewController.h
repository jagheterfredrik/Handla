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

#import "ZBarSDK.h"

@interface ArticleDetailViewController : UIViewController<ZBarReaderDelegate, UIImagePickerControllerDelegate> {
	Article *article_;
	NSManagedObjectContext *managedObjectContext_;
	IBOutlet UIButton *photoButton;
	IBOutlet UITextField *nameField;
	IBOutlet UITextField *scanField;
	IBOutlet UIImageView *photo;
	ZBarReaderViewController *barcodeReader;
	UIImagePickerController *picturePicker;
}
- (IBAction)scanClick:(id)sender;
- (IBAction)cameraClick:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil article:(Article*)article;

@end
