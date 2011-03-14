//
//  ListArticle.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-03-14.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Article;
@class List;

@interface ListArticle :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * weightUnit;
@property (nonatomic, retain) Article * article;
@property (nonatomic, retain) List * list;

@end



