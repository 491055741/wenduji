//
//  Chart.h
//	Version 0.1
//  Chart
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chart.h"
#import "Color.h"
#import "LineChart.h"
#import "BarChart.h"
//类型
typedef enum {
	ChartLineStyle,
	ChartBarStyle
} ChartStyle;


@class Chart;
@protocol ChartDataSource <NSObject>

@required
//横坐标标题数组
- (NSArray *)Chart_xLableArray:(Chart *)chart;

//数值多重数组
- (NSArray *)Chart_yValueArray:(Chart *)chart;

@optional
//颜色数组
- (NSArray *)Chart_ColorArray:(Chart *)chart;

//显示数值范围
- (CGRange)ChartChooseRangeInLineChart:(Chart *)chart;

#pragma mark 折线图专享功能
//标记数值区域
- (CGRange)ChartMarkRangeInLineChart:(Chart *)chart;

//判断显示横线条
- (BOOL)Chart:(Chart *)chart ShowHorizonLineAtIndex:(NSInteger)index;

//判断显示最大最小值
- (BOOL)Chart:(Chart *)chart ShowMaxMinAtIndex:(NSInteger)index;
@end


@interface Chart : UIView

//是否自动显示范围
@property (nonatomic, assign) BOOL showRange;

@property (assign) ChartStyle chartStyle;

-(id)initwithChartDataFrame:(CGRect)rect withSource:(id<ChartDataSource>)dataSource withStyle:(ChartStyle)style;

- (void)showInView:(UIView *)view;

-(void)strokeChart;

@end
