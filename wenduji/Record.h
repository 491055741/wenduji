//
//  Record.h
//  wenduji
//
//  Created by LiPeng on 3/14/15.
//
//

#import <Foundation/Foundation.h>

@interface Record : NSObject
@property NSDate *date;
@property NSNumber *temperature;

//- (id)initWithDate:(NSDate *)date temperature:(NSNumber *)temperature;
+ (id)recordWithDate:(NSDate *)date temperature:(NSNumber *)temperature;

@end
