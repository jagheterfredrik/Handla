//
//  IndividualListTableViewCell.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-03-14.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "IndividualListTableViewCell.h"
#import "AlertPrompt.h"
#import "PhotoUtil.h"

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
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    NSString *title;
    if (listArticle_.price) {
        title = [NSString stringWithFormat:@"Nytt pris (%@):",[formatter stringFromNumber:listArticle_.price]];
    } else {
        title = @"Nytt pris:";
    }
    
    [formatter release];
    
	AlertPrompt *alertPrompt = [[AlertPrompt alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Avbryt" okButtonTitle:@"Ändra"];
	alertPrompt.textField.keyboardType=UIKeyboardTypeDecimalPad;
	[alertPrompt show];
	[alertPrompt release];
}

- (IBAction)imagePressed {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ListCellImagePressed" object:self.listArticle];
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
        priceLabel.text = [formatter stringFromNumber:listArticle_.price];
        priceLabel.textColor = [UIColor blackColor];
    }
    else{
        priceLabel.text = @"? kr";
        priceLabel.textColor = [UIColor redColor];
    }
	
	if (self.listArticle.article.picture) {
		[thumbnail setImage:[[PhotoUtil instance] readThumbnail:self.listArticle.article.picture] forState:UIControlStateNormal];
		thumbnail.adjustsImageWhenHighlighted = NO;
	}
	
    [formatter release];
    
    if ([self.listArticle.checked boolValue]) {
        thumbnail.alpha = 0.2f;
        checkboxImage.alpha = 1.f;
    } else {
        thumbnail.alpha = 1.f;
        checkboxImage.alpha = 0.f;
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
        listArticle_.article.lastPrice = listArticle_.price;
		listArticle_.timeStamp = [NSDate date];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ListArticleChanged" object:nil];
		[f release];
	}
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[listArticle_ release];
    [super dealloc];
}


@end
