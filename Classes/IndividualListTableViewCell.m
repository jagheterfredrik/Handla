//
//  IndividualListTableViewCell.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-03-14.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "IndividualListTableViewCell.h"
#import "PriceAlertView.h"
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
	PriceAlertView *alertPrompt = [[PriceAlertView alloc] initWithListArticle:listArticle_];
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
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:20];
    
    for(int i = 20; i > 10; --i)
    {
        font = [font fontWithSize:i];
        
        CGSize constraintSize = CGSizeMake(123.0f, MAXFLOAT);
        CGSize labelSize = [titleLabel.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        if(labelSize.height <= 37.0f)
            break;
    }
    
    titleLabel.font = font;
    
    if (self.listArticle.price) {
        priceLabel.text = [formatter stringFromNumber:[listArticle_.amount decimalNumberByMultiplyingBy:listArticle_.price]];
        priceLabel.textColor = [UIColor blackColor];
    }
    else{
        priceLabel.text = @"? kr";
        priceLabel.textColor = [UIColor redColor];
    }
	
    [thumbnail setImage:[[PhotoUtil instance] readThumbnail:self.listArticle.article.picture] forState:UIControlStateNormal];
    thumbnail.adjustsImageWhenHighlighted = NO;
    
    if ([self.listArticle.weightUnit boolValue]) {
        if (self.listArticle.amount && !self.listArticle.price) {
            descriptionLabel.text = [NSString stringWithFormat:@"%.2f kg", [self.listArticle.amount doubleValue]];
        } else {
            descriptionLabel.text = [NSString stringWithFormat:@"%.2f kg á %@/kg", [self.listArticle.amount doubleValue], [formatter stringFromNumber:self.listArticle.price]];
        }
    } else {
        if (self.listArticle.amount && !self.listArticle.price) {
            descriptionLabel.text = [NSString stringWithFormat:@"%i st", [self.listArticle.amount intValue]];
        } else {
            descriptionLabel.text = [NSString stringWithFormat:@"%i st á %@/st", [self.listArticle.amount intValue], [formatter stringFromNumber:self.listArticle.price]];
        }
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

/*
 * This should be called when checking off an article. Increases a counter which when >0 enables "green flash" animations on the cell.
 */
-(void)wasChecked{
    shouldFlash++;  
}

/*
 * Overrides super method, to enable colored background.
 */
- (void)layoutSubviews { 
    [super layoutSubviews]; 
    if ([self.listArticle.checked boolValue]) {
        if (shouldFlash){//self.backgroundColor!=[UIColor colorWithRed:0.97f green:1.0f blue:0.97f alpha:1.f]) {
            [self setBackgroundColor:[UIColor colorWithRed:0.18f green:0.93f blue:0.29f alpha:1.0f]];
            [UIView animateWithDuration:0.2f
                                  delay:0.f
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 [self setBackgroundColor:[UIColor colorWithRed:0.96f green:1.0f blue:0.96f alpha:1.f]];
                             } completion:nil];
            shouldFlash--;
        }
        else {
            [self setBackgroundColor:[UIColor colorWithRed:0.96f green:1.0f blue:0.96f alpha:1.f]];
        }
    }
    else
    {
       [self setBackgroundColor:[UIColor whiteColor]];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[listArticle_ release];
    [super dealloc];
}


@end
