//
//  Chart.m
//  Chart
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "Chart.h"

@interface Chart ()

@property (strong, nonatomic) LineChart * lineChart;

@property (strong, nonatomic) BarChart * barChart;

@property (assign, nonatomic) id<ChartDataSource> dataSource;

@end

@implementation Chart

-(id)initwithChartDataFrame:(CGRect)rect withSource:(id<ChartDataSource>)dataSource withStyle:(ChartStyle)style{
    self.dataSource = dataSource;
    self.chartStyle = style;
    return [self initWithFrame:rect];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = NO;
    }
    return self;
}

-(void)setUpChart{
	if (self.chartStyle == ChartLineStyle) {
        if(!_lineChart){
            _lineChart = [[LineChart alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [self addSubview:_lineChart];
        }
        //选择标记范围
        if ([self.dataSource respondsToSelector:@selector(ChartMarkRangeInLineChart:)]) {
            [_lineChart setMarkRange:[self.dataSource ChartMarkRangeInLineChart:self]];
        }
        //选择显示范围
        if ([self.dataSource respondsToSelector:@selector(ChartChooseRangeInLineChart:)]) {
            [_lineChart setChooseRange:[self.dataSource ChartChooseRangeInLineChart:self]];
        }
        //显示颜色
        if ([self.dataSource respondsToSelector:@selector(Chart_ColorArray:)]) {
            [_lineChart setColors:[self.dataSource Chart_ColorArray:self]];
        }
        //显示横线
        if ([self.dataSource respondsToSelector:@selector(Chart:ShowHorizonLineAtIndex:)]) {
            NSMutableArray *showHorizonArray = [[NSMutableArray alloc]init];
            for (int i=0; i<5; i++) {
                if ([self.dataSource Chart:self ShowHorizonLineAtIndex:i]) {
                    [showHorizonArray addObject:@"1"];
                }else{
                    [showHorizonArray addObject:@"0"];
                }
            }
            [_lineChart setShowHorizonLine:showHorizonArray];

        }
        //判断显示最大最小值
        if ([self.dataSource respondsToSelector:@selector(Chart:ShowMaxMinAtIndex:)]) {
            NSMutableArray *showMaxMinArray = [[NSMutableArray alloc]init];
            NSArray *y_values = [self.dataSource Chart_yValueArray:self];
            if (y_values.count>0){
                for (int i=0; i<y_values.count; i++) {
                    if ([self.dataSource Chart:self ShowMaxMinAtIndex:i]) {
                        [showMaxMinArray addObject:@"1"];
                    }else{
                        [showMaxMinArray addObject:@"0"];
                    }
                }
                _lineChart.ShowMaxMinArray = showMaxMinArray;
            }
        }
        
		[_lineChart setYValues:[self.dataSource Chart_yValueArray:self]];
		[_lineChart setXLabels:[self.dataSource Chart_xLableArray:self]];
        
		[_lineChart strokeChart];

	}else if (self.chartStyle == ChartBarStyle)
	{
        if (!_barChart) {
            _barChart = [[BarChart alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [self addSubview:_barChart];
        }
        if ([self.dataSource respondsToSelector:@selector(ChartChooseRangeInLineChart:)]) {
            [_barChart setChooseRange:[self.dataSource ChartChooseRangeInLineChart:self]];
        }
        if ([self.dataSource respondsToSelector:@selector(Chart_ColorArray:)]) {
            [_barChart setColors:[self.dataSource Chart_ColorArray:self]];
        }
		[_barChart setYValues:[self.dataSource Chart_yValueArray:self]];
		[_barChart setXLabels:[self.dataSource Chart_xLableArray:self]];
        
        [_barChart strokeChart];
	}
}

- (void)showInView:(UIView *)view
{
    [self setUpChart];
    [view addSubview:self];
}

-(void)strokeChart
{
	[self setUpChart];
	
}



@end
