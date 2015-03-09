//
//  ThermometerView.m
//  2014621
//
//  Created by  on 14-6-30.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "ThermometerView.h"
#import "CircleProgressBackground.h"
#import "CircleProgressInfilling.h"
@implementation ThermometerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return  self;
}

- (void)awakeFromNib
{
    [self initView];
}

- (void)initView
{
    _width = 20;
    _circleProgressBackground = [[CircleProgressBackground alloc] init];
    _circleProgressBackground.backgroundColor = [UIColor clearColor];
    _circleProgressInfilling = [[CircleProgressInfilling alloc] init];
    _circleProgressInfilling.backgroundColor = [UIColor clearColor];
    _LedNumberView = [[LedNumberView alloc ]init];
    _LedNumberView.backgroundColor = [UIColor clearColor];
    [self insertSubview:_circleProgressInfilling atIndex:1];
    [self insertSubview:_circleProgressBackground atIndex:2];
    [self insertSubview:_LedNumberView atIndex:0];
}

- (void)drawRect:(CGRect)rect
{
    [self drawCircleProgress:rect];
    [self drawLedNumber:rect];
    
}

- (void)drawLedNumber:(CGRect)rect
{
    if (rect.size.width > rect.size.height) {
        _LedNumberView.frame = CGRectMake(0, 0, 2*rect.size.height/3, rect.size.height/3);
    } else {
        _LedNumberView.frame = CGRectMake(0, 0, 2*rect.size.width/3, rect.size.width/3);
    }
    
    _LedNumberView.layer.position = CGPointMake(rect.size.width/2, rect.size.height/2);
    _LedNumberView.value = _value;
}

- (void)drawCircleProgress:(CGRect)rect
{
    _circleProgressBackground.frame = rect;
    _circleProgressInfilling.frame  = rect;
    //宽度，值，宽度
    _circleProgressBackground.width = _width + 5;
    _circleProgressInfilling.value  = (_value - _minValue) / (_maxValue - _minValue);
    _circleProgressInfilling.width  = _width;
}

- (void)setWidth:(float)width
{
    _width = width > 20 ? 20 : width;
    [self setNeedsDisplay];
}

- (void)setValue:(float)value
{
    _value = value;
    [self setNeedsDisplay];
}

@end
