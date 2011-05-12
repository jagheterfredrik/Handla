//
//  PhotoHandler.m
//  Handla
//
//  Created by Fredrik Gustafsson on 5/10/11.
//  Copyright 2011 iGroup. All rights reserved.
//

#import "PhotoHandler.h"
#import "PhotoUtil.h"
#import "UIImagePickerSingleton.h"
#import "UIActionSheet+Blocks.h"
#import "DSActivityView.h"

@implementation PhotoHandler

@synthesize controller, article_, image;

- (id)initWithViewController:(UIViewController*)viewController article:(Article*)article
{
    self = [super init];
    if (self) {
        self.controller = viewController;
        self.article_ = article;
    }
    return self;
}

- (void)dealloc
{
    [controller release];
    [article_ release];
    [image release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Own stuff

- (void)doClose {
    [DSBezelActivityView removeViewAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ArticleChanged" object:nil];
}

- (void)updatePicture {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (article_.picture)
        [[PhotoUtil instance] deletePhoto:article_.picture];
    if (self.image) {
        NSString *new = [[PhotoUtil instance] savePhoto:self.image];
        article_.picture = new;
    } else {
        [[PhotoUtil instance] deletePhoto:article_.picture];
        article_.picture = nil;
    }
    [self performSelectorOnMainThread:@selector(doClose) withObject:nil waitUntilDone:NO];
    [pool drain];
}

#pragma mark - Image Picker delegate

- (void) imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    self.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    newPhoto = YES;
    [DSBezelActivityView newActivityViewForView:controller.view.superview.superview withLabel:@"Sparar..."];
    [self performSelectorInBackground:@selector(updatePicture) withObject:nil];
    reader.delegate = nil;
    [reader dismissModalViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)showAlternatives {
    RIButtonItem *delete = [RIButtonItem itemWithLabel:@"Ta bort bild"];
    delete.action = ^
    {
        if (article_.picture) {
            image = nil;
            newPhoto = YES;
            [self updatePicture];
        }
    };
    
    RIButtonItem *takeNew = [RIButtonItem itemWithLabel:@"Ta ny bild med kamera"];
    takeNew.action = ^
    {
        UIImagePickerController *imagePicker = [UIImagePickerSingleton sharedInstance];
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ingen kamera tillgänglig" message:@"Funktionen kräver att din enhet har en kamera" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        [self.controller presentModalViewController:imagePicker animated:YES];
    };
    
    RIButtonItem *pickOld = [RIButtonItem itemWithLabel:@"Välj befintlig bild"];
    pickOld.action = ^
    {
        UIImagePickerController *imagePicker = [UIImagePickerSingleton sharedInstance];
        imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        [self.controller presentModalViewController:imagePicker animated:YES];
    };
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Välj åtgärd" cancelButtonItem:[RIButtonItem itemWithLabel:@"Avbryt"]destructiveButtonItem:nil otherButtonItems:takeNew, pickOld, nil];
    if (controller && controller.view && controller.view.window) {
        [sheet showInView:controller.view.window];
    }
    [sheet release];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
