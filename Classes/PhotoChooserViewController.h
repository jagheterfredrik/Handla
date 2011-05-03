//
//  PhotoChooserViewController.h
//  Handla
//
//  Created by Emil Johansson on 12/4/11.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoChooserViewController;

@protocol PhotoChooserDelegate

- (void)photoChooserDone:(PhotoChooserViewController*)photoChooser;

@end


@interface PhotoChooserViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
	BOOL canChange;
	IBOutlet UIImageView *imageView;
    NSString *picture_str;
	IBOutlet UIButton *cameraButton;
	IBOutlet UIButton *galleryButton;
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UILabel *loading;
    IBOutlet UIView *loadingView;
    BOOL isInitialized;
}

@property (nonatomic,assign) NSObject<PhotoChooserDelegate> *delegate;
@property (readonly) BOOL newImage;
@property (readonly) UIImage *image;

- (id)initWithImage:(NSString*)photo canChange:(BOOL)change;

- (IBAction)getPhoto:(id)sender;
- (IBAction)goBack;

@end
