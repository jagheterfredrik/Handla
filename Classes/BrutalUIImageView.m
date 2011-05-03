//
//  UIBrutalViewController.m
//  Handla
//
//  Created by Fredrik Gustafsson on 5/3/11.
//  Copyright 2011 KTH. All rights reserved.
//

#import "BrutalUIImageView.h"

@implementation BrutalUIImageView
@synthesize image;

- (void)setImage:(UIImage *)anImage {
    [image autorelease];
    image = [anImage retain];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [image drawInRect:rect];
}

- (void)dealloc {
    [image release];
    [super dealloc];
}

@end