/**
 * Copyright (c) 2011 Muh Hon Cheng
 * Created by honcheng on 28/4/11.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2011	Muh Hon Cheng
 * @version
 * 
 */

#import "PCPieChart.h"

@implementation PCPieComponent
@synthesize value, colour, startDeg, endDeg;

- (id)initWithValue:(float)_value
{
    self = [super init];
    if (self)
    {
        self.value = _value;
        self.colour = PCColorDefault;
    }
    return self;
}

+ (id)pieComponentWithValue:(float)_value
{
    return [[[super alloc] initWithValue:_value] autorelease];
}

- (NSString*)description
{
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"value: %f\n", self.value];
    return text;
}

@end

@implementation PCPieChart
@synthesize  components;
@synthesize diameter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
		
	}
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    float margin = 15;
    if (self.diameter==0)
    {
        diameter = MIN(rect.size.width, rect.size.height) - 2*margin;
    }
    float x = (rect.size.width - diameter)/2;
    float y = (rect.size.height - diameter)/2;
    float gap = 1;
    float inner_radius = diameter/2;
    float origin_x = x + diameter/2;
    float origin_y = y + diameter/2;
    
    
    if ([components count]>0)
    {
        
        float total = 0;
        for (PCPieComponent *component in components)
        {
            total += component.value;
        }
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
		UIGraphicsPushContext(ctx);
		CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);  // white color
		CGContextSetShadow(ctx, CGSizeMake(0.0f, 0.0f), margin);
		CGContextFillEllipseInRect(ctx, CGRectMake(x, y, diameter, diameter));  // a white filled circle with a diameter of 100 pixels, centered in (60, 60)
		UIGraphicsPopContext();
		CGContextSetShadow(ctx, CGSizeMake(0.0f, 0.0f), 0);
		
		float nextStartDeg = 0;
		float endDeg = 0;
		NSMutableArray *tmpComponents = [NSMutableArray array];
		int last_insert = -1;
		for (int i=0; i<[components count]; i++)
		{
			PCPieComponent *component  = [components objectAtIndex:i];
			float perc = [component value]/total;
			endDeg = nextStartDeg+perc*360;
			
			CGContextSetFillColorWithColor(ctx, [component.colour CGColor]);
			CGContextMoveToPoint(ctx, origin_x, origin_y);
			CGContextAddArc(ctx, origin_x, origin_y, inner_radius, (nextStartDeg-90)*M_PI/180.0, (endDeg-90)*M_PI/180.0, 0);
			CGContextClosePath(ctx);
			CGContextFillPath(ctx);
			
			CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
			CGContextSetLineWidth(ctx, gap);
			CGContextMoveToPoint(ctx, origin_x, origin_y);
			CGContextAddArc(ctx, origin_x, origin_y, inner_radius, (nextStartDeg-90)*M_PI/180.0, (endDeg-90)*M_PI/180.0, 0);
			CGContextClosePath(ctx);
			CGContextStrokePath(ctx);
			
			[component setStartDeg:nextStartDeg];
			[component setEndDeg:endDeg];
			if (nextStartDeg<180)
			{
				[tmpComponents addObject:component];
			}
			else
			{
				if (last_insert==-1)
				{
					last_insert = i;
					[tmpComponents addObject:component];
				}
				else
				{
					[tmpComponents insertObject:component atIndex:last_insert];
				}
			}
			
			nextStartDeg = endDeg;
		}
    }
	
	
}

- (void)dealloc
{
    [components release];
    [super dealloc];
}


@end
