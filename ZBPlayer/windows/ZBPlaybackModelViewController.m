//
//  ZBPlaybackModelViewController.m
//  OSX
//
//  Created by Li28 on 2019/5/4.
//  Copyright © 2019 Li28. All rights reserved.
//

#import "ZBPlaybackModelViewController.h"


@interface ZBPlaybackModelViewController ()

@end

@implementation ZBPlaybackModelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)loadView{
    //1. 先创建 self.view,然后再往里面填子控件，否则编译不过
    //warning: could not execute support code to read Objective-C class data in the process. This may redu
    NSView *view = [[NSView alloc]initWithFrame:NSMakeRect(0, 0, 100, 130)];
    self.view = view;
    //view.wantsLayer = YES;
    //view.layer.backgroundColor = [NSColor redColor].CGColor;
    
    NSButton *switchListBtn = [NSButton checkboxWithTitle:@"切换列表" target:self action:@selector(switchListBtnAct:)];
    switchListBtn.frame = NSMakeRect(10, 0, 80, 30);
    [self.view addSubview:switchListBtn];
    
    NSArray *models = @[@"随机播放",@"循序播放",@"单曲循环",];//,@""
    for (int i = 0; i < models.count; i++) {
        [self btn:(30+2)*(i+1) title:models[i] tag:i];
    }
}

-(void)btn:(CGFloat)y title:(NSString *)title tag:(NSInteger)tag{
    NSButton *btn = [NSButton radioButtonWithTitle:title target:self action:@selector(btnAction:)];
    btn.tag = tag;
    btn.frame = NSMakeRect(10,y,80,30);
    [self.view addSubview:btn];
}
-(void)btnAction:(NSButton *)sender{
//    NSLog(@"sender.title_%@,%ld",sender.title,sender.state);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"playbackModelChanging" object:@{@"playbackModel":@(sender.tag)}];
}
-(void)switchListBtnAct:(NSButton *)sender{
//    NSLog(@"sender.title_%@,%ld",sender.title,sender.state);
    [[NSNotificationCenter defaultCenter]postNotificationName:@"playbackModelSwitchList" object:@{@"isSwitchList":@(sender.state)}];
}

@end
