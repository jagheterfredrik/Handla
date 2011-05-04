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
	if ((self = [super init])) {
		fileManager = [[NSFileManager alloc] init];
		NSString *library = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		basePath = [[library stringByAppendingPathComponent:@"Photos"] retain];
		if (![fileManager fileExistsAtPath:basePath])
			[fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	return self;
}


#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize;
{  
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }     
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }   
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, DEGREES_TO_RADIANS(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, DEGREES_TO_RADIANS(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, DEGREES_TO_RADIANS(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}

- (UIImage*)readPhoto:(NSString*)name {
	if (!name) return nil;
	NSString *path = filepath(basePath, name);
	if (![fileManager fileExistsAtPath:path])
		return nil;
	return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}

- (UIImage*)readThumbnail:(NSString*)name {
	if (!name) return [UIImage imageNamed:@"NoImage"];
	NSString *path = thumbpath(basePath, name);
	if (![fileManager fileExistsAtPath:path])
		return [UIImage imageNamed:@"NoImage"];
	return [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}

- (NSString*)savePhoto:(UIImage*)photo {
	NSString *name, *path;
	do {
		name = [NSString stringWithFormat:@"%08x", random()];
		path = filepath(basePath, name);
	} while ([fileManager fileExistsAtPath:path]);
    
    UIImage *full = [PhotoUtil imageWithImage:photo scaledToSizeWithSameAspectRatio:CGSizeMake(1024, 768)];
	[UIImagePNGRepresentation(full) writeToFile:path atomically:NO];
	
	//thumbnail
    UIImage *thumbnail = [PhotoUtil imageWithImage:photo scaledToSizeWithSameAspectRatio:CGSizeMake(114, 114)];
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

// Return the singleton instance
+ (PhotoUtil*)instance {
	if (!sharedInstance)
		sharedInstance = [[PhotoUtil alloc] init];
	return sharedInstance;
}

@end
