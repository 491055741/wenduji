/*
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <CoreGraphics/CoreGraphics.h>

#import "KalGridView.h"
#import "KalView.h"
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalLogic.h"
#import "KalDate.h"
#import "KalPrivate.h"

#define SLIDE_NONE 0
#define SLIDE_UP 1
#define SLIDE_DOWN 2

#define CheckInDateType 0
#define CheckOUTDateType 1
#define OriginalCheckDateType 2

#define kHintViewTag 111

//const CGSize kTileSize = { 46.f, 38.f };
const CGSize kTileSize = { 46.f, 30.f };

static NSString *kSlideAnimationId = @"KalSwitchMonths";

@interface KalGridView ()
@property (nonatomic, retain) KalTileView *selectedTile;
@property (nonatomic, retain) KalTileView *highlightedTile;
- (void)swapMonthViews;
@end

@implementation KalGridView

@synthesize selectedTile, highlightedTile, transitioning;
@synthesize movedTile;
@synthesize selectedDatesArray;
@synthesize startTile;
@synthesize midMonthView;
@synthesize slideDate;
@synthesize isSingleDate;

int showMonthFlag;

- (id)initWithFrame:(CGRect)frame logic:(KalLogic *)theLogic delegate:(id<KalViewDelegate>)theDelegate
{
    // MobileCal uses 46px wide tiles, with a 2px inner stroke
    // along the top and right edges. Since there are 7 columns,
    // the width needs to be 46*7 (322px). But the iPhone's screen
    // is only 320px wide, so we need to make the
    // frame extend just beyond the right edge of the screen
    // to accomodate all 7 columns. The 7th day's 2px inner stroke
    // will be clipped off the screen, but that's fine because
    // MobileCal does the same thing.
    self.selectedDatesArray = [NSMutableArray arrayWithCapacity:20];
    self.midMonthView = [[[KalMonthView alloc] init] autorelease];
    frame.size.width = 7 * kTileSize.width;

    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
        logic = [theLogic retain];
        delegate = theDelegate;
        isSingleDate = NO;
        CGRect monthRect = CGRectMake(0.f, 0.f, frame.size.width, frame.size.height);
        frontMonthView = [[KalMonthView alloc] initWithFrame:monthRect];
        backMonthView = [[KalMonthView alloc] initWithFrame:monthRect];
        backMonthView.hidden = YES;
        [self addSubview:backMonthView];
        [self addSubview:frontMonthView];
        
        [self jumpToSelectedMonth];
    }
    return self;
}

//- (void)initDateCheckDelegate:(id<KalDateCheckDelegate>)theDelegate
//{
//    checkDateDelegate=theDelegate;
//}

- (void)drawRect:(CGRect)rect
{
    [[UIColor whiteColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    [[UIColor colorWithRed:0.63f green:0.65f blue:0.68f alpha:1.f] setFill];
    CGRect line;
    line.origin = CGPointMake(0.f, self.height - 1.f);
    line.size = CGSizeMake(self.width, 1.f);
    CGContextFillRect(UIGraphicsGetCurrentContext(), line);
}

- (void)sizeToFit
{
    self.height = frontMonthView.height;
}

#pragma mark -
#pragma mark Touches

- (void)setHighlightedTile:(KalTileView *)tile
{
    if (tile != nil && tile.type != KalTileTypeDisable)
    {
        if (highlightedTile != tile) {
            highlightedTile.highlighted = NO;
            highlightedTile = [tile retain];
            tile.highlighted = YES;
            [tile setNeedsDisplay];
        }
    }
}

- (void)inputCheckInDate:(KalDate *)date
{
    //[delegate setCurrentCheckDateType:CheckInDateType];
    if([frontMonthView tileForDate:date])
    {
        self.selectedTile = [frontMonthView tileForDate:date];
    }
    else
    {
        self.selectedTile = [midMonthView tileForDate:date];
    }
    //selectedTile.isStartDate = YES;
    //selectedTile.isEndDate = NO;
    // cjj
    self.checkInDate = date;
    [selectedTile setNeedsDisplay];
}

- (void)inputCheckOutDate:(KalDate *)date
{
    //[delegate setCurrentCheckDateType:CheckOUTDateType];
    if([frontMonthView tileForDate:date])
    {
        self.selectedTile = [frontMonthView tileForDate:date];
    }
    else
    {
        self.selectedTile = [midMonthView tileForDate:date];
    }
    //selectedTile.isStartDate = NO;
    //selectedTile.isEndDate = YES;
    [selectedTile setNeedsDisplay];
    self.checkOutDate = date;
}

- (void)setSelectedTile:(KalTileView *)tile
{
    if (tile != nil && tile.type != KalTileTypeDisable)
    {
        if (selectedTile != tile) {
            //selectedTile.selected = NO;
            selectedTile = [tile retain];
            tile.selected = YES;
            [delegate didSelectDate:tile.date];
        }
    }
}

- (void)receivedTouches:(NSSet *)touches withEvent:event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *hitView = [self hitTest:location withEvent:event];
    
    if (!hitView)
        return;
    
    if (isSingleDate) {
        if ([hitView isKindOfClass:[KalTileView class]]) {
            KalTileView *tile = (KalTileView *)hitView;
            if (tile.selected) {
               [delegate didSelectDate:tile.date];
                return;
            }
            if (tile.type == KalTileTypeDisable) {
                return;
            }
            [self removeSelectedTilesArray];
            [selectedDatesArray removeAllObjects];
            
            [self setSelectedTile:tile];

            [selectedDatesArray addObject:tile.date];
        }
        return;
    }
    
    if ([hitView isKindOfClass:[KalTileView class]])
    {
        KalTileView *tile = (KalTileView*)hitView;
        
        if (tile.date == nil ||
            [tile.date compare:[KalDate dateFromNSDate:logic.minDate ]] == NSOrderedAscending
            || [tile.date compare:[KalDate dateFromNSDate:logic.maxDate]] == NSOrderedDescending) {
            return;
        }
        
        if([selectedDatesArray count]<=1)
        {
            selectedTile.selected = NO;
            [self removeSelectedTilesArray];
            if ([tile.date compare:[logic getFromKalDate]]==NSOrderedSame||[tile.date compare:[logic getToKalDate]]==NSOrderedSame)//tile.belongsToAdjacentMonth)
            {
                self.highlightedTile = tile;
                
                self.startTile=tile;
            } else {
                self.highlightedTile = nil;
                //self.selectedTile = tile;
                self.startTile=tile;
            }
        }
        else
        {
            selectedTile.selected = NO;
            [self removeSelectedTilesArray];
            if ([tile.date compare:[logic getFromKalDate]]==NSOrderedSame||[tile.date compare:[logic getToKalDate]]==NSOrderedSame)//tile.belongsToAdjacentMonth)
            {
                self.highlightedTile = tile;
                self.startTile=tile;
            } else {
                self.highlightedTile = nil;
                //self.selectedTile = tile;
                self.startTile=tile;
            }
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    showMonthFlag = 5;
    [self receivedTouches:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isSingleDate) {
        return;
    }
    BOOL slideFlag = YES;
    if (slideDate) {
        NSDate *date = [NSDate date];
        slideFlag = NO;
        if([date compare:[slideDate dateByAddingTimeInterval:0.8]]!=NSOrderedAscending) {
            slideFlag = YES;
        }
    }
    
    if (slideFlag) {
        
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        UIView *hitView = [self hitTest:location withEvent:event];
        
        if ([hitView isKindOfClass:[KalTileView class]]) {
            KalTileView *tile = (KalTileView*)hitView;
            
            if ([tile.date compare:[KalDate dateFromNSDate:logic.minDate ]] == NSOrderedAscending
                || [tile.date compare:[KalDate dateFromNSDate:logic.maxDate]] == NSOrderedDescending
                || startTile == nil) {
                return;
            }
            
            if ([tile.date compare:[logic getFromKalDate]]==NSOrderedSame||[tile.date compare:[logic getToKalDate]]==NSOrderedSame) //tile.belongsToAdjacentMonth)
            {
                if ([tile.date compare:[logic getToKalDate]]==NSOrderedSame)//[tile.date compare:[KalDate dateFromNSDate:logic.baseDate]] == NSOrderedDescending)
                {
                    if([selectedDatesArray count] < logic.maxSelectDays
                       && [[[frontMonthView firstTileOfMonth] date] compare:tile.date] == NSOrderedAscending
                       && showMonthFlag < 6) {
                        self.slideDate = [NSDate date];
                        //[NSThread sleepForTimeInterval:1.0];
                        //midMonthView = frontMonthView;
                        [delegate showFollowingMonth];
                        
                        showMonthFlag = showMonthFlag+1;
                    }
                } else {
                    if([selectedDatesArray count] < logic.maxSelectDays
                       && [[[frontMonthView firstTileOfMonth] date] compare:tile.date] == NSOrderedDescending
                       && showMonthFlag > 4) {
                        self.slideDate = [NSDate date];
                        //midMonthView = frontMonthView;
                        [delegate showPreviousMonth];
                        
                        showMonthFlag = showMonthFlag-1;
                    }
                }
                // if the moved tile is in last row, and the last row is hiden, the tile.date is nil, so self.movedTile will be nil too.
                self.movedTile = [frontMonthView tileForDate:tile.date];
            } else {
                self.highlightedTile = nil;
                self.movedTile = tile;
            }
            
            if (movedTile != nil) {
                [self removeSelectedTilesArray];
                [selectedDatesArray addObject:startTile.date];
                KalDate *midDate = startTile.date;
                
                if ([startTile.date compare:movedTile.date] == NSOrderedAscending) {
                    while ([midDate compare:movedTile.date] == NSOrderedAscending) {
                        midDate = [midDate nextDay];
                        //NSLog(@"%s get next kal date", __FUNCTION__);
                        if([selectedDatesArray count] < logic.maxSelectDays) {
                            [selectedDatesArray addObject:midDate];
                        }
                    }
                } else if ([startTile.date compare:movedTile.date] == NSOrderedDescending) {
                    while ([midDate compare:movedTile.date] == NSOrderedDescending) {
                        midDate = [midDate previousDay];
                        //NSLog(@"%s get preceding kal date", __FUNCTION__);
                        if([selectedDatesArray count] < logic.maxSelectDays) {
                            [selectedDatesArray addObject:midDate];
                        }
                    }
                }
                
                if ([startTile.date compare:movedTile.date] == NSOrderedAscending) {
                    [self inputCheckInDate:[selectedDatesArray objectAtIndex:0]];
                    [self inputCheckOutDate:[selectedDatesArray lastObject]];
                } else if ([startTile.date compare:movedTile.date] == NSOrderedDescending) {
                    [self inputCheckInDate:[selectedDatesArray lastObject]];
                    [self inputCheckOutDate:[selectedDatesArray objectAtIndex:0]];
                } else if ([selectedDatesArray count]==1) {
                    selectedTile = nil;
                    //[delegate setCurrentCheckDateType:OriginalCheckDateType];
                    self.selectedTile = [frontMonthView tileForDate:[selectedDatesArray objectAtIndex:0]];
                }
            }
            
            [self layoutSelectedTilesArray];
        }
    }
}

- (void)removeSelectedTilesArray
{
    for (KalDate *firstDate in selectedDatesArray) {
        KalTileView *firstTile = [frontMonthView tileForDate:firstDate];
        firstTile.selected = NO;
        firstTile.isEndDate = NO;
        firstTile.isStartDate = NO;
/*
        UIView *hintView = [firstTile viewWithTag:kHintViewTag];
        [hintView removeFromSuperview];
 */
    }
    [selectedDatesArray removeAllObjects];
}

