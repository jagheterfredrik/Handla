//
//  IndividualListTableViewCell.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-03-14.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListArticle.h"
#import "Article.h"

@interface IndividualListTableViewCell : UITableViewCell<UIAlertViewDelegate> {
	ListArticle *listArticle_;
	
	IBOutlet UIButton *thumbnail;
	IBOutlet UIImageView *checkboxImage;
	IBOutlet UILabel *titleLabel;
	IBOutlet UILabel *priceLabel;
	
	IBOutlet IndividualListTableViewCell *cell;
	
	BOOL checked;
}

- (id)init;
- (IBAction)changePriceButtonPressed:(UIButton*) sender;
- (IBAction)decheckPressed:(UIButton*) sender;

@property (nonatomic,retain) ListArticle *listArticle;
@property (nonatomic,assign) BOOL checked;

@end
