//
//  TableViewCell.m
//  ChartView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import "ChartTableViewCell.h"
#import "Chart.h"
#import "RecordsStore.h"

@interface ChartTableViewCell ()<ChartDataSource>
{
    NSIndexPath *path;
    Chart *chartView;
}
@end

@implementation ChartTableViewCell

- (void)configUI:(NSIndexPath *)indexPath
{
    if (chartView) {
        [chartView removeFromSuperview];
        chartView = nil;
    }
    
    path = indexPath;
    
    chartView = [[Chart alloc]initwithChartDataFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-20, 150)
                                              withSource:self
                                               withStyle:indexPath.section==1?ChartBarStyle:ChartLineStyle];
    [chartView showInView:self.contentView];
}

- (NSArray *)getXTitles:(int)num
{
    NSMutableArray *xTitles = [NSMutableArray array];
    for (int i=0; i<num; i++) {
        NSString * str = [NSString stringWithFormat:@"R-%d",i];
        [xTitles addObject:str];
    }
    return xTitles;
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)Chart_xLableArray:(Chart *)chart
{

    if (path.section==0) {
        switch (path.row) {
            case 0:
                return [self getXTitles:5];
            case 1:
                return [self getXTitles:11];
            case 2:
                return [self getXTitles:7];
            case 3:
                return [self getXTitles:7];
            default:
                break;
        }
    }else{
        switch (path.row) {
            case 0:
                return [self getXTitles:11];
            case 1:
                return [self getXTitles:7];
            default:
                break;
        }
    }
    return [self getXTitles:20];
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
    
    
    NSArray *ary = @[@"22",@"44",@"15",@"40",@"42"];
    NSArray *ary1 = @[@"22",@"54",@"15",@"30",@"42",@"77",@"43"];
    NSArray *ary2 = @[@"76",@"34",@"54",@"23",@"16",@"32",@"17"];
    NSArray *ary3 = @[@"3",@"12",@"25",@"55",@"52"];
    NSArray *ary4 = @[@"23",@"42",@"25",@"15",@"30",@"42",@"32",@"40",@"42",@"25",@"33"];
    
    if (path.section==0) {
        switch (path.row) {
            case 0:
                return @[valueArray];
            case 1:
                return @[ary4];
            case 2:
                return @[ary1,ary2];
            default:
                return @[ary1,ary2,ary3];
        }
    }else{
        if (path.row) {
            return @[ary1,ary2];
        }else{
            return @[ary4];
        }
    }
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

#pragma mark 折线图专享功能

//标记数值区域
- (CGRange)ChartMarkRangeInLineChart:(Chart *)chart
{
    if (path.row==2) {
        return CGRangeMake(25, 75);
    }
    return CGRangeZero;
}

//判断显示横线条
- (BOOL)Chart:(Chart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)Chart:(Chart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return path.row==2;
}
@end
