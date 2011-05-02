//
//  AlertPrompt.h
//  Prompt
//
//  Created by Jeff LaMarche on 2/26/09.
//	Edited by Fredrik Gustafsson on 2/15/11.

#import <Foundation/Foundation.h>

@interface AlertPrompt : UIAlertView <UITextFieldDelegate>
{
    UITextField *textField;
}
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;
- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;
@end