/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalViewController.h"
#import "KalLogic.h"
#import "KalDataSource.h"
#import "KalDate.h"
#import "KalPrivate.h"


#define PROFILER 0
#if PROFILER
#include <mach/mach_time.h>
#include <time.h>
#include <math.h>
void mach_absolute_difference(uint64_t end, uint64_t start, struct timespec *tp)
{
    uint64_t difference = end - start;
    static mach_timebase_info_data_t info = {0,0};
    
    if (info.denom == 0)
        mach_timebase_info(&info);
    
    uint64_t elapsednano = difference * (info.numer / info.denom);
    tp->tv_sec = elapsednano * 1e-9;
    tp->tv_nsec = elapsednano - (tp->tv_sec * 1e9);
}
#endif

@interface KalViewController ()
- (KalView*)calendarView;
- (void)markTiles;
@end

@implementation KalViewController

@synthesize dataSource, delegate, selectedDate, calendarDelegate;
//@synthesize dateCheckDateDelegate;
@synthesize tableView;
@synthesize isSingleDate;

- (id)initWithSelectedDate:(NSDate *)date
{
    if ((self = [super init])) {
        logic = [[KalLogic alloc] initForDate:date];
        initialSelectedDate = [date retain];
    }
    return self;
}

- (id)initWithCheckInDate:(NSDate *)dateIn CheckOutDate:(NSDate *)dateOut
{
    if ((self = [super init])) {
        logic = [[KalLogic alloc] initForDate:dateIn];
        initialSelectedDate = [dateIn retain];
        initialCheckOutDate = [dateOut retain];
    }
    return self;
}

- (void)setCheckInDate:(NSDate *)dateIn CheckOutDate:(NSDate *)dateOut
{
    [[self calendarView] setCheckInDate:dateIn CheckOutDate:dateOut];

    [self markTiles];
}

- (void)setInitSelectedDate:(NSDate *)dateSelect {
    isSingleDate = YES;
    [[self calendarView] setInitSelectedDate:dateSelect];
}

//- (void)initCheckDateDalegateWith:(id<KalDateCheckDelegate>)theDelegate
//{
//    dateCheckDateDelegate=theDelegate;
//}
- (id)init
{
    return [self initWithSelectedDate:[NSDate date]];
}

- (void)setDateRangeMin:(NSDate *)min Max:(NSDate *)max MaxSelectDays:(NSInteger)days
{
    if (logic != nil) {
        logic.minDate = min;
        logic.maxDate = max;
        logic.maxSelectDays = days;
    }
}

- (void)setTimeRange:(NSDate *)min Max:(NSDate *)max
{
    if (logic != nil)
    {
        logic.minDate = min;
        logic.maxDate = max;
        logic.maxSelectDays = 1;
    }
}

- (KalView*)calendarView { return (KalView*)self.view; }

- (void)setDataSource:(id<KalDataSource>)aDataSource
{
    if (dataSource != aDataSource) {
        [dataSource release];
        [aDataSource retain];
        dataSource = aDataSource;
        tableView.dataSource = dataSource;
        
        // add by lipeng : so all caller not need set delegate any more
        delegate = dataSource;
        tableView.delegate = delegate;
    }
}

- (void)setDelegate:(id<UITableViewDelegate>)aDelegate
{
    if (delegate != aDelegate) {
        [delegate release];
        [aDelegate retain];
        delegate = aDelegate;
        tableView.delegate = delegate;
    }
}

- (void)clearTable
{
    [dataSource removeAllItems];
    [tableView reloadData];
}

- (void)reloadData
{
    [dataSource presentingDatesFrom:logic.fromDate to:logic.toDate delegate:self];
}

// -----------------------------------------
#pragma mark KalViewDelegate protocol
- (void)getDateRangeMin:(NSDate **)min Max:(NSDate **)max
{
    [[self calendarView] getDateRangeMin:min Max:max];
}

- (void)getDateSelected:(NSDate **)sDate {
    [[self calendarView] getDateSelected:sDate];
}

