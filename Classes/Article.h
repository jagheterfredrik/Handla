//
//  Article.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Article :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSSet* listArticles;

@end


@interface Article (CoreDataGeneratedAccessors)
- (void)addListArticlesObject:(NSManagedObject *)value;
- (void)removeListArticlesObject:(NSManagedObject *)value;
- (void)addListArticles:(NSSet *)value;
- (void)removeListArticles:(NSSet *)value;

@end

