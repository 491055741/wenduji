//
//  RootViewController.m
//  ChartView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "ChartViewController.h"
#import "RecordsStore.h"
#import "Chart.h"
#import "Kal.h"

@interface ChartViewController () <KalCalendarDelegate, ChartDataSource>

@property (nonatomic, strong) KalViewController *kalCalendar;
@property (nonatomic, strong) Chart *chartView;
@end

@implementation ChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.kalCalendar == nil)
    {
        self.kalCalendar = [[KalViewController alloc] initWithSelectedDate:[NSDate date]];
        _kalCalendar.isSingleDate = YES;
        _kalCalendar.calendarDelegate = self;
        _kalCalendar.dataSource = nil;
        _kalCalendar.view.frame = CGRectMake(0, self.view.frame.size.height - kCalendarHeight, 320, kCalendarHeight);
        _kalCalendar.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    [self.view addSubview:_kalCalendar.view];

    self.chartView = [[Chart alloc]initwithChartDataFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-20, 150)
                                          withSource:self
                                           withStyle:ChartLineStyle];
    [_chartView showInView:self.view];

}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KalCalendar delegate method
- (void)didSelectDate:(NSDate *)date
{
    NSLog(@"%s %@", __func__, date);
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)Chart_xLableArray:(Chart *)chart
{
    NSInteger num = 5;
    NSMutableArray *xTitles = [NSMutableArray array];
    for (int i = 0; i < num; i++) {
        NSString *str = [NSString stringWithFormat:@"R-%d", i];
        [xTitles addObject:str];
    }
    return xTitles;
}

//数值多重数组
- (NSArray *)Chart_yValueArray:(Chart *)chart
{
    RecordsStore *recordsStore = [RecordsStore sharedInstance];
    //    NSArray *tempArray = recordsStore.recordsArray;
    NSMutableArray *valueArray = [NSMutableArray arrayWithCapacity:10];
    for (Record *record in recordsStore.recordsArray) {
        [valueArray addObject:[NSString stringWithFormat:@"%f", record.temperature.floatValue]];
    }
    
    return @[valueArray];
}

#pragma mark - @optional
//颜色数组
- (NSArray *)Chart_ColorArray:(Chart *)chart
{
    return @[UUGreen,UURed,UUBrown];
}
//显示数值范围
- (CGRange)ChartChooseRangeInLineChart:(Chart *)chart
{
    return CGRangeMake(40, 36);
}

@end
