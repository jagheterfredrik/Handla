//
//  UIImagePickerSingleton.h
//  Handla
//
//  Created by Fredrik Gustafsson on 5/3/11.
//  Copyright 2011 KTH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImagePickerSingleton : UIImagePickerController {
    
}
+ (UIImagePickerController*)sharedInstance;
@end
