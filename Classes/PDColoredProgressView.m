//
//  PDColoredProgressView.m
//  PDColoredProgressViewDemo
//
//  Created by Pascal Widdershoven on 03-01-09.
//  Copyright 2009 Pascal Widdershoven. All rights reserved.
//  

#import "PDColoredProgressView.h"

@implementation PDColoredProgressView

- (void) moveProgress
{
    if (self.progress < _targetProgress)
	{
        self.progress = MIN(self.progress + 0.02, _targetProgress);
    }
    else if(self.progress > _targetProgress)
    {
        self.progress = MAX(self.progress - 0.02, _targetProgress);
    }
    else
	{
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
}

- (void) setProgress:(CGFloat)newProgress animated:(BOOL)animated
{
    if (animated)
	{
        _targetProgress = newProgress;
        if (_progressTimer == nil)
		{
            _progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveProgress) userInfo:nil repeats:YES];
        }
    }
	else
	{
        self.progress = newProgress;
    }
}

- (void) dealloc
{
    [super dealloc];
}


@end
