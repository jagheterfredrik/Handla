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
    IBOutlet UIButton* markButton;
	
	IBOutlet IndividualListTableViewCell *cell;
}

- (id)init;
- (IBAction)changePriceButtonPressed:(UIButton*) sender;
- (IBAction)flipCheckedStatus;


- (void)updateView;


@property (nonatomic,retain) ListArticle *listArticle;

@end
