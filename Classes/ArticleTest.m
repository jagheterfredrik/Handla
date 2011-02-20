//
//  ArticleTest.m
//  Handla
//
//  Created by Fredrik on 2/19/11.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import "TestingConstants.m"

/**
 *
 * Unit tests for Articles.
 * 
 */

@interface ArticleTest : GHTestCase {
}
/** Tests insertion of objects into a list */
- (void)testInsertion;
/** Tests removal of objects from a list */
- (void)testRemoval;
/** Ran before each test */
- (void)setUp;
/** Ran after each test */
- (void)tearDown;
@end



@implementation ArticleTest

-(void)setUp
{
}

-(void)tearDown
{	
}

- (void)testInsertion {
    Assert(YES, @"Description of failure");
}

- (void)testRemoval {
    Assert(YES, @"Description of failure");
}

@end