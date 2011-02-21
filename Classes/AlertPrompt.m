//
//  AlertPrompt.m
//  Prompt
//
//  Created by Jeff LaMarche on 2/26/09.
//	Edited by Fredrik Gustafsson on 2/15/11.

#import "AlertPrompt.h"

@implementation AlertPrompt
@synthesize textField;
@synthesize enteredText;

/**
 * Initializes a UIAlertView and adds a UITextField to it.
 */
- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
	
    if (self = [super initWithTitle:title message:@"\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
        theTextField.backgroundColor = [UIColor clearColor];
		theTextField.textColor = [UIColor whiteColor];
		theTextField.keyboardType = UIKeyboardTypeAlphabet;
		theTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		theTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		theTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		theTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		theTextField.textAlignment = UITextAlignmentCenter;
        [self addSubview:theTextField];
        self.textField = theTextField;
        [theTextField release];
    }
    return self;
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
