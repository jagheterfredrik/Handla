//
//  PhotoUtil.m
//  Handla
//
//  Created by Emil Johansson on 15/4/11.
//  Copyright 2011 KTH. All rights reserved.
//

#import "PhotoUtil.h"
#import <stdlib.h>
#import "UIImage+Resize.h"

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
	if ((self = [super init])) {
		fileManager = [[NSFileManager alloc] init];
		NSString *library = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		basePath = [[library stringByAppendingPathComponent:@"Photos"] retain];
		if (![fileManager fileExistsAtPath:basePath])
			[fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return self;
}

/**
 * Get the picture form a picture-id.
 */
- (UIImage*)readPhoto:(NSString*)name {
	if (!name) return nil;
	NSString *path = filepath(basePath, name);
	if (![fileManager fileExistsAtPath:path])
		return nil;
	return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}

/**
 * Gets the thumbnail from a picture-id.
 */
- (UIImage*)readThumbnail:(NSString*)name {
	if (!name) return [UIImage imageNamed:@"NoImage"];
	NSString *path = thumbpath(basePath, name);
	if (![fileManager fileExistsAtPath:path])
		return [UIImage imageNamed:@"NoImage"];
	return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}

/**
 * Randomizes a name and save the photo. The photo is downscaled to a smaller version
 * before saved and also a thumbnail is saved.
 */
- (NSString*)savePhoto:(UIImage*)photo {
	NSString *name, *path;
	do {
		name = [NSString stringWithFormat:@"%08x", random()];
		path = filepath(basePath, name);
	} while ([fileManager fileExistsAtPath:path]);
    
    UIImage *full = [photo resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(1024, 768) interpolationQuality:kCGInterpolationDefault];
	[UIImagePNGRepresentation(full) writeToFile:path atomically:NO];
	
	//thumbnail
    UIImage *thumbnail = [photo thumbnailImage:114 interpolationQuality:kCGInterpolationDefault];
	[UIImagePNGRepresentation(thumbnail) writeToFile:thumbpath(basePath, name) atomically:NO];
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

/**
 * Returns a singleton instance.
 */
+ (PhotoUtil*)instance {
	if (!sharedInstance)
		sharedInstance = [[PhotoUtil alloc] init];
	return sharedInstance;
}

@end
