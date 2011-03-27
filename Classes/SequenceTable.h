//
//  SequenceTable.h
//  Handla
//
//  Created by Fredrik Gustafsson on 3/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SequenceTable : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * seq;

@end
