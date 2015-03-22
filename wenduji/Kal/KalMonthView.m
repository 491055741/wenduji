/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <CoreGraphics/CoreGraphics.h>
#import "KalMonthView.h"
#import "KalTileView.h"
#import "KalView.h"
#import "KalDate.h"
#import "KalPrivate.h"
#import "KalLogic.h"

extern const CGSize kTileSize;

@implementation KalMonthView

@synthesize numWeeks;

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    self.opaque = NO;
    self.clipsToBounds = YES;
    for (int i=0; i<6; i++) {
      for (int j=0; j<7; j++) {
        CGRect r = CGRectMake(j*kTileSize.width, i*kTileSize.height, kTileSize.width, kTileSize.height);
        [self addSubview:[[[KalTileView alloc] initWithFrame:r] autorelease]];
      }
    }
  }
  return self;
}

// totally 42 tiles, but maybe only init first 35 tiles.
- (void)showDates:(NSArray *)mainDates leadingAdjacentDates:(NSArray *)leadingAdjacentDates trailingAdjacentDates:(NSArray *)trailingAdjacentDates
{
    int tileNum = 0;
    NSArray *dates[] = { leadingAdjacentDates, mainDates, trailingAdjacentDates };

    for (int i=0; i<3; i++) {
        for (KalDate *d in dates[i]) {
            KalTileView *tile = [self.subviews objectAtIndex:tileNum];
            [tile resetState];
            tile.date = d;
            tile.type = dates[i] != mainDates
            ? KalTileTypeAdjacent
            : [d isToday] ? KalTileTypeToday : KalTileTypeRegular;
            tileNum++;
        }
    }
    
    numWeeks = ceilf(tileNum / 7.f);
    [self sizeToFit];
    [self setNeedsDisplay];
}

- (void)showDates:(KalLogic *)logic
{
    int tileNum = 0;

    NSArray *dates[] = {logic.daysInFinalWeekOfPreviousMonth, logic.daysInSelectedMonth, logic.daysInFirstWeekOfFollowingMonth };

    for (int i=0; i<3; i++) {
        for (KalDate *d in dates[i]) {
            KalTileView *tile = [self.subviews objectAtIndex:tileNum];
            [tile resetState];
            tile.date = d;
            tile.type = dates[i] != logic.daysInSelectedMonth
            ? KalTileTypeAdjacent
            : [d isToday] ? KalTileTypeToday : KalTileTypeRegular;
            
            if (![logic isDateInRange:[d NSDate]])
                tile.type = KalTileTypeDisable;            
            
            tileNum++;
        }
    }
    
    numWeeks = ceilf(tileNum / 7.f);
//    if([logic.daysInFirstWeekOfFollowingMonth count]==0||[logic.daysInFinalWeekOfPreviousMonth count]==0)
//    {
//        numWeeks = numWeeks + 1;
//    }

    [self sizeToFit];
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)rect
{
#ifdef __HOTEL_FINDER__
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextDrawTiledImage(ctx, (CGRect){CGPointZero,kTileSize}, [[UIImage imageNamed:@"kal_tile.png"] CGImage]);
#endif
}

- (KalTileView *)firstTileOfMonth
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if (!t.belongsToAdjacentMonth) {
      tile = t;
      break;
    }
  }
  
  return tile;
}


- (KalTileView *)tileForDate:(KalDate *)date
{
  KalTileView *tile = nil;
  for (KalTileView *t in self.subviews) {
    if ([t.date isEqual:date]) 
    {
      tile = t;
      break;
    }
  }
  //NSAssert1(tile != nil, @"Failed to find corresponding tile for date %@", date);
  
  return tile;
}

- (void)sizeToFit
{
  self.height = 1.f + kTileSize.height * numWeeks;
}

- (void)markTilesForDates:(NSArray *)dates
{
  for (KalTileView *tile in self.subviews)
    tile.marked = [dates containsObject:tile.date];
}

@end