- (void)didSelectDate:(KalDate *)date
{
    self.selectedDate = [date NSDate];
    
    NSDate *from = [[date NSDate] cc_dateByMovingToBeginningOfDay];
    NSDate *to = [[date NSDate] cc_dateByMovingToEndOfDay];
    //[self clearTable];
    [dataSource loadItemsFromDate:from toDate:to];
    //[dataSource presentingDatesFrom:from to:to delegate:self];
    [self markTiles];
    if (calendarDelegate != nil)
        [calendarDelegate didSelectDate:self.selectedDate];
        
    //[tableView reloadData];
    //[tableView flashScrollIndicators];
}

- (void)setCurrentCheckDateType:(NSUInteger)x
{
    if (calendarDelegate != nil && [calendarDelegate respondsToSelector:@selector(setCurrentCheckDateType:)])
        [calendarDelegate setCurrentCheckDateType:x];
}

- (void)showPreviousMonth
{
    [self clearTable];
    [logic retreatToPreviousMonth];
    [[self calendarView] slideDown];
    [self reloadData];
}

- (void)showFollowingMonth
{
    [self clearTable];
    [logic advanceToFollowingMonth];
    [[self calendarView] slideUp];
    [self reloadData];
}

// -----------------------------------------
#pragma mark KalDataSourceCallbacks protocol

- (void)loadedDataSource:(id<KalDataSource>)theDataSource;
{
/*
    NSArray *markedDates = [theDataSource markedDatesFrom:logic.fromDate to:logic.toDate];
    NSMutableArray *dates = [[markedDates mutableCopy] autorelease];
    for (int i=0; i<[dates count]; i++)
        [dates replaceObjectAtIndex:i withObject:[KalDate dateFromNSDate:[dates objectAtIndex:i]]];
    
    [[self calendarView] markTilesForDates:dates];
    [self didSelectDate:self.calendarView.selectedDate];
 */
}

- (void)markTiles {

    NSDate *from = nil;
    NSDate *to = nil;
    [[self calendarView] getDateRangeMin:&from Max:&to];
    if (from != nil && to != nil) {
        NSMutableArray *dates = [NSMutableArray arrayWithObjects:from, to, nil];
        for (int i=0; i<[dates count]; i++)
            [dates replaceObjectAtIndex:i withObject:[KalDate dateFromNSDate:[dates objectAtIndex:i]]];
        
        [[self calendarView] markTilesForDates:dates];
    }
}

// ---------------------------------------
#pragma mark -

- (void)showAndSelectDate:(NSDate *)date
{
    if ([[self calendarView] isSliding])
        return;
    
    [logic moveToMonthForDate:date];
    
#if PROFILER
    uint64_t start, end;
    struct timespec tp;
    start = mach_absolute_time();
#endif
    
    [[self calendarView] jumpToSelectedMonth];
    
#if PROFILER
    end = mach_absolute_time();
    mach_absolute_difference(end, start, &tp);
    printf("[[self calendarView] jumpToSelectedMonth]: %.1f ms\n", tp.tv_nsec / 1e6);
#endif
    
    [[self calendarView] selectDate:[KalDate dateFromNSDate:date]];
    [self reloadData];
}

// -----------------------------------------------------------------------------------
#pragma mark UIViewController

- (void)loadView
{
    //self.title = @"Calendar";    
    CGRect rect = CGRectMake(0, 0, kCalendarWidth, kCalendarHeight);
    
//    KalView *kalView = [[KalView alloc] initWithFrame:rect delegate:self logic:logic];
//    kalView.isSingleDate = isSingleDate;
    KalView *kalView = [[KalView alloc] initWithFrame:rect delegate:self logic:logic isSingleDate:isSingleDate];
    
//    [kalView initDateCheckDelegate:dateCheckDateDelegate];
    self.view = kalView;
    tableView = kalView.tableView;
    tableView.userInteractionEnabled = NO;
    tableView.dataSource = dataSource;
    tableView.delegate = delegate;
    [tableView retain];
 //   [kalView selectDate:[KalDate dateFromNSDate:initialSelectedDate]];
    [kalView initWithCheckInDate:initialSelectedDate CheckOutDate:initialCheckOutDate];
    [kalView release];
    [self reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tableView flashScrollIndicators];
}

#pragma mark -

- (void)dealloc
{
    self.selectedDate = nil;
    [initialSelectedDate release];
    [logic release];
    [tableView release];
    [dataSource release];
    [super dealloc];
}

@end