- (void)layoutSelectedTilesArray
{
    for (KalDate *theDate in selectedDatesArray)
    {
        KalTileView *theTile = [frontMonthView tileForDate:theDate];
        theTile.selected = YES;
        
        if ([theTile.date compare:self.checkInDate] == NSOrderedSame) {
            theTile.isStartDate = YES;
            theTile.isEndDate = NO;
        } else if ([theTile.date compare:self.checkOutDate] == NSOrderedSame) {
            theTile.isStartDate = NO;
            theTile.isEndDate = YES;
/*
            if ([theTile viewWithTag:kHintViewTag] != nil)
                [[theTile viewWithTag:kHintViewTag] removeFromSuperview];
            UIImageView *hintView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"] ] autorelease];
            hintView.frame = CGRectMake(0, -50, 50, 50);
            hintView.tag = kHintViewTag;
            [theTile addSubview:hintView];
*/
        } else {
            theTile.isStartDate = theTile.isEndDate = NO;
        }
    }
    
    return;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *hitView = [self hitTest:location withEvent:event];
    
    if (isSingleDate) {
        return;
    }
    
    if ([hitView isKindOfClass:[KalTileView class]]) {
        KalTileView *tile = (KalTileView*)hitView;
        
        if (tile.date == nil) {
            return;
        }
        
        if ([selectedDatesArray count] == 0
            && ([tile.date compare:[logic getFromKalDate]] == NSOrderedSame
                || [tile.date compare:[logic getToKalDate]] == NSOrderedSame))//tile.belongsToAdjacentMonth)
        {
            if ([tile.date compare:[logic getToKalDate]] == NSOrderedSame)//[tile.date compare:[KalDate dateFromNSDate:logic.baseDate]] == NSOrderedDescending)
            {
                [delegate showFollowingMonth];
            }
            else
            {
                [delegate showPreviousMonth];
            }
            //self.selectedTile = [frontMonthView tileForDate:tile.date];
        }

        if ([selectedDatesArray count] == 0)
        {
            //[delegate setCurrentCheckDateType:OriginalCheckDateType];
            
            if ([tile.date compare:[KalDate dateFromNSDate:logic.maxDate ]] == NSOrderedSame) {
                KalDate *preDate = [tile.date previousDay];
                [selectedDatesArray addObject:preDate];
                [selectedDatesArray addObject:tile.date];
                [self inputCheckInDate:[selectedDatesArray objectAtIndex:0]];
                [self inputCheckOutDate:[selectedDatesArray lastObject]];
                [self layoutSelectedTilesArray];
                return;
            }
            
            self.selectedTile = tile;
            [selectedDatesArray addObject:tile.date];
        }
    }
    
    if ([selectedDatesArray count] == 1) {
        KalDate *theOnlyDate = [selectedDatesArray objectAtIndex:0];
        
        if ([theOnlyDate compare:[KalDate dateFromNSDate:logic.maxDate]] == NSOrderedSame) {
            [selectedDatesArray insertObject:theOnlyDate.previousDay atIndex:0];
        } else if ([theOnlyDate compare:[KalDate dateFromNSDate:logic.minDate]] == NSOrderedSame) {
            [selectedDatesArray addObject:theOnlyDate.nextDay];
        } else {
            [selectedDatesArray addObject:theOnlyDate.nextDay];
        }
        
        [self inputCheckInDate:[selectedDatesArray objectAtIndex:0]];
        [self inputCheckOutDate:[selectedDatesArray lastObject]];
        [self layoutSelectedTilesArray];
    }
    
    [self layoutSelectedTilesArray];
    self.highlightedTile = nil;
}


