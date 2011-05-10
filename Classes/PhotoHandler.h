//
//  PhotoHandler.h
//  Handla
//
//  Created by Fredrik Gustafsson on 5/10/11.
//  Copyright 2011 iGroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article.h"

@interface PhotoHandler : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIViewController *controller;
    Article *article_;
    UIImage *image;
    BOOL newPhoto;
}

- (id)initWithViewController:(UIViewController*)viewController article:(Article*)article;
- (void)showAlternatives;

@property (nonatomic,retain) UIViewController *controller;
@property (nonatomic,retain) Article *article_;
@property (nonatomic,retain) UIImage *image;

@end
