//
//  PriceAlertView.h
//  Handla
//
//  Created by Fredrik Gustafsson on 5/6/11.
//  Copyright 2011 iGroup. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PriceAlertView : UIAlertView <UITextFieldDelegate>
{
    UITextField *textField;
}
@property (nonatomic, assign) NSInteger maxLength;
@property (nonatomic, retain) UITextField *textField;
@property (readonly) NSString *enteredText;
- (id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;
@end
