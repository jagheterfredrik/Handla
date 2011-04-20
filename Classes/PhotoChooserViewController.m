//
//  PhotoChooserViewController.m
//  Handla
//
//  Created by Emil Johansson on 12/4/11.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "PhotoChooserViewController.h"

@implementation PhotoChooserViewController

@synthesize delegate;
@synthesize newImage;
@synthesize image;

- (id)initWithImage:(UIImage*)photo canChange:(BOOL)change {
    if (self = [super init]) {
		canChange = change;
		image = photo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (image) {
		imageView.image = image;
	}
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[cameraButton setEnabled:NO];
		[cameraButton setHidden:YES];
	}
	if (!canChange) {
		[cameraButton setEnabled:NO];
		[cameraButton setHidden:YES];
		[galleryButton setEnabled:NO];
		[galleryButton setHidden:YES];
	}
}

- (IBAction)getPhoto:(id)sender {
	UIImagePickerControllerSourceType source = (sender == cameraButton
												? UIImagePickerControllerSourceTypeCamera
												: UIImagePickerControllerSourceTypeSavedPhotosAlbum);
	
	if ([UIImagePickerController isSourceTypeAvailable:source]) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.sourceType = source;
		picker.delegate = self;
		[self presentModalViewController:picker animated:YES];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
	imageView.image = image = [info objectForKey:UIImagePickerControllerOriginalImage];
	newImage = YES;
}

- (IBAction)goBack {
	if (self.delegate) {
		[self.delegate photoChooserDone:self]; 
	} else {
		[self.parentViewController dismissModalViewControllerAnimated:YES];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[cameraButton release], cameraButton = nil;
	[galleryButton release], galleryButton = nil;
	[imageView release], imageView = nil;
}


- (void)dealloc {
	[cameraButton release];
	[galleryButton release];
	[imageView release];
    [super dealloc];
}


@end
