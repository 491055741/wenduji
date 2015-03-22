/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

@interface KalDate : NSObject
{
    struct {
        unsigned int month : 4;
        unsigned int day : 5;
        unsigned int year : 15;
    } a;
    
    struct {
        unsigned int hour : 5;
        unsigned int minute : 6;
    } b;
}

+ (KalDate *)dateForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year;
+ (KalDate *)dateFromNSDate:(NSDate *)date;

+ (KalDate *)dateForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year hour:(unsigned int)hour minute:(unsigned int)minute;
+ (KalDate *)timeFromNSDate:(NSDate *)date;

- (id)initForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year;
- (id)initForDay:(unsigned int)minute hour:(unsigned int)hour day:(unsigned int)day month:(unsigned int)month year:(unsigned int)year;

- (void)setTime:(unsigned int)hour minute:(unsigned int)minute;
- (void)setMinute:(unsigned int)minute;
- (void)setHour:(unsigned int)hour;

- (unsigned int)day;
- (unsigned int)month;
- (unsigned int)year;
- (unsigned int)hour;
- (unsigned int)minute;

- (NSDate *)NSDate;
- (NSComparisonResult)compare:(KalDate *)otherDate;
- (BOOL)isToday;
- (KalDate *)nextDay;    // For selecting sereral tiles;
- (KalDate *)previousDay;      //For selecting several tiles;
- (int)daysIntervalSinceDate:(KalDate *)otherDate;
- (NSString *)chineseDescription;
- (NSString *)chineseDescription2;
- (NSString *)description;
- (NSString *)timeDescription;
- (NSString *)fullDescription;
- (NSString *)monthDayDescription;
- (NSString *)weekDescription;
- (NSString *)weekMonthDayDescription;

@end
