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
		NSLog(@"path: %@", basePath);
	}
	return self;
}

- (UIImage*)readPhoto:(NSString*)name {
	if (!name) return nil;
	NSLog(@"read: %@", name);
	NSString *path = filepath(basePath, name);
	if (![fileManager fileExistsAtPath:path])
		return nil;
	return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}

- (UIImage*)readThumbnail:(NSString*)name {
	//TODO: create and return real thumbnail
	NSLog(@"thumb");
	return [self readPhoto:name];
}

- (NSString*)savePhoto:(UIImage*)photo {
	NSString *name, *path;
	do {
		name = [NSString stringWithFormat:@"%08x", random()];
		path = filepath(basePath, name);
	} while ([fileManager fileExistsAtPath:path]);
	NSLog(@"create: %@", name);
	[UIImageJPEGRepresentation(photo, 0.7f) writeToFile:path atomically:NO];
	return name;
}

- (void)deletePhoto:(NSString*)name {
	if (!name) return;
	NSLog(@"delete: %@", name);
	NSString *path = filepath(basePath, name);
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
