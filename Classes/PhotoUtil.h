//
//  PhotoUtil.h
//  Handla
//
//  Created by Emil Johansson on 15/4/11.
//  Copyright 2011 KTH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhotoUtil : NSObject {
	NSFileManager *fileManager;
	NSString *basePath;
}

+ (PhotoUtil*)instance;

- (UIImage*)readPhoto:(NSString*)name;
- (UIImage*)readThumbnail:(NSString*)name;
- (NSString*)savePhoto:(UIImage*)photo;
- (void)deletePhoto:(NSString*)name;

@end
