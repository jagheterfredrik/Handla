//
//  UIImagePickerSingleton.m
//  Handla
//
//  Created by Fredrik Gustafsson on 5/3/11.
//  Copyright 2011 KTH. All rights reserved.
//

#import "UIImagePickerSingleton.h"


@implementation UIImagePickerSingleton

static UIImagePickerController *imagePicker = nil;

+ (UIImagePickerController*)sharedInstance {
    if (imagePicker == nil) {
        imagePicker = [[super alloc] init];
    }
    return imagePicker;
}

@end
