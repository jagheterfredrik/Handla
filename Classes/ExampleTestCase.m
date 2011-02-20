//
//  ExampleTestCase.m
//  Handla
//
//  Created by Fredrik Henriques on 2/15/11.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "TestingConstants.m"

/**
 *
 * This class is an example class of how to write unittests. Write (at least) one GHTestCase for each class under testing.
 *
 * All methods that start with test are automatically run during the testing phase.
 *
 * @see http://gabriel.github.com/gh-unit/interface_g_h_test_case.html
 * 
 */

@interface ExampleTestCase : GHTestCase {
	int number;
}
- (void)testMath; /** Runs a math test */
- (void)setUp; /** Ran before each test */
- (void)tearDown; /** Ran after each test */
@end



@implementation ExampleTestCase

-(void)setUp
{
	number = 100;
}
- (void)testMath {
    GHAssertTrue((number*2) == 200, @"100*2 != 200? right...");
}
- (void)tearDown
{	
}

@end
