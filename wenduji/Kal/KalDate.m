/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalDate.h"
#import "KalPrivate.h"

static KalDate *today;

@implementation KalDate

+ (void)initialize
{
  today = [[KalDate dateFromNSDate:[NSDate date]] retain];
  // TODO set a timer for midnight to recache this value
}

+ (KalDate *)dateForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year
{
  return [[[KalDate alloc] initForDay:day month:month year:year] autorelease];
}

+ (KalDate *)dateForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year hour:(unsigned int)hour minute:(unsigned int)minute
{
    return [[[KalDate alloc] initForDay:minute hour:hour day:day month:month year:year] autorelease];
}

+ (KalDate *)dateFromNSDate:(NSDate *)date
{
  NSDateComponents *parts = [date cc_componentsForMonthDayAndYear];
  return [KalDate dateForDay:[parts day] month:[parts month] year:[parts year]];
}

+ (KalDate *)timeFromNSDate:(NSDate *)date
{
    NSDateComponents *parts = [date cc_componentsForHourAndMinute];
    return [KalDate dateForDay:[parts day] month:[parts month] year:[parts year] hour:[parts hour] minute:[parts minute]];
}

- (id)initForDay:(unsigned int)day month:(unsigned int)month year:(unsigned int)year
{
  if ((self = [super init])) {
    a.day = day;
    a.month = month;
    a.year = year;
  }
  return self;
}

- (id)initForDay:(unsigned int)minute hour:(unsigned int)hour day:(unsigned int)day month:(unsigned int)month year:(unsigned int)year
{
    if ((self = [super init])) {
        a.day = day;
        a.month = month;
        a.year = year;
        b.hour = hour;
        b.minute = minute;
    }
    return self;
}

- (void)setTime:(unsigned int)hour minute:(unsigned int)minute
{
    b.hour = hour;
    b.minute = minute;
}

- (void)setMinute:(unsigned int)minute
{
    b.minute = minute;
}

- (void)setHour:(unsigned int)hour
{
    b.hour = hour;
}

- (unsigned int)day { return a.day; }
- (unsigned int)month { return a.month; }
- (unsigned int)year { return a.year; }
- (unsigned int)hour { return b.hour; }
- (unsigned int)minute { return b.minute; }

- (NSDate *)NSDate
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                              initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];
    [gregorian setLocale:[NSLocale currentLocale]];
//    [gregorian setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]]; // it will cause dead loop when timezone is 'NewYork'
    NSDateComponents *c = [[[NSDateComponents alloc] init] autorelease];
    c.day = a.day;
    c.month = a.month;
    c.year = a.year;
    c.hour = b.hour;
    c.minute = b.minute;
    NSDate *date = [NSDate dateWithTimeInterval:0 sinceDate:[gregorian dateFromComponents:c]];
    [gregorian release];
    return date;
}

- (KalDate *)previousDay      //For selecting several tiles;
{
    NSDate *precedingDay = [[self NSDate] dateByAddingTimeInterval:-24*60*60];
    return [KalDate dateFromNSDate:precedingDay];
}

- (KalDate *)nextDay      //For selecting several tiles;
{
    NSDate *nextDay = [[self NSDate] dateByAddingTimeInterval:24*60*60];
    
    return [KalDate dateFromNSDate:nextDay];
}

- (int)daysIntervalSinceDate:(KalDate *)otherDate
{
    return ([[self NSDate] timeIntervalSinceDate:[otherDate NSDate]] / 60*60*24);
}

- (BOOL)isToday { return [self isEqual:today]; }

- (NSComparisonResult)compare:(KalDate *)otherDate
{
  NSInteger selfComposite = a.year*10000 + a.month*100 + a.day;
  NSInteger otherComposite = [otherDate year]*10000 + [otherDate month]*100 + [otherDate day];
  
  if (selfComposite < otherComposite)
    return NSOrderedAscending;
  else if (selfComposite == otherComposite)
    return NSOrderedSame;
  else
    return NSOrderedDescending;
}

#pragma mark -
#pragma mark NSObject interface

- (id)copyWithZone:(NSZone *)zone 
{
    KalDate *copy = [[[self class] allocWithZone: zone] init];
    copy->a = a;
    copy->b = b;
    return copy;
}

- (BOOL)isEqual:(id)anObject
{
  if (![anObject isKindOfClass:[KalDate class]])
    return NO;
  
  KalDate *d = (KalDate*)anObject;
  return a.day == [d day] && a.month == [d month] && a.year == [d year] && b.hour == [d hour] && b.minute == [d minute];
}

- (NSUInteger)hash
{
  return a.day;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%u/%02u/%02u", a.year, a.month, a.day];
}

- (NSString *)chineseDescription
{
    return [NSString stringWithFormat:@"%u-%02u-%02u", a.year, a.month, a.day];
}

- (NSString *)chineseDescription2
{
    return [NSString stringWithFormat:@"%u月%u日", a.month, a.day];
}

- (NSString *)timeDescription;
{
    return [NSString stringWithFormat:@"%02u:%02u", b.hour, b.minute];
}

- (NSString *)fullDescription
{
    return [NSString stringWithFormat:@"%@ %@", [self chineseDescription], [self timeDescription]];
}

- (NSString *)monthDayDescription
{
    NSString *des = [NSString stringWithFormat:@"%u%@%u%@", a.month, NSLocalizedString(@"月", nil), a.day, NSLocalizedString(@"日", nil)];
    return des;
}

- (NSString *)weekDescription
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE";//@"EEE yyyy/MM/dd";
    NSString *des = [formatter stringFromDate:[self NSDate]];//[NSString stringWithFormat:@"%@ %@", [formatter stringFromDate:[self NSDate]], [self timeDescription]];
    [formatter release];
    return des;
}

- (NSString *)weekMonthDayDescription
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE";
    NSString *temp = [NSString stringWithFormat:@"%@", [formatter stringFromDate:[self NSDate]]];
    [formatter release];
    NSString *des = [NSString stringWithFormat:@"%u%@%u%@ %@", a.month, NSLocalizedString(@"月", nil), a.day, NSLocalizedString(@"日", nil), temp];
    return des;
}

@end
