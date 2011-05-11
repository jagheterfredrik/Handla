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
@synthesize maxLength;

/**
 * Initializes a UIAlertView and adds a UITextField to it.
 */
- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
	
    if ((self = [super initWithTitle:title message:@"\n" delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil]))
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
        theTextField.delegate = self;
        [self addSubview:theTextField];
        self.textField = theTextField;
        [theTextField release];
        maxLength = 50;
    }
    return self;
}

-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    if ([textField.text length] == 0 && buttonIndex == 1) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Någonting måste anges" delegate:nil cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles: nil];
        [sheet showInView:self.window];
        [sheet release];
    } else {
        [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    }
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
