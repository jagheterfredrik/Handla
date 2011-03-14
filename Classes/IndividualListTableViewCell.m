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

- (id)initWithListArticle:(ListArticle*)listArticle reuseIdentifier:(NSString*)reuseIdentifier {
	[[NSBundle mainBundle] loadNibNamed:@"IndividualListCell" owner:self options:nil];
	cell.listArticle = listArticle;
    return cell;
}

- (void)setListArticle:(ListArticle *)listArticle {
	titleLabel.text = listArticle.article.name;
	priceLabel.text = listArticle.price;
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
