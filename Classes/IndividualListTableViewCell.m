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

- (id)init {
	[[NSBundle mainBundle] loadNibNamed:@"IndividualListCell" owner:self options:nil];
    return cell;
}

- (void)setListArticle:(ListArticle *)listArticle {
	[listArticle_ release];
	listArticle_ = [listArticle retain];
    [self updateView];
}

- (IBAction)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

- (IBAction)changePriceButtonPressed:(UIButton*) sender{
	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:@"Nytt pris:" delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Ändra"];
	alertPrompt.textField.keyboardType=UIKeyboardTypeDecimalPad;
	[alertPrompt show];
	[alertPrompt release];
}

/**
 *  Updates the title, price and image to the 
 *  information available for the current
 *  ListArticle.
 */
-(void)updateView{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[self layoutSubviews];
    titleLabel.text = self.listArticle.article.name;
    if (self.listArticle.price != nil) {
        priceLabel.text = [formatter stringFromNumber:self.listArticle.price];
        priceLabel.textColor = [UIColor blackColor];
    }
    else{
        priceLabel.text = @"? kr";
        priceLabel.textColor = [UIColor redColor];
    }
	
    [formatter release];
    if ([self.listArticle.checked boolValue]) {
        thumbnail.alpha = 0.2f;
        checkboxImage.alpha = 1.f;
        //TODO:Kom på bra knapptext
        //markButton.titleLabel.text = @"";
    } else {
        thumbnail.alpha = 1.f;
        checkboxImage.alpha = 0.f;
        //TODO:Kom på bra knapptext
        //markButton.titleLabel.text = @"";
    }
}

- (IBAction)flipCheckedStatus{
    if ([self.listArticle.checked boolValue]==YES) {
        [self.listArticle setChecked:[NSNumber numberWithBool:NO]];
    } else {
        [self.listArticle setChecked:[NSNumber numberWithBool:YES]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ListArticleChanged" object:nil];
    [self updateView];
}
#pragma mark -
#pragma mark Alert prompt delegate

#define alertViewButtonOK 1

- (void)alertView:(AlertPrompt *)alertPrompt clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == alertViewButtonOK && [alertPrompt.textField.text length] != 0) { //TODO: Better test
		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setGeneratesDecimalNumbers:YES];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		listArticle_.price = (NSDecimalNumber*)[f numberFromString:alertPrompt.textField.text];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ListArticleChanged" object:nil];
		[f release];
	}
}


- (void)dealloc {
	[listArticle_ release];
    [super dealloc];
}


@end
