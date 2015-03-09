//
//  LedNumberView.m
//  2014621
//
//  Created by  on 14-7-2.
//  Copyright (c) 2014年 . All rights reserved.
//

#import "LedNumberView.h"

@implementation LedNumberView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initView] ;
    return  self;
}

- (void)awakeFromNib
{
    [self initView];
}

- (void)initView
{
    self.backgroundColor = [UIColor lightGrayColor];
    _label = [[UILabel alloc] init];
    _label.textAlignment = 1;
    _label.textColor = [UIColor greenColor];
    
    _label2 = [[UILabel alloc] init];
    _label2.textAlignment = 1;
    _label2.textColor = [UIColor grayColor];
    
    [self insertSubview:_label atIndex:1];
    [self insertSubview:_label2 atIndex:1];
}

- (void)drawRect:(CGRect)rect
{
    _label.frame = rect;
    _font1 = [UIFont fontWithName:@"DBLCDTempBlack" size:rect.size.height/2];
    _label.font = _font1;
    if (_value < 37) {
        _label.textColor = [UIColor greenColor];
    } else if (_value < 40) {
        _label.textColor = [UIColor yellowColor];
    } else {
        _label.textColor = [UIColor redColor];
    }
    _label.text = [NSString stringWithFormat:@"%.2f",_value];
    
    _label2.frame = CGRectMake(4*rect.size.width/5, 0, rect.size.width/5, rect.size.height/3);
    _font2 = [UIFont fontWithName:@"DBLCDTempBlack" size:rect.size.height/4];
    _label2.font = _font2;
    _label2.text = @"℃";
//    [self draw_yy];
}
//设置阴影
- (void)drawShadow
{
    //y阴影
    self.layer.shadowOffset = CGSizeMake(5, 5); //设置阴影的偏移量
    self.layer.shadowRadius = 5.0;  //设置阴影的半径
    self.layer.shadowColor = [UIColor blackColor].CGColor; //设置阴影的颜色为黑色
    self.layer.shadowOpacity = 1; //透明度
}

-(void)setValue:(float)value
{
    _value = value;
    [self setNeedsDisplay];
}

@end
