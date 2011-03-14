//
//  IndividualListTableViewCell.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-03-14.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "IndividualListTableViewCell.h"
#import "AlertPrompt.h"


@implementation IndividualListTableViewCell
@synthesize listArticle=listArticle_;

- (id)initReuseIdentifier:(NSString*)reuseIdentifier {
	[[NSBundle mainBundle] loadNibNamed:@"IndividualListCell" owner:self options:nil];
    return cell;
}

- (void)setListArticle:(ListArticle *)listArticle {
	[listArticle_ release];
	listArticle_ = [listArticle retain];
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	titleLabel.text = listArticle.article.name;
	priceLabel.text = [formatter stringFromNumber:listArticle.price];
	[formatter release];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (IBAction)changePriceButtonPressed:(UIButton*) sender{
	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Nytt pris:" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Ändra"];
	alertPrompt.textField.keyboardType=UIKeyboardTypeDecimalPad;
	
	[alertPrompt show];
	[alertPrompt release];
}

#pragma mark -
#pragma mark Alert prompt delegate

#define alertViewButtonOK 1

- (void)alertView:(AlertPrompt *)alertPrompt clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"%d", buttonIndex);
	if (buttonIndex == alertViewButtonOK && [alertPrompt.textField.text length] != 0) { //TODO: Better test
		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setGeneratesDecimalNumbers:YES];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		listArticle_.price = (NSDecimalNumber*)[f numberFromString:alertPrompt.textField.text];
		[f release];
	}
}


- (void)dealloc {
	[listArticle_ release];
    [super dealloc];
}


@end
