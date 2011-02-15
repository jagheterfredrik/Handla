//
//  ExampleTestCase.m
//  Handla
//
//  Created by Fredrik Henriques on 2/15/11.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "TestingConstants.m"


@interface ExampleTestCase : GHTestCase {
	int number;
}
- (void)testMath;
- (void)setUp;
@end



@implementation ExampleTestCase

-(void)setUp
{
	number = 100;
}
- (void)testMath {
    GHAssertTrue((number*2) == 200, @"100*2 != 200? right...");
}

@end