#pragma mark -
#pragma mark Slide Animation

- (void)swapMonthsAndSlide:(int)direction keepOneRow:(BOOL)keepOneRow
{
    backMonthView.hidden = NO;
    
    // set initial positions before the slide
    if (direction == SLIDE_UP) {
        backMonthView.top = keepOneRow
        ? frontMonthView.bottom - kTileSize.height
        : frontMonthView.bottom;
    } else if (direction == SLIDE_DOWN) {
        NSUInteger numWeeksToKeep = keepOneRow ? 1 : 0;
        NSInteger numWeeksToSlide = [backMonthView numWeeks] - numWeeksToKeep;
        backMonthView.top = -numWeeksToSlide * kTileSize.height;
    } else {
        backMonthView.top = 0.f;
    }
    
    // trigger the slide animation
    [UIView beginAnimations:kSlideAnimationId context:NULL]; {
        [UIView setAnimationsEnabled:direction!=SLIDE_NONE];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        
        frontMonthView.top = -backMonthView.top;
        backMonthView.top = 0.f;
        
        self.height = backMonthView.height;
        
        [self swapMonthViews];
    } [UIView commitAnimations];
    [UIView setAnimationsEnabled:YES];
}

- (void)slide:(int)direction
{
    // cjj
//    KalDate *startDate = nil;
//    KalDate *endDate = nil;
//    
//    for (KalDate *date in selectedDatesArray) {
//        KalTileView *tile = [frontMonthView tileForDate:date];
//        if (tile.isStartDate) {
//            startDate = tile.date;
//            tile.isStartDate = NO;
//        } else if (tile.isEndDate) {
//            endDate = tile.date;
//            tile.isEndDate = NO;
//        }
//    }
    
//    NSLog(@"start : %@   end : %@", startDate, endDate);
    
    self.midMonthView = frontMonthView;
    transitioning = YES;
    
    //[backMonthView showDates:logic.daysInSelectedMonth
    //leadingAdjacentDates:logic.daysInFinalWeekOfPreviousMonth
    //trailingAdjacentDates:logic.daysInFirstWeekOfFollowingMonth];
    [backMonthView showDates:logic];
    
    // At this point, the calendar logic has already been advanced or retreated to the
    // following/previous month, so in order to determine whether there are
    // any cells to keep, we need to check for a partial week in the month
    // that is sliding offscreen.
    
    BOOL keepOneRow = (direction == SLIDE_UP && [logic.daysInFinalWeekOfPreviousMonth count] > 0)
    || (direction == SLIDE_DOWN && [logic.daysInFirstWeekOfFollowingMonth count] > 0);
    
    [self swapMonthsAndSlide:direction keepOneRow:keepOneRow];
    
    /*
     if ([[[NSDate date] cc_dateByMovingToFirstDayOfTheMonth] isEqual:[[frontMonthView firstTileOfMonth].date NSDate]]) {
     self.selectedTile = [frontMonthView tileForDate:[KalDate dateFromNSDate:[[NSDate date] cc_dateByMovingToBeginningOfDay]]];
     } else {
     self.selectedTile = [frontMonthView firstTileOfMonth];
     }*/

    [self layoutSelectedTilesArray];
}

