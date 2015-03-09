//
//  yuan2_dt.h
//  2014621
//
//  Created by  on 14-7-1.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CircleProgressInfilling : UIView

@property(nonatomic) CGPoint centerPoint;
//半径，底层半径，上层半径，中间层半径
@property (nonatomic) float radius;
//温度计宽度，线的宽度
@property (nonatomic) float width;

@property (nonatomic) float z1,z2;

//渐变层坐标大小
@property (nonatomic) CGRect rect1,rect2;

@property (nonatomic) float value;

@property (nonatomic) CAGradientLayer *gradientlayer1, *gradientlayer2;

@property (nonatomic) CALayer *layer_d;

@property (nonatomic) CAShapeLayer *shapelayer;

@property (nonatomic) NSArray *array1, *array2;

@property (nonatomic) UIBezierPath *path;

@property (nonatomic) CABasicAnimation *animation;
@end
