//
//  PriceAlertView.h
//  Handla
//
//  Created by Fredrik Gustafsson on 5/6/11.
//  Copyright 2011 iGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListArticle.h"
#import "Article.h"

@interface PriceAlertView : UIAlertView <UITextFieldDelegate, UIAlertViewDelegate>
{
    UITextField *amountField;
    UITextField *priceField;
    UILabel *priceLabel;
    UILabel *amountLabel;
    UISegmentedControl *weightUnitSwitch;
    ListArticle *listArticle_;
}
@property (nonatomic, assign) NSInteger maxLength;

@property (readonly) NSString *enteredPrice;
@property (readonly) NSString *enteredAmount;
@property (readonly) BOOL enteredWeightUnit;

- (id)initWithListArticle:(ListArticle*)listArticle;
@end
