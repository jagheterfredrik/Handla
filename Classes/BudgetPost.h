//
//  BudgetPost.h
//  Handla
//
//  Created by Fredrik Gustafsson on 2011-02-15.
//  Copyright 2011 Kungliga Tekniska Högskolan. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface BudgetPost :  NSManagedObject  
{
}

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSManagedObject * list;

@end



