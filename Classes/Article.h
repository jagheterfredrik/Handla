//
//  Article.h
//  Handla
//
//  Created by Fredrik Gustafsson on 5/6/11.
//  Copyright (c) 2011 iGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ListArticle;

@interface Article : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * lastWeightUnit;
@property (nonatomic, retain) NSString * barcode;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDecimalNumber * lastPrice;
@property (nonatomic, retain) NSSet* listArticles;

@end
