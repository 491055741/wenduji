/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

@class KalTileView, KalMonthView, KalLogic, KalDate;
@protocol KalViewDelegate;
//@protocol KalDateCheckDelegate;


/*
 *    KalGridView
 *    ------------------
 *
 *    Private interface
 *
 *  As a client of the Kal system you should not need to use this class directly
 *  (it is managed by KalView).
 *
 */
@interface KalGridView : UIView
{
    id<KalViewDelegate> delegate;  // Assigned.

    KalLogic *logic;
    KalMonthView *frontMonthView;
    KalMonthView *backMonthView;
    KalTileView *selectedTile;
    KalTileView *highlightedTile;
    
    KalTileView *movedTile;     //  for selecting several tiles;
    KalTileView *startTile;
    KalMonthView *midMonthView;
    NSDate *slideDate;
    NSMutableArray *selectedDatesArray;//for selecting several tiles;
    BOOL transitioning;
    BOOL isSingleDate;
}

@property (nonatomic, assign) BOOL isSingleDate;
@property (nonatomic, readonly) BOOL transitioning;
@property (nonatomic, readonly) KalDate *selectedDate;
@property (nonatomic, retain)  KalTileView *movedTile;
@property (nonatomic, retain) NSMutableArray *selectedDatesArray;
@property (nonatomic, retain) KalTileView *startTile;
@property (nonatomic, retain) KalMonthView *midMonthView;
@property (nonatomic, retain) NSDate *slideDate;

@property (nonatomic, retain) KalDate *checkInDate;
@property (nonatomic, retain) KalDate *checkOutDate;

- (id)initWithFrame:(CGRect)frame logic:(KalLogic *)logic delegate:(id<KalViewDelegate>)delegate;
//- (void)initDateCheckDelegate:(id<KalDateCheckDelegate>)theDelegate;
- (void)selectDate:(KalDate *)date;
- (void)markTilesForDates:(NSArray *)dates;

// These 3 methods should be called *after* the KalLogic
// has moved to the previous or following month.
- (void)slideUp;
- (void)slideDown;
- (void)jumpToSelectedMonth;    // see comment on KalView

- (void)removeSelectedTilesArray;  //  for selecting several tiles;
- (void)layoutSelectedTilesArray;
- (void)inputCheckInDate:(KalDate *)date;
- (void)inputCheckOutDate:(KalDate *)date;  //  for selecting several tiles;
- (void)getDateSelected:(NSDate **)sDate;  // for single date
- (void)getDateRangeMin:(NSDate **)min Max:(NSDate **)max;
- (void)initWithCheckInDate:(NSDate *)dateIn CheckOutDate:(NSDate *)dateOut;
- (void)setCheckInDate:(NSDate *)dateIn CheckOutDate:(NSDate *)dateOut;
- (void)setInitSelectedDate:(NSDate *)dateSelect;

@end
