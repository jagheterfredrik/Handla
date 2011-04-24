//
//  PhotoUtil.m
//  Handla
//
//  Created by Emil Johansson on 15/4/11.
//  Copyright 2011 KTH. All rights reserved.
//

#import "PhotoUtil.h"
#import <stdlib.h>

NSString *filepath(NSString *base, NSString *name) {
	return [base stringByAppendingPathComponent:name];
}

NSString *thumbpath(NSString *base, NSString *name) {
	return [base stringByAppendingPathComponent:[name stringByAppendingString:@"t"]];
}

@implementation PhotoUtil

+ (void)initialize {
	srandom(time(NULL));
}

- (id)init {
	if (self = [super init]) {
		fileManager = [[NSFileManager alloc] init];
		NSString *library = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		basePath = [[library stringByAppendingPathComponent:@"Photos"] retain];
		if (![fileManager fileExistsAtPath:basePath])
			[fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return self;
}

- (UIImage*)readPhoto:(NSString*)name {
	if (!name) return nil;
	NSString *path = filepath(basePath, name);
	if (![fileManager fileExistsAtPath:path])
		return nil;
	return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}

- (UIImage*)readThumbnail:(NSString*)name {
	if (!name) return nil;
	NSString *path = thumbpath(basePath, name);
	if (![fileManager fileExistsAtPath:path])
		return nil;
	return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}

- (NSString*)savePhoto:(UIImage*)photo {
	NSString *name, *path;
	do {
		name = [NSString stringWithFormat:@"%08x", random()];
		path = filepath(basePath, name);
	} while ([fileManager fileExistsAtPath:path]);
	[UIImageJPEGRepresentation(photo, 0.7f) writeToFile:path atomically:NO];
	
	//thumbnail
	CGSize size = CGSizeMake(57, 57);
	UIGraphicsBeginImageContext(size);
	[photo drawInRect:CGRectMake(0,0,size.width,size.height)];
	UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	[UIImageJPEGRepresentation(thumbnail, 0.5f) writeToFile:thumbpath(basePath, name) atomically:NO];
	return name;
}

- (void)deletePhoto:(NSString*)name {
	if (!name) return;
	NSString *path = filepath(basePath, name);
	if ([fileManager fileExistsAtPath:path])
		[fileManager removeItemAtPath:path error:NULL];
	path = thumbpath(basePath, name);
	if ([fileManager fileExistsAtPath:path])
		[fileManager removeItemAtPath:path error:NULL];
}


static PhotoUtil *sharedInstance = nil;

// Return the singleton instance
+ (PhotoUtil*)instance {
	if (!sharedInstance)
		sharedInstance = [[PhotoUtil alloc] init];
	return sharedInstance;
}

@end