- (void)slideUp { [self slide:SLIDE_UP]; }
- (void)slideDown { [self slide:SLIDE_DOWN]; }

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    transitioning = NO;
    backMonthView.hidden = YES;
}

#pragma mark -

- (void)selectDate:(KalDate *)date
{
    self.selectedTile = [frontMonthView tileForDate:date];
}

- (void)initWithCheckInDate:(NSDate *)dateIn CheckOutDate:(NSDate *)dateOut
{
    [self removeSelectedTilesArray];
    KalDate *startDate = [KalDate dateFromNSDate:dateIn];
    KalDate *stopDate = [KalDate dateFromNSDate:dateOut];
    KalDate *midDate = startDate;
    
    while ([midDate compare:stopDate] != NSOrderedDescending)
    {
        if([selectedDatesArray count] < logic.maxSelectDays)
        {
            [selectedDatesArray addObject:midDate];
        }
        midDate = [midDate nextDay];
    }
    [self layoutSelectedTilesArray];
    
}

- (void)setCheckInDate:(NSDate *)dateIn CheckOutDate:(NSDate *)dateOut
{
    /*
     NSDate *d = [NSDate dateWithTimeInterval:0 sinceDate:logic.minDate];
     NSDate *e = [NSDate dateWithTimeInterval:0 sinceDate:logic.maxDate];
     logic = [logic initForDate:dateIn];
     logic.minDate = d;
     logic.maxDate = e;
     */
    [logic moveToMonthForDate:dateIn];
    
    [self jumpToSelectedMonth];
    [self removeSelectedTilesArray];
    KalDate *startDate = [KalDate dateFromNSDate:dateIn];
    KalDate *stopDate = [KalDate dateFromNSDate:dateOut];
    KalDate *midDate = startDate;
    
    [self inputCheckInDate:startDate];
    [self inputCheckOutDate:stopDate];
    
    while ([midDate compare:stopDate] != NSOrderedDescending)
    {
        if([selectedDatesArray count] < logic.maxSelectDays)
        {
            [selectedDatesArray addObject:midDate];
        }
        midDate = [midDate nextDay];
    }
    [self layoutSelectedTilesArray];
}

