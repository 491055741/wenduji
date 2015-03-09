//
//  ThermometerView.h
//  2014621
//
//  Created by  on 14-6-30.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CircleProgressBackground.h"
#import "CircleProgressInfilling.h"
#import "LedNumberView.h"

@interface ThermometerView : UIView

@property (nonatomic) float width;
@property (nonatomic) float value;
@property (nonatomic) float minValue;
@property (nonatomic) float maxValue;
@property (nonatomic) CircleProgressBackground *circleProgressBackground;

@property (nonatomic) CircleProgressInfilling *circleProgressInfilling;

@property (nonatomic) LedNumberView *LedNumberView;

@end
