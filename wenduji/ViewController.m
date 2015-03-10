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
@property (nonatomic, weak) IBOutlet ThermometerView *thermometerView;
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _stepper.minimumValue = _thermometerView.minValue = 35.0f;
    _stepper.maximumValue = _thermometerView.maxValue = 42.0f;
    _stepper.value = _thermometerView.value = _stepper.minimumValue;
    _stepper.stepValue = 0.1f;
}

- (IBAction)changeValue:(UIStepper*)stepper
{
    _thermometerView.value = stepper.value;
}

@end
