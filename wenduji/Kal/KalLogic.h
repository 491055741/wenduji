/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

/*
 *    KalLogic
 *    ------------------
 *
 *    Private interface
 *
 *  As a client of the Kal system you should not need to use this class directly
 *  (it is managed by the internal Kal subsystem).
 *
 *  The KalLogic represents the current state of the displayed calendar month
 *  and provides the logic for switching between months and determining which days
 *  are in a month as well as which days are in partial weeks adjacent to the selected
 *  month.
 *
 */
@class KalDate;

@interface KalLogic : NSObject
{
    NSDate *baseDate;
    NSDate *fromDate;
    NSDate *toDate;
    NSDate *minDate; // limit the valid date within 3 months
    NSDate *maxDate;
    NSArray *daysInSelectedMonth;
    NSArray *daysInFinalWeekOfPreviousMonth;
    NSArray *daysInFirstWeekOfFollowingMonth;
    NSDateFormatter *monthAndYearFormatter;   
    NSInteger maxSelectDays;
}

@property (nonatomic, retain) NSDate *baseDate;    // The first day of the currently selected month
@property (nonatomic, retain, readonly) NSDate *fromDate;  // The date corresponding to the tile in the upper-left corner of the currently selected month
@property (nonatomic, retain, readonly) NSDate *toDate;    // The date corresponding to the tile in the bottom-right corner of the currently selected month
@property (nonatomic, retain, readonly) NSArray *daysInSelectedMonth;             // array of KalDate
@property (nonatomic, retain, readonly) NSArray *daysInFinalWeekOfPreviousMonth;  // array of KalDate
@property (nonatomic, retain, readonly) NSArray *daysInFirstWeekOfFollowingMonth; // array of KalDate
@property (nonatomic, readonly) NSString *selectedMonthNameAndYear; // localized (e.g. "September 2010" for USA locale)
@property (nonatomic) NSInteger maxSelectDays;
@property (nonatomic, retain) NSDate *minDate; //minimum date
@property (nonatomic, retain) NSDate *maxDate; //maximal date

- (id)initForDate:(NSDate *)date; // designated initializer.

- (void)retreatToPreviousMonth;
- (void)advanceToFollowingMonth;
- (void)moveToMonthForDate:(NSDate *)date;
- (BOOL)isDateInRange:(NSDate *)date;

- (KalDate *)getFromKalDate;  //For slide previous month;2011.8.17
- (KalDate *)getToKalDate;    //For slide following month;2011.8.17

@end
