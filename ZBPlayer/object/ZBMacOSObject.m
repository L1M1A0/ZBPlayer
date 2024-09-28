//
//  ZBMacOSObject.m
//  OSX
//
//  Created by 李振彪 on 2017/5/25.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import "ZBMacOSObject.h"

@implementation ZBMacOSObject

#pragma mark - NSView
-(NSView *)view:(NSRect)frame superView:(NSView *)superView{
    
    NSView *view = [[NSView alloc]initWithFrame:frame];
    view.wantsLayer = YES;//设置layer属性时必须先设置为YES
    view.layer.backgroundColor = [NSColor redColor].CGColor;
    [superView addSubview:view];
    return view;
}


#pragma mark - NSButton
-(NSButton *)button:(NSRect)frame title:(NSString *)title tag:(NSInteger)tag type:(NSButtonType)type target:(id)target superView:(NSView *)superView{
    NSButton *btn = [[NSButton alloc]init];
    btn.frame = frame;//NSRectMake
    btn.alignment = NSTextAlignmentCenter;
    btn.toolTip = @"这是一个按钮";
    btn.bezelStyle = NSBezelStyleRounded;
    btn.tag = tag;
    btn.target = target;
//    btn.action = @selector(btnAction:);
    [superView addSubview:btn];
    
    //以下设置中，随着title和image的代码位置不同，在界面上的显示效果也不同
    btn.bordered = YES;//是否带边框
    btn.title = title.length>0?title:@"NSButton";
    //button中显示的图象。如果去掉button的边框和文字，设置完图象属性后，按钮就变成了一个图标按钮。”
    //    btn.image = [NSImage imageNamed:@"docx"];
    
    //设置按钮类型，风格，强大
    //1.以下5种类型只有在点击的时候背景颜色发生变化,其他无明显区别
    //    [btn setButtonType:NSButtonTypeMomentaryLight];//    = 0,
    //    [btn setButtonType:NSButtonTypeToggle];//            = 2,
    //    [btn setButtonType:NSButtonTypeMomentaryPushIn];//   = 7,
    //    [btn setButtonType:NSButtonTypeAccelerator];//       = 8,
    //    [btn setButtonType:NSButtonTypeMultiLevelAccelerator];// = 9,
    
    //2.默认的时候是（左复选框+右文字）的按钮，当设置了image之后，复选框变成了image
    //    [btn setButtonType:NSButtonTypeSwitch];//            = 3,
    
    //3.默认的时候是（左单选框+右文字）的按钮，当设置了image之后，复选框变成了image
    //一组相关的 Radio Button 关联到同样的 action 方法即可，另外要求同一组 Radio Button 拥有相同的父视图。
    //    [btn setButtonType:NSButtonTypeRadio];//            = 4,
    
    //4.点击的时候，title会变化（消失）
    //    [btn setButtonType:NSButtonTypeMomentaryChange];//   = 5,
    
    //5.以下2种类型，stringValue=1有默认选中颜色，stringValue=0没选中无、颜色，
    //    [btn setButtonType:NSButtonTypePushOnPushOff];//     = 1,
    [btn setButtonType:type];//             = 6,
    //设置按钮初始选中状态，1：选中
    //    btn.state = 1;
    
    
    return btn;
}

#pragma mark - NSPopUpButton:BS
-(NSPopUpButton *)popUpButton:(NSRect)frame superView:(NSView *)superView{
    //pullsDown = YES,选中item不能同步值到输入框
    NSPopUpButton *popUpBtn = [[NSPopUpButton alloc]initWithFrame:frame pullsDown:NO];
    popUpBtn.wantsLayer = YES;
    popUpBtn.layer.backgroundColor = [NSColor greenColor].CGColor;
    [popUpBtn addItemsWithTitles:@[@"1",@"32",@"ASDF",@"FA"]];
    [popUpBtn removeItemAtIndex:1];
    [popUpBtn insertItemWithTitle:@"er" atIndex:2];
    //    [popUpBtn setButtonType:NSButtonTypeRadio];
    //    [popUpBtn.cell setArrowPosition:NSPopUpNoArrow];//无箭头
    //    [popUpBtn.cell setArrowPosition:NSPopUpArrowAtBottom];
    [popUpBtn.cell setArrowPosition:NSPopUpArrowAtCenter];
    
    popUpBtn.target = self;
    popUpBtn.action = @selector(popUpBtnAction:);
    [superView addSubview:popUpBtn];
    
    
    //    NSPopUpButtonCell *cel = [[NSPopUpButtonCell alloc]init];
    return popUpBtn;
}

