//
//  PriceAlertView.m
//  Handla
//
//  Created by Fredrik Gustafsson on 5/6/11.
//  Copyright 2011 iGroup. All rights reserved.
//

#import "PriceAlertView.h"


@implementation PriceAlertView 
@synthesize textField;
@synthesize enteredText;
@synthesize maxLength;

/**
 * Initializes a UIAlertView and adds a UITextField to it.
 */
- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
	
    if ((self = [super initWithTitle:title message:@"\n\n\n\n\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil]))
    {
        UISegmentedControl *theSwitch = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Styckpris", @"Kilopris", nil]];
        theSwitch.center = CGPointMake(140.f, 70.f);
        theSwitch.selectedSegmentIndex = 0;
        [self addSubview:theSwitch];
        [theSwitch release];
        
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 125.0, 260.0, 25.0)];
        theTextField.textColor = [UIColor whiteColor];
		theTextField.keyboardType = UIKeyboardTypeAlphabet;
		theTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		theTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		theTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		theTextField.textAlignment = UITextAlignmentCenter;
        theTextField.delegate = self;
        [self addSubview:theTextField];
        self.textField = theTextField;
        [theTextField release];
        
        
        UITextField *thePriceField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 100.0, 260.0, 25.0)]; 
        thePriceField.textColor = [UIColor whiteColor];
		thePriceField.keyboardType = UIKeyboardTypeAlphabet;
		thePriceField.keyboardAppearance = UIKeyboardAppearanceAlert;
		thePriceField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		thePriceField.autocorrectionType = UITextAutocorrectionTypeNo;
		thePriceField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		thePriceField.textAlignment = UITextAlignmentCenter;
        thePriceField.delegate = self;
        [self addSubview:thePriceField];
        self.textField = thePriceField;
        [thePriceField release];
        
        
        
        maxLength = 50;
    }
    return self;
}

- (BOOL)textField:(UITextField *)textField_ shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField_.text length] + [string length] - range.length;
    return (newLength > maxLength) ? NO : YES;
}

/**
 * Shows the alert prompt.
 */
- (void)show
{
    [textField becomeFirstResponder];
    [super show];
}

/**
 * Retireves the text entered in the text field.
 */
- (NSString *)enteredText
{
    return textField.text;
}
- (void)dealloc
{
    [textField release];
    [super dealloc];
}
@end