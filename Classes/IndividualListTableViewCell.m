//
//  IndividualListTableViewCell.m
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-03-14.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "IndividualListTableViewCell.h"


@implementation IndividualListTableViewCell
@synthesize listArticle=listArticle_;

- (id)initReuseIdentifier:(NSString*)reuseIdentifier {
	[[NSBundle mainBundle] loadNibNamed:@"IndividualListCell" owner:self options:nil];
    return cell;
}

- (void)setListArticle:(ListArticle *)listArticle {
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


- (void)dealloc {
	[listArticle_ release];
    [super dealloc];
}


@end
