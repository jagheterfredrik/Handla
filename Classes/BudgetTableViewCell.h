//
//  BudgetTableViewCell.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-21.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BudgetTableViewCell : UITableViewCell {
	IBOutlet UIImageView *symbolView;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *priceLabel;
}

@property (nonatomic,readonly) IBOutlet UIImageView *symbolView;
@property (nonatomic,readonly) IBOutlet UILabel *nameLabel;
@property (nonatomic,readonly) IBOutlet UILabel *dateLabel;
@property (nonatomic,readonly) IBOutlet UILabel *priceLabel;

@end
