/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalTileView.h"
#import "KalDate.h"
#import "KalPrivate.h"
#import <CoreText/CoreText.h>

extern const CGSize kTileSize;

@implementation KalTileView

@synthesize date;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        origin = frame.origin;
        [self resetState];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat fontSize; // 24.f
    UIFont *font;
    if (self.selected) {
        fontSize = 18.f;
        font = [UIFont boldSystemFontOfSize:18.f];
    } else {
        fontSize = 15.f;
        font = [UIFont systemFontOfSize:fontSize];//[UIFont boldSystemFontOfSize:fontSize];
    }
    UIColor *shadowColor = nil;
    UIColor *textColor = nil;
    UIImage *markerImage = nil;
    CGContextSelectFont(ctx, [font.fontName cStringUsingEncoding:NSUTF8StringEncoding], fontSize, kCGEncodingMacRoman);
    
    CGContextTranslateCTM(ctx, 0, kTileSize.height);
    CGContextScaleCTM(ctx, 1, -1);

    if (self.selected) {
        markerImage = [UIImage imageNamed:@"kal_marker_selected.png"];

        CGFloat width = MIN(kTileSize.width, kTileSize.height)-2;
        [[UIImage imageNamed:@"kal_tile_selected.png"] drawInRect:CGRectMake(ABS(kTileSize.width - width)/2, 0, width, width)];
        textColor = [UIColor whiteColor];
        shadowColor = nil;//[UIColor blackColor];
        
    }  else if (![self enabled]) {
        textColor = RGB(160, 160, 160);
        shadowColor = nil;
    } else {
        textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"kal_tile_text_fill.png"]];
        shadowColor = [UIColor clearColor];
    }
    
    if (flags.marked) {
        [markerImage drawInRect:CGRectMake(23.f-markerImage.size.width/2, 3.f, markerImage.size.width, markerImage.size.height)];
    }
    
    NSUInteger n = [self.date day];
    NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
    const char *day = [dayText cStringUsingEncoding:NSUTF8StringEncoding];
    CGSize textSize = [dayText sizeWithFont:font];
    CGFloat textX, textY;
    textX = roundf(0.5f * (kTileSize.width - textSize.width));
    textY = 2.f/*6.f*/ + roundf(0.5f * (kTileSize.height - textSize.height));
    if (self.selected)
        textY += 2.f; // move a bit upper
    if (shadowColor) {
        [shadowColor setFill];
        CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
        textY += 1.f;
    }
    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        [textColor setFill];
        CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
    } else {
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:dayText attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:textColor}];
        CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)attrString);
        CGContextSetTextPosition(ctx, textX, textY);
        CTLineDraw(line, ctx);
        CFRelease(line);
    }
    
    if (self.highlighted) {
        [[UIColor colorWithWhite:0.25f alpha:0.3f] setFill];
        CGContextFillRect(ctx, CGRectMake(0.f, 0.f, kTileSize.width, kTileSize.height));
    }
}

- (void)resetState
{
    // realign to the grid
    CGRect frame = self.frame;
    frame.origin = origin;
    frame.size = kTileSize;
    self.frame = frame;

    
    [date release];
    date = nil;
    flags.type = KalTileTypeRegular;
    flags.highlighted = NO;
    flags.selected = NO;
    flags.marked = NO;
}

- (void)setDate:(KalDate *)aDate
{
    if (date == aDate)
        return;

    [date release];
    date = [aDate retain];
    
    [self setNeedsDisplay];
}

- (BOOL)isSelected { return flags.selected; }

- (void)setSelected:(BOOL)selected
{
    if (self.type == KalTileTypeDisable)
    {
        flags.selected = NO;
        return;
    }
    
    if (flags.selected == selected)
        return;
    
    // workaround since I cannot draw outside of the frame in drawRect:
    if (![self isToday]) {
        CGRect rect = self.frame;
        if (selected) {
            rect.origin.x--;
            rect.size.width++;
            rect.size.height++;
        } else {
            rect.origin.x++;
            rect.size.width--;
            rect.size.height--;
        }
        self.frame = rect;
    }
    
    flags.selected = selected;
    [self setNeedsDisplay];
}

- (BOOL)isHighlighted { return flags.highlighted; }

- (void)setHighlighted:(BOOL)highlighted
{
    if (self.type == KalTileTypeDisable)
    {
        flags.highlighted = NO;
        return;
    }
    
    if (flags.highlighted == highlighted)
        return;
    
    flags.highlighted = highlighted;
    [self setNeedsDisplay];
}

- (BOOL)isMarked { return flags.marked; }

- (void)setMarked:(BOOL)marked
{
    if (flags.marked == marked)
        return;
    
    flags.marked = marked;
    [self setNeedsDisplay];
}

- (KalTileType)type { return flags.type; }

- (void)setType:(KalTileType)tileType
{
    if (flags.type == tileType)
        return;
    
    // workaround since I cannot draw outside of the frame in drawRect:
    CGRect rect = self.frame;
    if (tileType == KalTileTypeToday) {
        rect.origin.x--;
        rect.size.width++;
        rect.size.height++;
    } else {
        rect.origin.x++;
        rect.size.width--;
        rect.size.height--;
    }
    self.frame = rect;
    
    flags.type = tileType;
    [self setNeedsDisplay];
}

- (BOOL)isToday { return flags.type == KalTileTypeToday; }

- (BOOL)belongsToAdjacentMonth { return flags.type == KalTileTypeAdjacent; }

- (BOOL)enabled {return flags.type != KalTileTypeDisable; }

- (void)dealloc
{
    [date release];
    [super dealloc];
}

@end
