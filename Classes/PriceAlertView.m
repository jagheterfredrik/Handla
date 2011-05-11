//
//  PriceAlertView.m
//  Handla
//
//  Created by Fredrik Gustafsson on 5/6/11.
//  Copyright 2011 iGroup. All rights reserved.
//

#import "PriceAlertView.h"


@implementation PriceAlertView 
@synthesize maxLength;

/**
 * Updates the labels depending on weight or amount unit.
 */
- (void)updateLabels {
    if (weightUnitSwitch.selectedSegmentIndex == 0) {
        priceLabel.text = @"Styckpris:";
        amountLabel.text = @"Antal:";
    } else {
        priceLabel.text = @"Kilopris:";
        amountLabel.text = @"Vikt (kg):";        
    }
}

/**
 * Initializes a UIAlertView and sets it up as a priceWeightView according
 * to the passed in article.
 */
- (id)initWithListArticle:(ListArticle*)listArticle
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSString *title = [NSString stringWithFormat:(listArticle_.price ? @"Ändra pris (%@)" : @"Ändra pris"), [formatter stringFromNumber:listArticle_.price]];
    if ((self = [super initWithTitle:title message:@"\n\n\n\n\n" delegate:self cancelButtonTitle:@"Avbryt" otherButtonTitles:@"Ändra", nil]))
    {
        listArticle_ = [listArticle retain];
        
        //Weight switch
        weightUnitSwitch = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Styckpris", @"Kilopris", nil]];
        weightUnitSwitch.center = CGPointMake(140.f, 65.f);
        weightUnitSwitch.selectedSegmentIndex = 0;
        [self addSubview:weightUnitSwitch];
        weightUnitSwitch.selectedSegmentIndex = [listArticle_.weightUnit boolValue] ? 1 : 0;
        [weightUnitSwitch addTarget:self action:@selector(updateLabels) forControlEvents:UIControlEventValueChanged];
        
        //Price field
        priceField = [[UITextField alloc] initWithFrame:CGRectMake(142.0, 91.0, 120.0, 29.0)]; 
        priceField.borderStyle = UITextBorderStyleRoundedRect;
		priceField.keyboardType = UIKeyboardTypeDecimalPad;
		priceField.keyboardAppearance = UIKeyboardAppearanceAlert;
		priceField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		priceField.autocorrectionType = UITextAutocorrectionTypeNo;
		priceField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		priceField.textAlignment = UITextAlignmentCenter;
        priceField.delegate = self;
        priceField.clearButtonMode = UITextFieldViewModeAlways;
        [self addSubview:priceField];
        
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        priceField.text = [formatter stringFromNumber:listArticle_.price];
        
        // Price label
        priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 25.f)];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.textColor = [UIColor whiteColor];
        priceLabel.center = CGPointMake(priceField.center.x-120, priceField.center.y);
        [self addSubview:priceLabel];
        
        //Amount field
        amountField = [[UITextField alloc] initWithFrame:CGRectMake(142.0, 124.0, 120.0, 29.0)];
        amountField.borderStyle = UITextBorderStyleRoundedRect;
		amountField.keyboardType = UIKeyboardTypeDecimalPad;
		amountField.keyboardAppearance = UIKeyboardAppearanceAlert;
		amountField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		amountField.autocorrectionType = UITextAutocorrectionTypeNo;
		amountField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		amountField.textAlignment = UITextAlignmentCenter;
        amountField.delegate = self;
        amountField.clearButtonMode = UITextFieldViewModeAlways;

        amountField.text = (listArticle_.price ? [formatter stringFromNumber:listArticle_.amount] : @"1");
        [self addSubview:amountField];
        
        //Amount label
        amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 25.f)];
        amountLabel.backgroundColor = [UIColor clearColor];
        amountLabel.textColor = [UIColor whiteColor];
        amountLabel.center = CGPointMake(amountField.center.x-120, amountField.center.y);
        [self addSubview:amountLabel];
        
        //Update displays
        [self updateLabels];
        
        //Max length of inputs
        maxLength = 7;
    }
    [formatter release];
    return self;
}

/**
 * Prevents too long input, as specified by maxLength.
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
    [priceField becomeFirstResponder];
    [super show];
}

/**
 * Handles updating the article when pressing OK.
 */
- (void)alertView:(PriceAlertView *)alertPrompt clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1 && [alertPrompt.enteredPrice length] != 0) { //TODO: Better test
		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setGeneratesDecimalNumbers:YES];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		listArticle_.price = (NSDecimalNumber*)[f numberFromString:alertPrompt.enteredPrice];
        listArticle_.article.lastWeightUnit = listArticle_.weightUnit = [NSNumber numberWithBool:alertPrompt.enteredWeightUnit];
        if (!alertPrompt.enteredWeightUnit) {
            [f setNumberStyle:NSNumberFormatterRoundFloor];
        }
        listArticle_.amount = (NSDecimalNumber*)[f numberFromString:alertPrompt.enteredAmount];
        listArticle_.article.lastPrice = listArticle_.price;
		listArticle_.timeStamp = [NSDate date];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ListArticleChanged" object:nil];
		[f release];
	}
}

/**
 * Retireves the text entered in the text field.
 */
- (NSString *)enteredPrice
{
    return priceField.text;
}

/**
 * The amount entered.
 */
- (NSString *)enteredAmount
{
    return amountField.text;
}

/**
 * The unittype selected.
 */
- (BOOL)enteredWeightUnit
{
    return (weightUnitSwitch.selectedSegmentIndex == 1);
}

- (void)dealloc
{
    [weightUnitSwitch release];
    [priceField release];
    [amountField release];
    [listArticle_ release];
    [super dealloc];
}
@end