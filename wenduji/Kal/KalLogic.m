/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalLogic.h"
#import "KalDate.h"
#import "KalPrivate.h"

@interface KalLogic ()
- (void)moveToMonthForDate:(NSDate *)date;
- (void)recalculateVisibleDays;
- (NSUInteger)numberOfDaysInPreviousPartialWeek;
- (NSUInteger)numberOfDaysInFollowingPartialWeek;

@property (nonatomic, retain) NSDate *fromDate;
@property (nonatomic, retain) NSDate *toDate;
@property (nonatomic, retain) NSArray *daysInSelectedMonth;
@property (nonatomic, retain) NSArray *daysInFinalWeekOfPreviousMonth;
@property (nonatomic, retain) NSArray *daysInFirstWeekOfFollowingMonth;

@end

@implementation KalLogic

@synthesize baseDate, fromDate, toDate, daysInSelectedMonth, daysInFinalWeekOfPreviousMonth, daysInFirstWeekOfFollowingMonth, maxSelectDays;

@synthesize minDate, maxDate;


+ (NSSet *)keyPathsForValuesAffectingSelectedMonthNameAndYear
{
    return [NSSet setWithObjects:@"baseDate", nil];
}

- (BOOL)isDateInRange:(NSDate *)date
{
    KalDate *min = [KalDate dateFromNSDate:minDate];
    KalDate *max = [KalDate dateFromNSDate:maxDate];
    KalDate *aim = [KalDate dateFromNSDate:date];
    return [aim compare:min] != NSOrderedAscending && [aim compare:max] != NSOrderedDescending;    
}

- (id)initForDate:(NSDate *)date
{
    if ((self = [super init])) {
        monthAndYearFormatter = [[NSDateFormatter alloc] init];
        [monthAndYearFormatter setDateFormat:NSLocalizedString(@"MMM, YYYY", nil)];

//        [monthAndYearFormatter setTimeStyle:NSDateFormatterNoStyle];
//        [monthAndYearFormatter setDateStyle:NSDateFormatterMediumStyle];
        [monthAndYearFormatter setLocale:[NSLocale currentLocale]];

        NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
        format.dateFormat = @"YYYY-MM-DD";
//        self.minDate = [NSDate dateWithTimeIntervalSince1970]//[NSDate date];
        self.minDate = [format dateFromString:@"2015-01-01"];
        self.maxDate = [NSDate distantFuture];
        [self moveToMonthForDate:date];
    }
    return self;
}

- (id)init
{
    return [self initForDate:[NSDate date]];
}

- (void)moveToMonthForDate:(NSDate *)date
{
    self.baseDate = [date cc_dateByMovingToFirstDayOfTheMonth];
    [self recalculateVisibleDays];
}

- (void)retreatToPreviousMonth
{
    [self moveToMonthForDate:[self.baseDate cc_dateByMovingToFirstDayOfThePreviousMonth]];
}

- (void)advanceToFollowingMonth
{
    [self moveToMonthForDate:[self.baseDate cc_dateByMovingToFirstDayOfTheFollowingMonth]];
}

- (NSString *)selectedMonthNameAndYear;
{
    return [monthAndYearFormatter stringFromDate:self.baseDate];
}

#pragma mark Low-level implementation details

- (NSUInteger)numberOfDaysInPreviousPartialWeek
{
    return ([self.baseDate cc_weekday]==1?8:[self.baseDate cc_weekday]) - 1;
}

- (NSUInteger)numberOfDaysInFollowingPartialWeek
{
    NSDateComponents *c = [self.baseDate cc_componentsForMonthDayAndYear];
    c.day = [self.baseDate cc_numberOfDaysInMonth];
    NSDate *lastDayOfTheMonth = [[NSCalendar currentCalendar] dateFromComponents:c];
    return 7 - ([lastDayOfTheMonth cc_weekday]==7?0:[lastDayOfTheMonth cc_weekday]);
}

