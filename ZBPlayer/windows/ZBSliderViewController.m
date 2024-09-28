//
//  ZBSliderViewController.m
//  OSX
//
//  Created by Li28 on 2019/4/21.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBSliderViewController.h"


@interface ZBSliderViewController ()

@end

@implementation ZBSliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)loadView{
    //1. 先创建 self.view,然后再往里面填子控件，否则编译不过
    //warning: could not execute support code to read Objective-C class data in the process. This may redu
    NSView *view = [[NSView alloc]initWithFrame:NSMakeRect(0, 0, 45, 140)];
//    view.wantsLayer = YES;
//    view.layer.backgroundColor = [NSColor redColor].CGColor;
    self.view = view;
    
    NSSlider *slider = [[NSSlider alloc]initWithFrame:NSMakeRect(10, 10, 25, 120)];
    slider.wantsLayer = YES;
//    slider.layer.backgroundColor = [NSColor yellowColor].CGColor;
    slider.sliderType = NSSliderTypeLinear;//线型 或者 圆钮型
    slider.vertical = YES;//是否是垂直的
    slider.minValue = 0;
    slider.maxValue = 100;
    //当前数值位置
    slider.floatValue  = self.defaltVolume * 100;
    //integerValue = 40;
    //slider.stringValue = @"40";
    
    //slider.numberOfTickMarks = 10;//标尺分节段数量，将无法设置线条颜色,且滑动指示器会变成三角模式，0是圆形
    slider.appearance = [NSAppearance currentAppearance];
    slider.trackFillColor = [NSColor redColor];//跟踪填充颜色，需要先设置appearance
    
    slider.target = self;
    slider.action = @selector(sliderAction:);
    self.slider = slider;
    [self.view addSubview:self.slider];

}

-(void)sliderAction:(NSSlider *)sender{
//    NSLog(@"sliderAction:%@",sender.stringValue);//volumeSliderIsChanging
    [[NSNotificationCenter defaultCenter]postNotificationName:@"volumeSliderIsChanging" object:@{@"stringValue":sender.stringValue}];
}

@end