- (void)setInitSelectedDate:(NSDate *)dateSelect {
    
    [logic moveToMonthForDate:dateSelect];
    [self jumpToSelectedMonth];
    [self removeSelectedTilesArray];
    [selectedDatesArray addObject:[KalDate dateFromNSDate:dateSelect]];
    [self layoutSelectedTilesArray];
    
}

- (void)getDateSelected:(NSDate **)sDate {
    if ([selectedDatesArray count] > 0 && isSingleDate) {
        KalDate *date = [selectedDatesArray objectAtIndex:0];
        NSDate *date1 = [date NSDate];
        *sDate = date1;
    }
}

- (void)getDateRangeMin:(NSDate **)min Max:(NSDate **)max;
{
    if([selectedDatesArray count]>0 && !isSingleDate)
    {
        if([[selectedDatesArray objectAtIndex:0] compare:[selectedDatesArray lastObject]]==NSOrderedAscending)
        {
            KalDate *date = [selectedDatesArray objectAtIndex:0];
            NSDate *date1 = [date NSDate];
            *min = date1;
            date = [selectedDatesArray lastObject];
            date1 = [date NSDate];
            *max = date1;
        }
        else if([[selectedDatesArray objectAtIndex:0] compare:[selectedDatesArray lastObject]]==NSOrderedDescending)
        {
            KalDate *date = [selectedDatesArray objectAtIndex:0];
            NSDate *date1 = [date NSDate];
            *max = date1;
            date = [selectedDatesArray lastObject];
            date1 = [date NSDate];
            *min = date1;
        }
        else if([[selectedDatesArray objectAtIndex:0] compare:[selectedDatesArray lastObject]]==NSOrderedSame)
        {
            KalDate *date = [selectedDatesArray objectAtIndex:0];
            NSDate *date1 = [date NSDate];
            *min = date1;
            date = [date nextDay];
            date1 = [date NSDate];
            *max = date1;
        }
    }
}

- (void)swapMonthViews
{
    KalMonthView *tmp = backMonthView;
    backMonthView = frontMonthView;
    frontMonthView = tmp;
    [self exchangeSubviewAtIndex:[self.subviews indexOfObject:frontMonthView] withSubviewAtIndex:[self.subviews indexOfObject:backMonthView]];
}

- (void)jumpToSelectedMonth
{
    [self slide:SLIDE_NONE];
}

- (void)markTilesForDates:(NSArray *)dates { [frontMonthView markTilesForDates:dates]; }

- (KalDate *)selectedDate { return selectedTile.date; }

#pragma mark -

- (void)dealloc
{
    self.slideDate = nil;
    self.selectedDatesArray = nil;
    self.midMonthView = nil;
    
    self.checkInDate = nil;
    self.checkOutDate = nil;
    
    [selectedTile release];
    [highlightedTile release];
    [frontMonthView release];
    [backMonthView release];
    [logic release];
    [super dealloc];
}

@end
