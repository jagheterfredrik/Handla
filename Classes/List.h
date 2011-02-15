//
//  List.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BudgetPost;

@interface List :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * lastUsed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* budgetPost;
@property (nonatomic, retain) NSSet* articles;

@end


@interface List (CoreDataGeneratedAccessors)
- (void)addBudgetPostObject:(BudgetPost *)value;
- (void)removeBudgetPostObject:(BudgetPost *)value;
- (void)addBudgetPost:(NSSet *)value;
- (void)removeBudgetPost:(NSSet *)value;

- (void)addArticlesObject:(NSManagedObject *)value;
- (void)removeArticlesObject:(NSManagedObject *)value;
- (void)addArticles:(NSSet *)value;
- (void)removeArticles:(NSSet *)value;

@end

