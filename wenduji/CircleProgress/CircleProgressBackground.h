//
//  ddd.h
//  2014621
//
//  Created by  on 14-7-1.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CircleProgressBackground : UIView
@property (nonatomic) CAShapeLayer * shapelayer;

@property (nonatomic) CGPoint centerPoint;
//半径，底层半径，上层半径，中间层半径
@property (nonatomic) float radius;
//温度计宽度，线的宽度
@property (nonatomic) float width;

@end
