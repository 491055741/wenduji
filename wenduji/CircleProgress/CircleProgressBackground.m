//
//  ddd.m
//  2014621
//
//  Created by  on 14-7-1.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "CircleProgressBackground.h"

@implementation CircleProgressBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shapelayer = [CAShapeLayer layer];
        _shapelayer.fillColor = [[UIColor clearColor] CGColor];
        _shapelayer.strokeColor = [[UIColor redColor] CGColor];
        _shapelayer.backgroundColor = [[UIColor clearColor] CGColor];
        _shapelayer.lineJoin = kCALineJoinRound;
        _shapelayer.lineCap = kCALineCapRound;
        _shapelayer.frame = CGRectMake(0, 0, 0, 0);
    }
    return  self;
}

- (void)drawRect:(CGRect)rect
{
    _radius = (rect.size.height>rect.size.width?rect.size.width/2:rect.size.height/2)-_width/2;
    _centerPoint = CGPointMake(rect.size.width/2, rect.size.height/2);
    if (_shapelayer.frame.origin.x == 0 ||
        _shapelayer.frame.origin.y == 0 ||
        _shapelayer.frame.size.width == 0 ||
        _shapelayer.frame.size.height == 0) {
        
        _shapelayer.frame = rect;
        _shapelayer.lineWidth = _width;
        UIBezierPath * apath = [UIBezierPath bezierPath];
        [apath addArcWithCenter:_centerPoint radius:_radius startAngle:M_PI/2 endAngle:2*M_PI clockwise:YES];
        _shapelayer.path = apath.CGPath;
        _shapelayer.strokeEnd = 1;
        
        //为了旋转角度
        _shapelayer.transform = CATransform3DMakeRotation(M_PI/4, 0, 0, 1);
    }

    CGFloat components[12] = {
        0.0, 0.0, 0.0, 0.1,     //start color(r,g,b,alpha)
        1.0, 1.0, 1.0, 0.5,
        0.0, 0.0, 0.0, 0.1 //end color
    };
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, NULL,3);
    
    CGPoint start = _centerPoint;  //开始的点
    CGPoint end = _centerPoint; //结束的点
    CGFloat startRadius = _radius + _width / 2;      //半径
    CGFloat endRadius = _radius - _width / 2;          //空心半径
    CGContextRef graCtx = UIGraphicsGetCurrentContext();
    CGContextDrawRadialGradient(graCtx, gradient, start, startRadius, end, endRadius, 0);


    [self.layer setMask:_shapelayer];
//    [self drawShadow];
}

- (void)drawShadow
{
    //y阴影
    self.layer.shadowOffset = CGSizeMake(15, 5); //设置阴影的偏移量
    self.layer.shadowRadius = 5.0;  //设置阴影的半径
    self.layer.shadowColor  = [UIColor blackColor].CGColor; //设置阴影的颜色为黑色
    self.layer.shadowOpacity = 1; //透明度
}

- (void)setWidth:(float)width
{
    _width = width;
    [self setNeedsDisplay];
}

@end
