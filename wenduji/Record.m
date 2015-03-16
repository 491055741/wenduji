//
//  Record.m
//  wenduji
//
//  Created by LiPeng on 3/14/15.
//
//

#import "Record.h"

@implementation Record

- (id)init
{
    if (self=[super init]) {
        
    }
    return self;
}

- (id)initWithDate:(NSDate *)date temperature:(NSNumber *)temperature
{
    if (self = [super init]) {
        self.date = [date copy];
        self.temperature = [temperature copy];
    }
    return self;
}

+ (id)recordWithDate:(NSDate *)date temperature:(NSNumber *)temperature
{
    Record *record = [[Record alloc] initWithDate:date temperature:temperature];
    return record;
}

@end