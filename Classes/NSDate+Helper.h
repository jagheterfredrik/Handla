/*
 * Created for Handla! by Fredrik Gustafsson
 */

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

- (NSDate *)beginningOfYear;
- (NSDate *)endOfYear;

- (NSDate *)beginningOfMonth;
- (NSDate *)endOfMonth;

- (NSDate *)beginningOfWeek;
- (NSDate *)endOfWeek;

- (NSDate *)beginningOfDay;
- (NSDate *)endOfDay;

@end