- (NSArray *)calculateDaysInFinalWeekOfPreviousMonth
{
    NSMutableArray *days = [NSMutableArray array];
    
    NSDate *beginningOfPreviousMonth = [self.baseDate cc_dateByMovingToFirstDayOfThePreviousMonth];
    int n = [beginningOfPreviousMonth cc_numberOfDaysInMonth];
    int numPartialDays = [self numberOfDaysInPreviousPartialWeek];
    NSDateComponents *c = [beginningOfPreviousMonth cc_componentsForMonthDayAndYear];
    for (int i = n - (numPartialDays - 1); i < n + 1; i++)
        [days addObject:[KalDate dateForDay:i month:c.month year:c.year]];
    
    return days;
}

- (NSArray *)calculateDaysInSelectedMonth
{
    NSMutableArray *days = [NSMutableArray array];
    
    NSUInteger numDays = [self.baseDate cc_numberOfDaysInMonth];
    NSDateComponents *c = [self.baseDate cc_componentsForMonthDayAndYear];
    for (int i = 1; i < numDays + 1; i++)
        [days addObject:[KalDate dateForDay:i month:c.month year:c.year]];
    
    return days;
}

- (NSArray *)calculateDaysInFirstWeekOfFollowingMonth
{
    NSMutableArray *days = [NSMutableArray array];
    
    NSDateComponents *c = [[self.baseDate cc_dateByMovingToFirstDayOfTheFollowingMonth] cc_componentsForMonthDayAndYear];
    NSUInteger numPartialDays = [self numberOfDaysInFollowingPartialWeek];
    
    for (int i = 1; i < numPartialDays + 1; i++)
        [days addObject:[KalDate dateForDay:i month:c.month year:c.year]];
    
    return days;
}

- (void)recalculateVisibleDays
{
    self.daysInSelectedMonth = [self calculateDaysInSelectedMonth];
    self.daysInFinalWeekOfPreviousMonth = [self calculateDaysInFinalWeekOfPreviousMonth];
    self.daysInFirstWeekOfFollowingMonth = [self calculateDaysInFirstWeekOfFollowingMonth];
    KalDate *from = [self.daysInFinalWeekOfPreviousMonth count] > 0 ? [self.daysInFinalWeekOfPreviousMonth objectAtIndex:0] : [self.daysInSelectedMonth objectAtIndex:0];
    KalDate *to = [self.daysInFirstWeekOfFollowingMonth count] > 0 ? [self.daysInFirstWeekOfFollowingMonth lastObject] : [self.daysInSelectedMonth lastObject];
    self.fromDate = [[from NSDate] cc_dateByMovingToBeginningOfDay];
    self.toDate = [[to NSDate] cc_dateByMovingToEndOfDay];
}

- (KalDate *)getFromKalDate
{
    self.daysInFinalWeekOfPreviousMonth = [self calculateDaysInFinalWeekOfPreviousMonth];
    
    KalDate *from = [self.daysInFinalWeekOfPreviousMonth count] > 0 ? [self.daysInFinalWeekOfPreviousMonth objectAtIndex:0] : [self.daysInSelectedMonth objectAtIndex:0];
    return from;
}

- (KalDate *)getToKalDate
{
    self.daysInFirstWeekOfFollowingMonth = [self calculateDaysInFirstWeekOfFollowingMonth];
    KalDate *to = [self.daysInFirstWeekOfFollowingMonth count] > 0 ? [self.daysInFirstWeekOfFollowingMonth lastObject] : [self.daysInSelectedMonth lastObject];
    return to;
}

#pragma mark -

- (void) dealloc
{
    [minDate release];
    [maxDate release];
    
    [monthAndYearFormatter release];
    [baseDate release];
    [fromDate release];
    [toDate release];
    [daysInSelectedMonth release];
    [daysInFinalWeekOfPreviousMonth release];
    [daysInFirstWeekOfFollowingMonth release];
    [super dealloc];
}

@end
