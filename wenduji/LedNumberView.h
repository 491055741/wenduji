//
//  LedNumberView.h
//  2014621
//
//  Created by  on 14-7-2.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LedNumberView : UIView
@property (nonatomic) CAGradientLayer * gradientlayer;
@property (nonatomic) CAGradientLayer * gradientlayer2;
@property (nonatomic) CAShapeLayer *shapelayer;
@property (nonatomic) NSArray * arrayColor;
@property (nonatomic) NSArray * arrayColor2;
@property (nonatomic) UILabel * label,*label2;
@property (nonatomic) UIFont * font1,*font2;
@property (nonatomic) float value;
@end
