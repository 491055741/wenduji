/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

@class KalGridView, KalLogic, KalDate;
@protocol KalViewDelegate, KalDataSourceCallbacks;//,KalDateCheckDelegate;

/*
 *    KalView
 *    ------------------
 *
 *    Private interface
 *
 *  As a client of the Kal system you should not need to use this class directly
 *  (it is managed by KalViewController).
 *
 *  KalViewController uses KalView as its view.
 *  KalView defines a view hierarchy that looks like the following:
 *
 *       +-----------------------------------------+
 *       |                header view              |
 *       +-----------------------------------------+
 *       |                                         |
 *       |                                         |
 *       |                                         |
 *       |                 grid view               |
 *       |             (the calendar grid)         |
 *       |                                         |
 *       |                                         |
 *       +-----------------------------------------+
 *       |                                         |
 *       |           table view (events)           |
 *       |                                         |
 *       +-----------------------------------------+
 *
 */
@interface KalView : UIView
{
  UILabel *headerTitleLabel;
  KalGridView *gridView;
  UITableView *tableView;
  UIImageView *shadowView;
  id<KalViewDelegate> delegate;
//  id<KalDateCheckDelegate> dateCheckDelegate;  //  for selecting several tiles;
  KalLogic *logic;
    BOOL isSingleDate;
}

@property (nonatomic, assign) id<KalViewDelegate> delegate;
//@property (nonatomic, assign) id<KalDateCheckDelegate> dateCheckDelegate;  //  for selecting several tiles;
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) KalDate *selectedDate;
@property (nonatomic, assign) BOOL isSingleDate;

- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)delegate logic:(KalLogic *)logic;
- (id)initWithFrame:(CGRect)frame delegate:(id<KalViewDelegate>)theDelegate logic:(KalLogic *)theLogic isSingleDate:(BOOL)singleDate ;
//- (void) initDateCheckDelegate:(id<KalDateCheckDelegate>)theDelegate;  //  for selecting several tiles;
- (BOOL)isSliding;
- (void)selectDate:(KalDate *)date;
- (void)markTilesForDates:(NSArray *)dates;

// These 3 methods are exposed for the delegate. They should be called 
// *after* the KalLogic has moved to the month specified by the user.
- (void)slideDown;
- (void)slideUp;
- (void)jumpToSelectedMonth;    // change months without animation (i.e. when directly switching to "Today")
- (void)getDateSelected:(NSDate **)sDate;  // for single date
- (void)getDateRangeMin:(NSDate **)min Max:(NSDate **)max;
- (void)initWithCheckInDate:(NSDate *)dateIn CheckOutDate:(NSDate *)dateOut;
- (void)setCheckInDate:(NSDate *)dateIn CheckOutDate:(NSDate *)dateOut;
- (void)setInitSelectedDate:(NSDate *)dateSelect;

@end

#pragma mark -

@class KalDate;

@protocol KalViewDelegate

- (void)showPreviousMonth;
- (void)showFollowingMonth;
- (void)didSelectDate:(KalDate *)date;
- (void)setCurrentCheckDateType:(NSUInteger)x;


@end

//   //  for selecting several tiles;  for modifying checkin date and checkout date;
//@protocol KalDateCheckDelegate
//- (void)setCurrentCheckDateType:(NSUInteger)x;
//@end
