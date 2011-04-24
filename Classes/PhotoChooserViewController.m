//
//  PhotoChooserViewController.m
//  Handla
//
//  Created by Emil Johansson on 12/4/11.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "PhotoChooserViewController.h"

#import "PhotoUtil.h"

@implementation PhotoChooserViewController

@synthesize delegate;
@synthesize newImage;
@synthesize image;

- (id)initWithImage:(NSString*)photo canChange:(BOOL)change {
    if ((self = [super init])) {
		canChange = change;
        picture_str = photo;
		image = [[PhotoUtil instance] readThumbnail:photo];
    }
    return self;
}

- (void)loadHighResolution {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    UIImage *img = [[PhotoUtil instance] readPhoto:picture_str];
    image = img;
    imageView.image = image;
    [pool release];
    [indicator stopAnimating];
    loading.hidden = YES;
}

- (void)doThreadcall {
    [self performSelectorInBackground:@selector(loadHighResolution) withObject:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (image) {
        [indicator startAnimating];
		imageView.image = image;
    } else {
        loading.hidden = YES;
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
    if (image) {
        [self performSelector:@selector(doThreadcall) withObject:self afterDelay:0.01f];
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
