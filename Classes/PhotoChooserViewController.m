//
//  PhotoChooserViewController.m
//  Handla
//
//  Created by Emil Johansson on 12/4/11.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "PhotoChooserViewController.h"

#import "PhotoUtil.h"

#import "DSActivityView.h"

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
    [DSWhiteActivityView removeView];
}

- (void)doThreadcall {
    [self performSelectorInBackground:@selector(loadHighResolution) withObject:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (isInitialized) {
        return;
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
		imageView.image = image;
        
        [DSWhiteActivityView newActivityViewForView:imageView withLabel:@"Laddar..."];
        
        [self performSelector:@selector(doThreadcall) withObject:nil afterDelay:0.01f];
	}
    
    isInitialized = YES;
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:NO];
	imageView.image = image = [info objectForKey:UIImagePickerControllerOriginalImage];
	newImage = YES;
    [picker release];
    [self performSelectorOnMainThread:@selector(goBack) withObject:nil waitUntilDone:NO];
}

- (IBAction)goBack {
	if (self.delegate) {
		[self.delegate photoChooserDone:self]; 
	} else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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