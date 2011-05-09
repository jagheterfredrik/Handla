//
//  Article.m
//  Handla
//
//  Created by Fredrik Gustafsson on 5/6/11.
//  Copyright (c) 2011 Spotify. All rights reserved.
//

#import "Article.h"
#import "ListArticle.h"


@implementation Article
@dynamic lastWeightUnit;
@dynamic barcode;
@dynamic picture;
@dynamic comment;
@dynamic name;
@dynamic lastPrice;
@dynamic listArticles;

- (void)addListArticlesObject:(ListArticle *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"listArticles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"listArticles"] addObject:value];
    [self didChangeValueForKey:@"listArticles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeListArticlesObject:(ListArticle *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"listArticles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"listArticles"] removeObject:value];
    [self didChangeValueForKey:@"listArticles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addListArticles:(NSSet *)value {    
    [self willChangeValueForKey:@"listArticles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"listArticles"] unionSet:value];
    [self didChangeValueForKey:@"listArticles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeListArticles:(NSSet *)value {
    [self willChangeValueForKey:@"listArticles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"listArticles"] minusSet:value];
    [self didChangeValueForKey:@"listArticles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
