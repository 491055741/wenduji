//
//  ViewController.m
//  wenduji
//
//  Created by  on 14-7-21.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "ViewController.h"
#import "ThermometerView.h"
#import "BLEDiscovery.h"

#define RGB(R,G,B) [UIColor colorWithRed:(R)/255.0 green:(G)/255.0 blue:(B)/255.0 alpha:1.0]
#define DAY_BG_COLOR RGB(250,250,250)
#define NIGHT_BG_COLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue_background"]]
#define DAY_TIME_COLOR [UIColor blackColor]
#define NIGHT_TIME_COLOR RGB(243,241,239)

@interface ViewController () <BLEDiscoveryDelegate, ThermometerProtocol>
@property (nonatomic, assign) BOOL isNightMode;
@property (nonatomic, assign) BOOL isManualSetDayNight;
@property (nonatomic, weak) IBOutlet UIStepper *stepper;
@property (nonatomic, weak) IBOutlet ThermometerView *thermometerView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIButton *dayNightButton;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    _stepper.hidden = YES;
    _stepper.minimumValue = _thermometerView.minValue = 35.0f;
    _stepper.maximumValue = _thermometerView.maxValue = 42.0f;
    _thermometerView.width = 15;
    _stepper.value = _thermometerView.value = _stepper.minimumValue;
    _stepper.stepValue = 0.1f;

    self.view.backgroundColor = DAY_BG_COLOR;
    _timeLabel.textColor = DAY_TIME_COLOR;
    [self checkTime];
    _timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];

    [[BLEDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[BLEDiscovery sharedInstance] setPeripheralDelegate:self];

}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

- (void)checkTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *str = [formatter stringFromDate:[NSDate date]];
    _timeLabel.text = str;
    if (!_isManualSetDayNight && _isNightMode != [self currentTimeIsNight]) {
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

- (IBAction)dayNightBtnClicked
{
    _isManualSetDayNight = YES;
    [self switchDayNight];
}

- (void)switchDayNight
{
    _isNightMode = !_isNightMode;

    self.view.backgroundColor = _isNightMode ? NIGHT_BG_COLOR : DAY_BG_COLOR;
    _timeLabel.textColor = _isNightMode ? NIGHT_TIME_COLOR : DAY_TIME_COLOR;
    _dayNightButton.selected = _isNightMode;
    [[UIApplication sharedApplication] setStatusBarStyle:_isNightMode ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault];
}

#pragma mark -
#pragma mark BLEDiscoveryDelegate
/****************************************************************************/
/*                       BLEDiscoveryDelegate Methods                        */
/****************************************************************************/
- (void)discoveryDidRefresh
{
    //    [sensorsTable reloadData];
    NSLog(@"%s", __func__);
}

- (void)discoveryStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -
#pragma mark LeAntiLostAlarmProtocol Delegate Methods

/** Peripheral connected or disconnected */
- (void) ThermometerDidChangeStatus:(BLEService*)service
{
    if ( [service peripheral].state == CBPeripheralStateConnected ) {
        NSLog(@"%s Device (%@) connected", __func__, service.peripheral.name);
//        _statusLabel.text = [NSString stringWithFormat:@"%@ connected." ,service.peripheral.name ];
//        [self changeConnectStateTo:YES];
    } else {
        NSLog(@"%s Device (%@) disconnected", __func__, service.peripheral.name);
//        _statusLabel.text = @"Connecting...";
//        [self changeConnectStateTo:NO];
    }
}

- (void)ThermometerDidChangeTemperature:(CGFloat)temperature
{
    if (_thermometerView.value < 40 && temperature >= 40) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"高温警告" message:@"体温过高！建议您立刻联系医生或去医院检查！" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        }]];
        [self presentViewController:alert animated:YES completion:^{
        }];
    }

    _thermometerView.value = temperature;
}

- (void) ThermometerDidChangeBatteryLevel:(NSInteger)batteryLevel
{
    NSLog(@"%s battery level:%ld", __FUNCTION__, (long)batteryLevel);
}

/** Central Manager reset */
- (void)ThermometerDidReset
{
    NSLog(@"%s", __func__);
    //    [connectedServices removeAllObjects];
}

@end
