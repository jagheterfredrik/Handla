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
- (void)testInsertion; /** Tests insertion of objects into a list */
- (void)testRemoval; /** Tests removal of objects from a list */
- (void)setUp; /** Ran before each test */
- (void)tearDown; /** Ran after each test */
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