-(void)popUpBtnAction:(NSPopUpButton *)sender{
    
    NSLog(@"popUpBtnAction_%ld,%@,%@",sender.indexOfSelectedItem,sender.itemTitles[sender.indexOfSelectedItem],sender.itemTitles);
}

#pragma mark - NSSegmentedControl
-(NSSegmentedControl *)segmentedControl:(NSRect)frame labels:(NSArray *)labels target:(id)target superView:(NSView *)superView{
    NSSegmentedControl *seg = [NSSegmentedControl segmentedControlWithLabels:labels trackingMode:NSSegmentSwitchTrackingSelectOne target:self action:@selector(segmentAction:)];
    seg.frame = frame;
    seg.wantsLayer = YES;
    seg.layer.backgroundColor = [NSColor redColor].CGColor;
    //    seg.segmentCount = 3;//seg的item数量
    //    seg.segmentStyle = NSSegmentStyleRounded;
    //    seg.trackingMode = NSSegmentSwitchTrackingSelectOne;
    //    seg.target = self;
    //    seg.action = @selector(segmentAction:);
    [superView addSubview:seg];
    
    return seg;
}

- (void)segmentAction:(NSSegmentedControl *)seg{
    
    NSLog(@"NSSegmentedControl_%ld",seg.selectedSegment);
    
}


#pragma mark - NSProgressIndicator
-(NSProgressIndicator *)progressIndicator:(NSRect)frame style:(NSProgressIndicatorStyle)style superView:(NSView *)superView{
    NSProgressIndicator *proIndicator = [[NSProgressIndicator alloc]initWithFrame:frame];
    //类型：圆圈NSProgressIndicatorSpinningStyle
    proIndicator.style = style;//默认，bar
    proIndicator.controlSize = NSControlSizeMini;
    proIndicator.controlTint = NSGraphiteControlTint;
    proIndicator.usesThreadedAnimation = YES;
    
    proIndicator.minValue = 0;//默认
    proIndicator.maxValue = 100;//默认
    proIndicator.doubleValue = 25.0;//需要设置indeterminate==NO
    proIndicator.indeterminate = NO;
    [proIndicator incrementBy:1];
    
    proIndicator.wantsLayer = YES;
    proIndicator.layer.backgroundColor = [NSColor brownColor].CGColor;
    [superView addSubview:proIndicator];
    [proIndicator startAnimation:proIndicator];
    
    return proIndicator;
    
}

#pragma mark - NSStepper
-(NSStepper *)stepper:(NSRect)frame superView:(NSView *)superView{
    NSStepper *stepper = [[NSStepper alloc]initWithFrame:frame];
    stepper.stringValue = @"10";
    stepper.minValue = 10;
    stepper.maxValue = 100;
    stepper.increment = 10;//步进增长量
    stepper.wantsLayer = YES;
    stepper.layer.backgroundColor = [NSColor purpleColor].CGColor;
//    stepper.target = self;
//    stepper.action = @selector(stepperAction:);
    [superView addSubview:stepper];
    return stepper;
}

#pragma mark - NSSlider
-(NSSlider *)slider:(NSSliderType)sliderType frame:(CGRect)frame superView:(NSView *)superView target:(id)target action:(SEL)action{
    
    NSSlider *slider = [[NSSlider alloc]initWithFrame:frame];
    slider.wantsLayer = YES;
    slider.layer.backgroundColor = [NSColor yellowColor].CGColor;
    slider.sliderType = sliderType;//线型 或者 圆钮型
    if (sliderType == NSSliderTypeLinear) {
        slider.vertical = NO;//是否是垂直的
    }
    //设置数值
    slider.minValue = 0;
    slider.maxValue = 100;
    //当前数值位置
    slider.integerValue = 0;
    //slider.floatValue = 29.22;
    //slider.stringValue = @"40";
    
//    slider.numberOfTickMarks = 10;//标尺分节段数量，将无法设置线条颜色,且滑动指示器会变成三角模式，0是圆形
    slider.appearance = [NSAppearance currentAppearance];
    slider.trackFillColor = [NSColor redColor];//跟踪填充颜色，需要先设置appearance
    
    slider.target = target;
    slider.action = action;
    [superView addSubview:slider];
    return slider;
    
}


@end
