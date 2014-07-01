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
        self.alertViewStyle = UIAlertViewStylePlainTextInput;
        [self textFieldAtIndex:0].placeholder = @"";
        maxLength = 50;
    }
    return self;
}

/**
 *  Prevents the AlertPrompt from returning empty if clicking OK.
 */
-(void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    if ([textField.text length] == 0 && buttonIndex == alertPromptButtonOK) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Någonting måste anges" delegate:nil cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles: nil];
        [sheet showInView:self.window];
        [sheet release];
        return;
    } else {
        [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    }
}

/**
 *  Prevents the input to be too long. As specified by maxLength.
 */
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
    return [self textFieldAtIndex:0].text;
}

- (void)dealloc
{
    [super dealloc];
    [textField release];
}
@end
