//
//  ViewController.m
//  wenduji
//
//  Created by  on 14-7-21.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "ViewController.h"
#import "ThermometerView.h"
@interface ViewController ()
@property (nonatomic, assign) BOOL isNightMode;
@property (nonatomic, weak) IBOutlet UIStepper *stepper;
@property (nonatomic, weak) IBOutlet ThermometerView *thermometerView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    _stepper.minimumValue = _thermometerView.minValue = 35.0f;
    _stepper.maximumValue = _thermometerView.maxValue = 42.0f;
    _stepper.value = _thermometerView.value = _stepper.minimumValue;
    _stepper.stepValue = 0.1f;

    [self checkTime];
    _timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
}

- (void)checkTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    _timeLabel.text = str;
    if (_isNightMode != [self currentTimeIsNight]) {
        [self switchDayNight];
    }
}

- (BOOL)currentTimeIsNight
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    int time = [str intValue];
    return (time >= 20 || time <= 07);
}

- (IBAction)changeValue:(UIStepper*)stepper
{
    if (_thermometerView.value < 40 && stepper.value >= 40) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"高温警告" message:@"体温过高！建议您立刻联系医生或去医院检查！" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }]];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }

    _thermometerView.value = stepper.value;
}

- (IBAction)switchDayNight
{
    _isNightMode = !_isNightMode;
    self.view.backgroundColor = _isNightMode ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"star_background"]] : [UIColor whiteColor];
}

@end
