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
@property (nonatomic, weak) IBOutlet UIStepper *stepper;
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _thermometerView = [[ThermometerView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.1, self.view.frame.size.height*0.2, self.view.frame.size.width*0.8, self.view.frame.size.height*0.5)];
    
    _thermometerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_thermometerView];
    
//    UIStepper *stepper = [[UIStepper alloc]initWithFrame:CGRectMake(110, self.view.bounds.size.height-100, 100, 50)];
//    [stepper addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventTouchDown];
    _stepper.minimumValue = _thermometerView.minValue = 35.0f;
    _stepper.maximumValue = _thermometerView.maxValue = 42.0f;
    _stepper.value = _thermometerView.value = _stepper.minimumValue;
    _stepper.stepValue = 0.1f;
//    [self.view addSubview:stepper];
}

- (IBAction)showChartView
{
    
}

- (IBAction)changeValue:(UIStepper*)stepper
{
    _thermometerView.value = stepper.value;
}

@end
