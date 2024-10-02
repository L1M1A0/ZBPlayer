//
//  ZBPlayer_2.m
//  OSX
//
//  Created by Li28 on 2019/4/7.
//  Copyright © 2019 Li28. All rights reserved.
//


/**
 * 注：本文件目录结构以 控件初始化+功能实现 为一组，尽量
 
 
 */

#import "ZBPlayer_2.h"
#import <AVFoundation/AVFoundation.h>
#import <VLCKit/VLCKit.h>
#import "AFNetworking.h"
#import "Masonry.h"
//#import "ISSoundAdditions.h"//音量管理

#import "ZBDataObject.h"
#import "ZBMacOSObject.h"
#import "ZBMusicStatusControllerObject.h"
#import "ZBPlayerSection.h"
#import "ZBPlayerRow.h"
#import "ZBAudioModel.h"
#import "ZBAudioObject.h"
#import "ZBPlayerSplitView.h"
#import "ZBScrollOutlineView.h"
#import "ZBScrollTableView.h"
#import "ZBScrollTextView.h"
#import "ZBSliderViewController.h"
#import "ZBPlaybackModelViewController.h"
//#import <objc/runtime.h>
#import "ZBAudioOutlineView.h"
#import "KRCOperate.h"

#define kListNamesKey @"kListNamesKey"//存数组转字符串，播放列表路径


/**
 * 分屏组件：NSSplitViewController、NSSplitView、NSSplitViewItem。
 * 列表、表格组件：NSTableView
 * 大纲视图、目录结构组件：NSOutlineView，继承自NSTableView。outline：中文意思是：大纲、纲要的意思，常用于表示目录结构图，有子级目录索引展示，可以收起和展开。
 */
@interface ZBPlayer_2 ()<NSSplitViewDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource,AVAudioPlayerDelegate,ZBPlayerSectionDelegate,ZBPlayerRowDelegate,NSTableViewDelegate,NSTableViewDataSource,NSFileManagerDelegate>
{
    
}
@property (nonatomic, strong) ZBMacOSObject *object;
@property (nonatomic, strong) ZBDataObject *dataObject;


#pragma mark - 主功能：播放功能
/** 上一曲 */
@property (nonatomic, strong) NSButton *lastBtn;
/** 播放 or 暂停 */
@property (nonatomic, strong) NSButton *playBtn;
/** 下一曲 */
@property (nonatomic, strong) NSButton *nextBtn;
/** 艺术家头像 */
@property (nonatomic, strong) NSImageView *artistImage;
/** 音频格式 */
@property (nonatomic, strong) NSTextField *formatTF;
/** 音频文件名字 */
@property (nonatomic, strong) NSTextField *audioNameTF;
/** 播放时长 */
@property (nonatomic, strong) NSTextField *durationTF;
/** 播放进度条 */
@property (nonatomic, strong) NSSlider *progressSlider;
/** 歌词按钮 */
@property (nonatomic, strong) NSButton *lyricBtn;
/** 播放循环模式：列表循环，单曲循环，随机播放，跨列表播放 */
@property (nonatomic, strong) NSButton *playbackModelBtn;
/** 播放模式选择窗口 */
@property (nonatomic, strong) NSPopover *playbackModelPopover;
/** 音量按钮 */
@property (nonatomic, strong) NSButton *volumeBtn;
/** 音量窗口 */
@property (nonatomic, strong) NSPopover *volumePopover;
/**当前音量*/
@property (nonatomic, strong) NSString *volumeString;

#pragma mark - 副功能：列表数据管理
/** 搜索历史按钮 */
@property (nonatomic, strong) NSButton *searchHistoryBtn;
/** 搜索输入框 */
@property (nonatomic, strong) ZBScrollTextView *searchScrollTextView;
/** 搜索按钮 */
@property (nonatomic, strong) NSButton *searchBtn;
/** 更换背景颜色按钮 */
@property (nonatomic, strong) NSButton *bgColorBtn;
/** 播放历史按钮 */
@property (nonatomic, strong) NSButton *playHistoryBtn;
/** 列表操作按钮 */
@property (nonatomic, strong) NSButton *listActionBtn;
/** 播放管理按钮*/
@property (nonatomic, strong) NSButton *playActionBtn;

#pragma mark - 主功能
/** 创建列表 */
@property (nonatomic, strong) NSButton *createListBtn;


#pragma mark - 主界面
/** 分屏组件 播放器主活动界面 左边存放歌曲列表，右边显示歌词等其他界面 */
@property (nonatomic, strong) ZBPlayerSplitView *playerSplitView;
/** 歌曲列表大纲、目录层级页面
 outline：中文意思是：大纲、纲要的意思，常用于表示目录结构图，有子级目录索引展示，可以收起和展开。
 */
@property (nonatomic, strong) ZBScrollOutlineView *audioListScrollOutlineView;//左侧
@property (nonatomic, strong) ZBScrollTableView   *audioListScrollTableView;//右侧
@property (nonatomic, strong) NSMutableArray *tableViewDatas;



#pragma mark - 数据
/** 本地路径音频数据，对localMusics进行加工包装，真正用于播放的数据 */
@property (nonatomic, strong) TreeNodeModel *treeModel;
/** 历史播放记录 */
//@property (nonatomic, strong) TreeNodeModel *historyPlayed;
/** 是否是使用VCL框架播放模式，0：AVAudioPlayer，1:vlcPlayer */
@property (nonatomic, assign) BOOL isVCLPlayMode;

#pragma mark - 播放器控制
/** 播发器 */
@property (nonatomic, strong) VLCMediaPlayer *vlcPlayer;
/** 播发器 */
@property (nonatomic, strong) AVAudioPlayer *avPlayer;
@property (nonatomic, strong) ZBMusicStatusControllerObject *musicStatusCtrl;

///** 是否正在播放  */
@property (nonatomic, assign) BOOL isPlaying;

/** 主色调 */
@property (nonatomic, strong) NSColor *mainColor;

@property (nonatomic, assign) CFRunLoopTimerRef timerForRemainTime;
/** VLC 播放模式下，当前歌曲的播放进度 */
@property (nonatomic, assign) int vlcCurrentTime;
@property (nonatomic, strong) NSNotification *mainNoti;

@end

@implementation ZBPlayer_2

//-(instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag{
//    self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
//    if (self) {
//        [self initWindow];
//    }
//    return self;
//    
//}

#pragma mark - 设置 window 的相关属性
/**
 设置 window 的相关属性
 */
- (void)initWindow{
    //----------1、titleBar-------
    //1、设置titlebar透明，实现titlebar的隐藏或显示效果
    self.titlebarAppearsTransparent = NO;
    
    //2、titlebar中的标题是否显示
    //self.titleVisibility = NSWindowTitleHidden;
    
    //3、设置窗口标题
    self.title = @"ZBPlayer_2";
    
    //如果设置minSize后拉动窗口有明显的大小变化，需要在MainWCtrl.xib中勾选Mininum content size
    self.minSize = NSMakeSize(900, 556);//标准尺寸

    //是否不透明
    [self setOpaque:NO];
    
    //窗口背景颜色
    NSColor *windowBackgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.5];//[NSColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
    [self setBackgroundColor: windowBackgroundColor];
    
    //可移动的窗口背景
    self.movableByWindowBackground = YES;
    //窗口显示
    //[self makeKeyAndOrderFront:self];
    
    //是否记住上一次窗口的位置,在要求打开窗口时居中的时候需要设置为NO
    //在设置窗口的位置的时候也要设置先为NO，然后再setFrame
    self.restorable = NO;
    //窗口居中
    [self center];
    
    [self viewInWindow];
    
    //KRC歌词解析测试
//    KRCOperate *krc = [KRCOperate currentKRCOperate];
//    [krc test];
}

-(void)viewInWindow{
    
    //窗口标题栏透明
    self.titlebarAppearsTransparent = YES;
    //窗口背景颜色
    self.mainColor = [NSColor colorWithCalibratedRed:0x22/255.0 green:0x22/255.0 blue:0x22/255.0 alpha:0xFF/255.0];
    [self setBackgroundColor: self.mainColor];
    
    self.object = [[ZBMacOSObject alloc]init];
    self.dataObject = [[ZBDataObject alloc]init];
    self.musicStatusCtrl = [[ZBMusicStatusControllerObject alloc]init];
    self.isVCLPlayMode = YES;
    [self initData];
    

    //注：似乎没法使用懒加载，只能手动调用了
    [self playerSplitView];
    [self controllBar];
    [self addNotification];
    [self addSubviewsIntoSplitView];
    [self.audioListScrollOutlineView.outlineView reloadData];
    
    NSMutableArray *arr1 =[NSMutableArray arrayWithArray:@[]];
    NSMutableArray *arr2 =[NSMutableArray arrayWithArray:@[]];
    for(int i = 0; i < 10000 ; i++){
        NSString *str1 = [NSString stringWithFormat:@"A %d",i];
        NSString *str2 = [NSString stringWithFormat:@"B %d",i];
        [arr1 addObject:str1];
        [arr2 addObject:str2];
    }
    self.tableViewDatas = [NSMutableArray arrayWithArray:@[arr1,arr2]];
    [self.audioListScrollTableView.tableView reloadData];
    

}



#pragma mark - 播放器功能区 播放、暂停等

-(void)controllBar{
    self.lastBtn = [self button:NSMakeRect(10, 15, 40, 40) title:@"上一曲" tag:1 image:@"statusBarPreviewSelected" alternateImage:@"statusBarPreview"];
    self.lastBtn = [self border:self.lastBtn];
    self.playBtn = [self button:NSMakeRect(60, 10, 50, 50) title:@"播放"   tag:2 image:@"statusBarPlaySelected" alternateImage:@"statusBarPlay"];
    self.playBtn = [self border:self.playBtn];
    self.nextBtn = [self button:NSMakeRect(120, 15, 40, 40) title:@"下一曲" tag:3 image:@"statusBarNextSelected" alternateImage:@"statusBarNext"];
    self.nextBtn = [self border:self.nextBtn];
    
    self.volumeString = @"50";//默认音量
    self.volumeBtn    = [self button:NSMakeRect(170, 15, 40, 40) title:@"音量" tag:4 image:@"volumeSelected" alternateImage:@"volumeSelected"];
    self.volumeBtn    = [self border:self.volumeBtn];
    [self volumePopover];//音量窗口
    
    self.playbackModelBtn = [self button:NSMakeRect(220, 15, 40, 40) title:@"播放模式" tag:5 image:@"" alternateImage:@""];
    self.playbackModelBtn = [self border:self.playbackModelBtn];
    [self.playbackModelBtn setTitle:@"顺序"];
    [self playbackModelPopover];

    //NSMakeRect(270, 15, 450, 8)
    self.progressSlider = [self.object slider:NSSliderTypeLinear frame:NSZeroRect superView:self.contentView target:self action:@selector(progressAction:)];
    self.progressSlider.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor;
//    self.progressSlider.numberOfTickMarks = 0;//标尺分节段数量，将无法设置线条颜色,且滑动指示器会变成三角模式
    self.progressSlider.appearance = [NSAppearance currentAppearance];
    self.progressSlider.trackFillColor = [NSColor redColor];//跟踪填充颜色，需要先设置appearance
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(270);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-13);
        make.height.mas_equalTo(18);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    
    self.audioNameTF = [self textField:NSMakeRect(270, 28, 450, 20) holder:@"歌名" fontsize:11];
    self.durationTF  = [self textField:NSMakeRect(270, 48, 450, 15) holder:@"时长" fontsize:9];
}

- (NSButton *)buttonTitle:(NSString *)title tag:(NSInteger)tag superView:(NSView *)superView{
    NSButton *btn = [self.object button:CGRectZero title:title tag:tag type:NSButtonTypeMomentaryChange target:self superView:superView];
    btn.wantsLayer = YES;
    btn.layer.backgroundColor = [NSColor colorWithCalibratedRed:0x2C/255.0 green:0x28/255.0 blue:0x2D/255.0 alpha:0xFF/255.0].CGColor;
    btn.action = @selector(btnAction:);
    btn.bordered = NO;//是否带边框
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = btn.frame.size.width/2;
    btn.layer.borderColor = [NSColor whiteColor].CGColor;
    btn.layer.borderWidth = 3;
    return btn;
}

- (NSButton *)button:(NSRect)frame title:(NSString *)title tag:(NSInteger)tag image:(NSString *)image alternateImage:(NSString *)alternateImage {
    NSButton *btn = [self.object button:frame title:title tag:tag type:NSButtonTypeMomentaryChange target:self superView:self.contentView];
    btn.wantsLayer = YES;
    btn.layer.backgroundColor = [NSColor colorWithCalibratedRed:0x2C/255.0 green:0x28/255.0 blue:0x2D/255.0 alpha:0xFF/255.0].CGColor;
    btn.action = @selector(btnAction:);
    
    //设置图片类型的按钮，不能设置标题，不能带边框，设置图片，可以添加鼠标悬浮提示
    btn.title = @"";
    btn.bordered = NO;//是否带边框
    btn.image = [NSImage imageNamed:image];//常态
    btn.alternateImage = [NSImage imageNamed:alternateImage];
    btn.toolTip = title;
    return btn;
}
- (NSButton *)border:(NSButton *)btn{
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = btn.frame.size.width/2;
    btn.layer.borderColor = [NSColor whiteColor].CGColor;
    btn.layer.borderWidth = 3;
    return btn;
}
-(void)btnAction:(NSButton *)sender{
    NSLog(@"sender.tag = %d",sender.tag);

    if(sender.tag == 0){
       
    }else if(sender.tag == 1){
        //上一曲
        [self changeAudio:NO];
    }else if(sender.tag == 2){
        if(self.isPlaying == NO){
            [self setIsPlaying:YES];
        }else{
            [self setIsPlaying:NO];
        }
    }else if(sender.tag == 3){
        //下一曲
        [self changeAudio:YES];
    }else if(sender.tag == 4){
        //音量控制
        [self.volumePopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSRectEdgeMaxY];
    }else if(sender.tag == 5){
        //播放模式
//        self.isPlayModelRandom = YES;
        [self.playbackModelPopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSRectEdgeMaxY];
    }
}

-(void)progressAction:(NSSlider *)slider{
//    NSLog(@"sliderValue_%ld,%f,%@",slider.integerValue,slider.floatValue,slider.stringValue);
    if (self.isVCLPlayMode == true) {
        self.vlcCurrentTime = (int)[self.dataObject timeToDuration:slider.stringValue];
        //秒转毫秒
        NSNumber *num = [NSNumber numberWithDouble:slider.doubleValue*1000];
        VLCTime *tmpTime = [VLCTime timeWithNumber:num];
        [self.vlcPlayer setTime:tmpTime];
    }else{
        //AVAudionPlayer
        self.avPlayer.currentTime = slider.integerValue;
    }
}

-(NSTextField *)textField:(NSRect)frame holder:(NSString *)holder fontsize:(CGFloat)size{

    NSTextField *tf = [NSTextField wrappingLabelWithString:@""];//[[NSTextField alloc]initWithFrame:frame];
    tf.textColor = [NSColor whiteColor];
    tf.alignment = NSTextAlignmentLeft;
    [tf setBezeled:NO];
    [tf setDrawsBackground:NO];
    [tf setEditable:NO];
    [tf setSelectable:YES];
    [tf setMaximumNumberOfLines:1];
    [[tf cell] setLineBreakMode:NSLineBreakByCharWrapping];//支持换行模式
    [[tf cell] setTruncatesLastVisibleLine:YES];//过长字符，显示省略号...
    tf.font = [NSFont systemFontOfSize:size];
    tf.placeholderString = holder;
//    tf.drawsBackground = YES;
//    tf.backgroundColor = [NSColor greenColor];
    [self.contentView addSubview:tf];

    [tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(frame.origin.x);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-frame.origin.y);
        make.height.mas_equalTo(frame.size.height);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    return tf;
}

#pragma mark 音量控制

-(NSPopover *)volumePopover{
    if(!_volumePopover){
        ZBSliderViewController *vc = [[ZBSliderViewController alloc]init];
        vc.defaltVolume = [self.volumeString floatValue]/100;//_player.volume;
        _volumePopover = [[NSPopover alloc]init];
        _volumePopover.contentViewController = vc;
        _volumePopover.behavior = NSPopoverBehaviorTransient;
        _volumePopover.animates = YES;
        _volumePopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        //[_popover close];
        
        ////监听方法只添加一次就可以了，重复添加会造成发送多个监听命令响应
        ///监听音量变化
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumeSliderIsChanging:) name:@"volumeSliderIsChanging" object:nil];
    }
    
    return _volumePopover;
}

/** 修改音量*/
-(void)volumeSliderIsChanging:(NSNotification *)noti{
//    NSLog(@"volumeSliderIsChanging:%@",noti);
    self.volumeString      = noti.object[@"stringValue"];
    self.avPlayer.volume     = [self.volumeString floatValue]/100;
    self.vlcPlayer.audio.volume = [self.volumeString intValue];
}

#pragma mark 播放模式
-(NSPopover *)playbackModelPopover{
    if(!_playbackModelPopover){
        ZBPlaybackModelViewController *vc = [[ZBPlaybackModelViewController alloc]init];
        _playbackModelPopover = [[NSPopover alloc]init];
        _playbackModelPopover.contentViewController = vc;
        _playbackModelPopover.behavior = NSPopoverBehaviorTransient;
        _playbackModelPopover.animates = YES;
        _playbackModelPopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        
        //监听方法只添加一次就可以了，重复添加会造成发送多个监听命令响应
        //监听播放模式改变：顺序、随机、循环等等
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playModelChanging:) name:@"playbackModelChanging" object:nil];
        //监听是否允许切换播放列表
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playModelSwitchList:) name:@"playbackModelSwitchList" object:nil];
    }
   

    return _playbackModelPopover;
}

-(void)playModelChanging:(NSNotification *)noti{
    NSNumber *tag = noti.object[@"playbackModel"];
    if ([tag isEqual:@(0)]) {
        NSLog(@"playModelChanging_noti_随机播放_%@",tag);
        self.musicStatusCtrl.isPlayModelRandom = YES;
        self.musicStatusCtrl.isPlayModelSingleRepeat = NO;
        [self.playbackModelBtn setTitle:@"随机"];
    }else if ([tag isEqual:@(1)]){
        NSLog(@"playModelChanging_noti_循序播放_%@",tag);
        self.musicStatusCtrl.isPlayModelRandom = NO;
        self.musicStatusCtrl.isPlayModelSingleRepeat = NO;
        [self.playbackModelBtn setTitle:@"顺序"];
    }else if ([tag isEqual:@(2)]){
        NSLog(@"playModelChanging_noti_单曲循环_%@",tag);
        [self.playbackModelBtn setTitle:@"单曲"];
        self.musicStatusCtrl.isPlayModelSingleRepeat = YES;
    }
}
-(void)playModelSwitchList:(NSNotification *)noti{
    NSNumber *tag = noti.object[@"isSwitchList"];
    if ([tag isEqual:@(0)]) {
        NSLog(@"playModelSwitchListnoti_不允许跨列表_%@",tag);
        self.musicStatusCtrl.isPlayModelSwitchList = NO;
    }else if ([tag isEqual:@(1)]){
        NSLog(@"playModelSwitchList_noti_允许跨列表_%@",tag);
        self.musicStatusCtrl.isPlayModelSwitchList = YES;
    }
    
}


/** 是否播放 */
-(void)setIsPlaying:(BOOL)isPlaying{
    _isPlaying = isPlaying;
    if(isPlaying == YES){
        //播放
        if (self.musicStatusCtrl.currentRow > [[self.treeModel.childNodes[self.musicStatusCtrl.currentSection] childNodes] count] || !self.musicStatusCtrl.currentRow) {
            self.musicStatusCtrl.currentRow = 0;
        }
        [self startPlaying];
    }else{
        //暂停
        if (self.isVCLPlayMode == YES) {
            [self.vlcPlayer pause];
            if(self.avPlayer && self.avPlayer.isPlaying == true){
                [self.avPlayer pause];
            }
        }else{
            [self.avPlayer pause];
            if(self.vlcPlayer && self.vlcPlayer.isPlaying == true){
                [self.vlcPlayer pause];
            }
        }
        [self.playBtn setImage:[NSImage imageNamed:@"statusBarPlaySelected"]];
        [self.playBtn setAlternateImage:[NSImage imageNamed:@"statusBarPlay"]];
        CFRunLoopTimerInvalidate(self.timerForRemainTime);
    }
}

#pragma mark - 计时器

/**
 设置定时器，暂时不知道怎么暂停
 */
-(void)runLoopTimerForRemainTime{
    
    
    if(_timerForRemainTime){
        CFRunLoopTimerInvalidate(self.timerForRemainTime);
        _timerForRemainTime = nil;
    }
    
    if(!_timerForRemainTime){
        CGFloat timeInterVal = 1.0;
        __weak __typeof(self) weakSelf = self;
         weakSelf.vlcCurrentTime = 0;//切歌之后自动归零
        CFRunLoopTimerRef timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + timeInterVal, timeInterVal, 0, 0, ^(CFRunLoopTimerRef timer) {
            if (weakSelf.isVCLPlayMode == true) {
                weakSelf.progressSlider.maxValue = [weakSelf.dataObject timeToDuration:self.vlcPlayer.media.length.stringValue];
                weakSelf.progressSlider.stringValue = [NSString stringWithFormat:@"%f",weakSelf.progressSlider.doubleValue + 1.0];

                /**
                 //解决有些歌在最后几秒就停了（解码出错）
                 思路1：总时长-当前播放时长，剩余时长2秒的时候，手动切歌。（不推荐使用，只能解决部分问题，超过2秒解码失败的会重新出现这样的问题）
                 思路2：设置计时变量，每一秒计时+1，当计时变量的值等于或大于当前歌曲的总时长的时候，切歌。同时，切换进度的时候，计时变量的值也要改变
  
                 //出错：有些歌在最后几秒就停了
                 //    if ([self.vlcPlayer.time.stringValue isEqualTo:self.vlcPlayer.media.length.stringValue]) {
                 //        [self changeAudio];
                 //    }
                 
                 以下是思路2的实现方式
                 */
                weakSelf.vlcCurrentTime = weakSelf.vlcCurrentTime + 1;
                NSString *remaining = [weakSelf.dataObject durationToTime:(float)weakSelf.vlcCurrentTime];
                weakSelf.durationTF.stringValue = [NSString stringWithFormat:@"%@ / %@",remaining,weakSelf.vlcPlayer.media.length.stringValue];//[NSString stringWithFormat:@"%@ / %@",weakSelf.vlcPlayer.time.stringValue,weakSelf.vlcPlayer.media.length.stringValue];
               
                double all = [weakSelf.dataObject timeToDuration:weakSelf.vlcPlayer.media.length.stringValue];
//                double cur = [weakSelf.dataObject timeToDuration:weakSelf.vlcPlayer.time.stringValue];
//                NSLog(@"vlcCurrentTime_%d,%d,%f",weakSelf.vlcCurrentTime,(int)all,all);
                if ((int)all == weakSelf.vlcCurrentTime){//(all - cur < 1.5) {
                    [weakSelf changeAudio:YES];
                }
                
            }else {
                weakSelf.progressSlider.stringValue = [NSString stringWithFormat:@"%f",weakSelf.progressSlider.doubleValue + 1.0];
                NSString *allTime = [weakSelf.dataObject durationToTime:weakSelf.avPlayer.duration];
                NSString *remaining = [weakSelf.dataObject durationToTime:weakSelf.progressSlider.doubleValue];
                weakSelf.durationTF.stringValue = [NSString stringWithFormat:@"%@ / %@",remaining,allTime];
            }
        });
        _timerForRemainTime = timer;
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), _timerForRemainTime, kCFRunLoopCommonModes);
    }
}


#pragma mark - NSSplitView 分屏控件
/**
 播发器主面板 分屏控件初始化

 @return return value description
 */
-(ZBPlayerSplitView *)playerSplitView{
    if(!_playerSplitView){
        _playerSplitView = [[ZBPlayerSplitView alloc]init];
        _playerSplitView.dividerStyle = NSSplitViewDividerStyleThick;//分隔线的样式
        _playerSplitView.vertical = YES;//方向
        _playerSplitView.delegate = self;
        _playerSplitView.wantsLayer = YES;
        _playerSplitView.layer.backgroundColor = [NSColor blueColor].CGColor;
        [_playerSplitView adjustSubviews];
        [_playerSplitView setAutoresizesSubviews:YES];
        [_playerSplitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self.contentView addSubview:_playerSplitView];
        [_playerSplitView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(0);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-70);
            make.left.equalTo(self.contentView.mas_left).offset(0);
            make.right.equalTo(self.contentView.mas_right).offset(0);
        }];
        
        //增加左右视图
//        [_playerSplitView addSubview:view1];
//        [_playerSplitView addSubview:view2];
//    [_playerSplitView insertArrangedSubview:[self viewForSplitView:[NSColor orangeColor]] atIndex:1];
//            [_playerSplitView drawDividerInRect:NSMakeRect(80, 0, 50, 50)];
        [_playerSplitView setPosition:100 ofDividerAtIndex:1];
    }
    return _playerSplitView;
}


#pragma mark 给分屏控件组件添加 大纲目录列表视图 NSOutlineView
/**
 给分屏视图组件添加子视图控件，左边大纲目录列表视图（歌曲目录列表），右边未定
 */
- (void)addSubviewsIntoSplitView{
    
    CGFloat tempWidth = self.frame.size.width/3;
    CGFloat tempHeight = self.frame.size.height - 80;
    
    
    //************增加左右分栏视图,数量任意加
    //添加分屏 1
    //分屏控件左边视图的层级关系，由底到面：_playerSplitView、scrollViewOnSplitLeft、_audioListScrollOutlineView.outlineView
    //outlineView一般不建议添加多个column，之添加一个column就行，tableView可以根据需求数量添加
    self.audioListScrollOutlineView = [[ZBScrollOutlineView alloc]initWithColumnIdentifiers:@[@"columnID1"] className:@"ZBAudioOutlineView"];
    self.audioListScrollOutlineView.frame = NSMakeRect(0, 0, tempWidth, tempHeight);
    self.audioListScrollOutlineView.outlineView.delegate = self;
    self.audioListScrollOutlineView.outlineView.dataSource = self;
    [self.playerSplitView addSubview:self.audioListScrollOutlineView];//如果后续不继续添加分屏界面，那么就不会分屏，占满窗口
    
    

    //*****右侧视图
    
    //添加分屏2
    //分屏控件右边视图的层级关系，由底到面：_playerSplitView、scrollViewOnSplitRight
    //UI顺序是从底部到上的
    NSView *splitRightView = [[NSView alloc]initWithFrame:NSMakeRect(0, 80, tempWidth, tempHeight)];
    splitRightView.wantsLayer = YES;
    splitRightView.layer.backgroundColor = [NSColor yellowColor].CGColor;
    [self.playerSplitView addSubview:splitRightView];
    

    CGFloat btnwidth = 65;
    CGFloat btnheight = 32;
    CGFloat topOff = 5;
    CGFloat splitRightTopViewHeight = btnheight * 2 + topOff * 3 + 15;
    
    self.audioListScrollTableView = [[ZBScrollTableView alloc]initWithColumnIdentifiers:@[@"column_table_ID0",@"column_table_ID1"] className:@""];
    self.audioListScrollTableView.tableView.delegate = self;
    self.audioListScrollTableView.tableView.dataSource = self;
    [splitRightView addSubview:self.audioListScrollTableView];
    [self.audioListScrollTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitRightView.mas_top).offset(splitRightTopViewHeight);
        make.bottom.equalTo(splitRightView).offset(-10);
        make.left.equalTo(splitRightView.mas_left).offset(10);
        make.width.equalTo(splitRightView.mas_width).offset(-20);
//        make.height.mas_equalTo(tempHeight-100);
    }];

    NSView *splitRightTopView = [[NSView alloc]initWithFrame:NSMakeRect(0, 80, tempWidth, tempHeight)];
    splitRightTopView.wantsLayer = YES;
    splitRightTopView.layer.backgroundColor = [NSColor greenColor].CGColor;
    [splitRightView addSubview:splitRightTopView];
    [splitRightTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitRightView.mas_top).offset(10);
        make.bottom.equalTo(self.audioListScrollTableView.mas_top).offset(-5);
        make.left.equalTo(splitRightView.mas_left).offset(10);
        make.width.equalTo(splitRightView.mas_width).offset(-20);
//        make.height.mas_equalTo(tempHeight/3);

    }];
    
    

    
    /** 搜索历史按钮 */
    self.searchHistoryBtn = [self buttonTitle:@"搜索历史" tag:21 superView:splitRightTopView];
    [self.searchHistoryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitRightTopView.mas_top).offset(topOff);
        make.left.equalTo(splitRightTopView.mas_left).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);
    }];
    
    self.searchScrollTextView = [[ZBScrollTextView alloc]initWithScrollTextView];
    [splitRightTopView addSubview:self.searchScrollTextView];
    [self.searchScrollTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitRightTopView.mas_top).offset(topOff);
        make.left.equalTo(self.searchHistoryBtn.mas_right).offset(10);
        make.width.mas_equalTo(230);
        make.height.mas_equalTo(btnheight);

    }];
    
    /** 搜索按钮 */
    self.searchBtn = [self buttonTitle:@"搜索" tag:22 superView:splitRightTopView];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitRightTopView.mas_top).offset(topOff);
        make.left.equalTo(self.searchScrollTextView.mas_right).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);

    }];
    
    /** 更换背景颜色按钮 */
    self.bgColorBtn = [self buttonTitle:@"背景颜色" tag:23 superView:splitRightTopView];
    [self.bgColorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitRightTopView.mas_top).offset(topOff);
        make.left.equalTo(self.searchBtn.mas_right).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);

    }];
    
    
    /** 播放历史按钮 */
    self.playHistoryBtn = [self buttonTitle:@"播放历史" tag:24 superView:splitRightTopView];
    [self.playHistoryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchHistoryBtn.mas_bottom).offset(5);
        make.left.equalTo(splitRightTopView.mas_left).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);
    }];
    
    /** 列表操作按钮 */
    self.listActionBtn = [self buttonTitle:@"列表操作" tag:25 superView:splitRightTopView];
    [self.listActionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.playHistoryBtn.mas_top);
        make.left.equalTo(self.playHistoryBtn.mas_right).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);
    }];
    
    /** 播放管理按钮*/
    self.playActionBtn = [self buttonTitle:@"播放管理" tag:26 superView:splitRightTopView];
    [self.playActionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.listActionBtn.mas_top);
        make.left.equalTo(self.listActionBtn.mas_right).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);
    }];
    

    
    
    
}



#pragma mark  NSSplitViewDelegate 分屏组件代理
/** 设置每个栏的最小值，可以根据dividerIndex单独设置 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    CGFloat width0 = self.frame.size.width/3;
    width0 = width0>350?350:width0;
    
    if (dividerIndex == 0) {
        return width0;
    }else{
        CGFloat tempWidth = CGRectGetWidth(self.frame) - width0;
        return tempWidth;
    }
}
/** 设置每个栏的最大值，可以根据dividerIndex单独设置 */
-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    CGFloat width0 = self.frame.size.width/3;
    width0 = width0>350?350:width0;
    if (dividerIndex == 0) {
        return width0;
    }else{
        CGFloat tempWidth = CGRectGetWidth(self.frame) - width0;
        return tempWidth;
    }
}


/**
 在缩放splitView的时候，控制指定DividerAtIndex代表的View的宽和高。
 此处，不随着splitView的尺寸变化而变化DividerAtIndex==0的viewc的尺寸
 @param oldSize 原来的尺寸，
 */
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
    CGFloat oldWidth = splitView.arrangedSubviews.firstObject.frame.size.width;
    [splitView adjustSubviews];
    [splitView setPosition:oldWidth ofDividerAtIndex:0];
}



#pragma mark - NSOutlineView 歌曲大纲列表、目录结构组件


//3.实现数据源协议
#pragma mark  NSOutlineViewDataSource 大纲目录、列表结构数据源
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    //当item为空时表示根节点.
    if(!item){
        return [self.treeModel.childNodes count];
    } else{
        TreeNodeModel *nodeModel = item;
        return [nodeModel.childNodes count];
    }
}


-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(!item){
        return self.treeModel.childNodes[index];
    }else{
        TreeNodeModel *nodeModel = item;
        return nodeModel.childNodes[index];
    }
}

//根据数据源判断该节点是否有子集节点数据，如果有，允许展开，如果没有，不允许展开
-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(nonnull id)item{
    //count 大于0表示有子节点,需要允许Expandable
    if(!item){
        return [self.treeModel.childNodes count] > 0 ? YES : NO;
    } else {
        return [self checkItem:item];
    }
}
-(BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item{
    return [self checkItem:item];
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item{
    return [self checkItem:item];
}
//检查本节点下方是否有子级节点数据
-(BOOL)checkItem:(id)item{
    TreeNodeModel *model = (TreeNodeModel *)item;
    BOOL result = model.childNodes.count > 0 ? YES : NO;
    return result;
}



#pragma mark  NSOutlineViewDelegate 大纲、目录结构视图代理

-(NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item{
    TreeNodeModel *nodeModel = item;
    //使用分级来做标识符更节省内存
    NSString *idet = [NSString stringWithFormat:@"%ld",nodeModel.nodeLevel];
    
    if (nodeModel.nodeLevel == 1) {
        ZBPlayerRow *rowView = [outlineView makeViewWithIdentifier:idet owner:self];
        
        if (rowView == nil) {
            rowView = [[ZBPlayerRow alloc]initWithLevel:nodeModel.nodeLevel];
            rowView.identifier = idet;
        }
        rowView.model = nodeModel;
        rowView.delegate = self;
        return rowView;
    }else{
//        idet = NSOutlineViewDisclosureButtonKey;
        ZBPlayerSection *rowView = [outlineView makeViewWithIdentifier:idet owner:self];
        
        if (rowView == nil) {
            rowView = [[ZBPlayerSection alloc]initWithLevel:nodeModel.nodeLevel];
            rowView.identifier = idet;
        }
        rowView.delegate = self;
        rowView.model = nodeModel;
        return rowView;
    }
}



//4.实现代理方法,绑定数据到节点视图
//列表滚动时,出现新的column时，会执行这个代理，重载数据
-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{

    TreeNodeModel *model = item;
    //根据标识符取column上的子view
    NSView *result  =  [outlineView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    //可以通过这个代理填充数据，也可以通过NSTableRowView（可以自定义）中的drawRect:方法赋值。注：此处需要注意子控件的类型
    NSArray *subviews = [result subviews];
    //NSImageView *imageView = subviews[0];
    NSTextField *field = subviews[1];
    field.stringValue = model.name;
    [field setDoubleValue:NO];
    [field setBezelStyle:NSTextFieldRoundedBezel];

    return result;
}




-(CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    TreeNodeModel *model = item;
    if(model.nodeLevel == 0){
        return ZBPlayerSectionHeight;
    }else{
        return ZBPlayerRowHeight;
    }
}


-(void)outlineView:(NSOutlineView *)outlineView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn{
    NSLog(@"鼠标点击了tableColumn_%@",tableColumn);
}
//方法相似：-(void)outlineView:(NSOutlineView *)outlineView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn
-(void)outlineView:(NSOutlineView *)outlineView didClickTableColumn:(NSTableColumn *)tableColumn{
    //可以通过identifie 区别点击的是哪一列表，也可以设置点击方法
    NSLog(@"点击了tableColumn_%@",tableColumn);
}
-(void)outlineView:(NSOutlineView *)outlineView didDragTableColumn:(NSTableColumn *)tableColumn{
    NSLog(@"拖拽了tableColumn_%@",tableColumn);
}

-(void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors{
    
}


//“5.节点选择的变化事件通知
//实现代理方法 outlineViewSelectionDidChange获取到选择节点后的通知
-(void)outlineViewSelectionDidChange:(NSNotification *)notification{
    ZBAudioOutlineView *treeView = notification.object;
    NSInteger row = [treeView selectedRow];// 当前所有已展开的row的顺数index
//    NSLog(@"[treeView itemAtRow:row].class_%@",[[treeView itemAtRow:row] class]);
    TreeNodeModel *model = (TreeNodeModel*)[treeView itemAtRow:row];
    
    //获取当前item的层级序号
    NSInteger levelForRow  = [treeView levelForRow:row];
    NSInteger levelForItem = [treeView levelForItem:model];
    NSInteger childIndexForItem = [treeView childIndexForItem:model];
//    NSLog(@"row=%ld，name=%@，levelForRow=%ld，levelForItem=%ld，childIndexForItem=%ld",row,model.name,levelForRow,levelForItem,childIndexForItem);
    
//    NSIndexSet *indexset = [treeView selectedRowIndexes];
//    NSInteger inlevel = treeView.indentationPerLevel;
//    NSIndexSet *hidenrowIndexSets = [treeView hiddenRowIndexes];
    
    if(levelForRow == 0){
        for (int i = 0; i < self.treeModel.childNodes.count - 1; i++) {//减去随机
            
            NSLog(@"%d", i);
            TreeNodeModel *mo = self.treeModel.childNodes[i];
            if(i == childIndexForItem){
                if(mo.isExpand == YES){
                    mo.isExpand = NO;
                    [treeView collapseItem:mo collapseChildren:NO];//“collapseChildren 参数表示是否收起所有的子节点。”
                }else{
                    mo.isExpand = YES;
                    [treeView expandItem:mo expandChildren:NO];//“expandChildren 参数表示是否展开所有的子节点。”
                }
            }else{
                mo.isExpand = NO;
                [treeView collapseItem:mo collapseChildren:NO];
            }

            [self.treeModel.childNodes removeObjectAtIndex:i];
            [self.treeModel.childNodes insertObject:mo atIndex:i];
        }

        for (id view in treeView.subviews) {
            if([view isKindOfClass:[ZBPlayerSection class]]){
                ZBPlayerSection *sec = (ZBPlayerSection *)view;
                TreeNodeModel *mo = self.treeModel.childNodes[sec.model.rowIndex];
                sec.model.isExpand = mo.isExpand;
                if(sec.model.rowIndex == childIndexForItem){
                    //NSLog(@"ZBPlayerSection_2_%ld,%ld",sec.model.rowIndex,childIndexForItem);
                    [sec didSelected];
                }
            }
        }

    }else if (levelForRow == 1) {
       
        //列表第一层 播放
        if (
            //self.currentSection != self.lastSection ||
            self.musicStatusCtrl.currentRow != childIndexForItem ||
//            (self.currentSection == self.lastSection && self.currentRow != childIndexForItem) ||
            (self.musicStatusCtrl.currentRow == childIndexForItem && self.musicStatusCtrl.currentSection != self.musicStatusCtrl.lastSection)
            ){
            //记录上一次播放的位置
            self.musicStatusCtrl.lastSection = self.musicStatusCtrl.currentSection;
            self.musicStatusCtrl.lastRow     = self.musicStatusCtrl.currentRow;
            
            //更新播放位置
            self.musicStatusCtrl.currentSection = model.sectionIndex;
            self.musicStatusCtrl.currentRow = childIndexForItem;
            self.isPlaying = YES;
            NSLog(@"点击row:%ld , section:%ld",childIndexForItem,model.sectionIndex);
        }else{
            NSLog(@"点击row,正在播放：%@",model.name);
        }
    }
}



//dfdf

- (void)outlineViewSelectionIsChanging:(NSNotification *)notification{
    NSLog(@"outlineViewSelectionIsChanging_选中其他行数据_%@",notification);
}


- (void)outlineViewItemWillExpand:(NSNotification *)notification{
    NSLog(@"outlineViewItemWillExpand_即将展开节点前_%@",notification);
}
- (void)outlineViewItemDidExpand:(NSNotification *)notification{
    NSLog(@"outlineViewItemDidExpand_完成展开节点_%@",notification);
}
- (void)outlineViewItemWillCollapse:(NSNotification *)notification{
    NSLog(@"outlineViewItemWillCollapse_即将收拢节点_%@",notification);
}
- (void)outlineViewItemDidCollapse:(NSNotification *)notification{
    NSLog(@"outlineViewItemDidCollapse_完成收拢节点_%@",notification);
}

#pragma mark - ZBPlayerRowDelegate
-(void)playerRow:(ZBPlayerRow *)playerRow didSelectRowForModel:(TreeNodeModel *)model{
    
    NSLog(@"ZBPlayerRow__%@",model.name);
    NSInteger childIndexForItem = [self.audioListScrollOutlineView.outlineView childIndexForItem:model];
    if (model.nodeLevel == 1) {
        //列表第一层 播放
        if(self.musicStatusCtrl.currentRow != childIndexForItem){
            self.musicStatusCtrl.currentRow = childIndexForItem;
            self.isPlaying = YES;
        }else{
            NSLog(@"正在播放：%@",model.name);
        }
    }
}
-(void)playerRow:(ZBPlayerRow *)playerRow menuItem:(NSMenuItem *)menuItem{
    if ([menuItem.title isEqualToString:kMenuItemInitializeList]) {//初始列表
        [self openPanel];
    }else if ([menuItem.title isEqualToString:kMenuItemInsertSection]) {//新增列表
        
    }else if ([menuItem.title isEqualToString:kMenuItemUpdateSection]) {//更新本组
        NSLog(@"当前组：%ld",playerRow.model.sectionIndex);
    }else if ([menuItem.title isEqualToString:kMenuItemDeleteSection]) {//删除本组
        
    }else if ([menuItem.title isEqualToString:kMenuItemLocatePlaying]) {//当前播放
        [self reloadSectionStaus];
    }else if ([menuItem.title isEqualToString:kMenuItemSearchMusic])  {//搜索音乐
        
    }else if ([menuItem.title isEqualToString:kMenuItemShowAll])      {//显示全部
        
    }else if ([menuItem.title isEqualToString:kMenuItemShowInFinder]) {//定位文件
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:playerRow.model.audio.path]]];
    }
}

-(void)playerRowMoreBtn:(ZBPlayerRow *)playerRow{
    //show file in finder 打开文件所在文件夹
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:playerRow.model.audio.path]]];
}
#pragma mark - ZBPlayerSectionDelegate
-(void)playerSectionMoreBtn:(ZBPlayerSection *)playerSection{
    [self openPanel];
}
-(void)playerSectionDidSelect:(ZBPlayerSection *)playerSection{
    
    TreeNodeModel *myModel = playerSection.model;
    for (int i = 0; i < self.treeModel.childNodes.count - 1; i++) {//减去随机
        TreeNodeModel *mo = self.treeModel.childNodes[i];
        if(i == myModel.rowIndex){
            mo = myModel;
            if(myModel.isExpand == YES){
                [self.audioListScrollOutlineView.outlineView expandItem:myModel expandChildren:NO];
            }else{
                [self.audioListScrollOutlineView.outlineView collapseItem:myModel collapseChildren:NO];
            }
        }else{
            if(myModel.isExpand == YES){
                mo.isExpand = NO;
                [self.audioListScrollOutlineView.outlineView collapseItem:mo collapseChildren:NO];
            }
        }
        [self.treeModel.childNodes removeObjectAtIndex:i];
        [self.treeModel.childNodes insertObject:mo atIndex:i];
    }
    
    for (id view in self.audioListScrollOutlineView.outlineView.subviews) {
        if([view isKindOfClass:[ZBPlayerSection class]]){
            ZBPlayerSection *sec = (ZBPlayerSection *)view;
            TreeNodeModel *mo = self.treeModel.childNodes[sec.model.rowIndex];
            sec.isImageExpand = mo.isExpand;
        }
    }
}


#pragma mark - 右侧，NSTableView的代理
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.tableViewDatas[0] count];//由于每列的row数量是相等的，所以选0即可
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([tableColumn.identifier isEqualToString:@"column_table_ID0"]){
        return self.tableViewDatas[0][row];
    }else{
        return self.tableViewDatas[1][row];
    }
    
}

/***
 * 疑似废弃代码，无用，不会执行
 * 创建tableview时执行，滚动列表时不会再执行(似乎屏蔽代码不执行也没问题)
 * 页面中没有tableView，也没有需要实现的tableView的代理
 */
//-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
//
//    NSLog(@"faosdjafpdsjaopfsdjfjaspdfjapsdojfadfapsjfpasjdfajspdfjapsdfajsop");
//    TreeNodeModel *model = (TreeNodeModel*)[self.audioListScrollOutlineView.outlineView itemAtRow:row];
//    //根据标识符取column上的子view
//    NSView *result  =  [self.audioListScrollOutlineView.outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
//    //可以通过这个代理填充数据，也可以通过NSTableRowView（可以自定义）中的drawRect:方法赋值。注：此处需要注意子控件的类型
//    NSArray *subviews = [result subviews];
//    //NSImageView *imageView = subviews[0];
//    NSTextField *field = subviews[1];
//    field.stringValue = model.name;
//    return result;
//}


#pragma mark - 面板：NSOpenPanel 读取电脑文件 获取文件名，路径
- (void)openPanel{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES ;//----------“是否允许选择文件”
    openDlg.canChooseDirectories = YES;//-----“是否允许选择目录”
    openDlg.allowsMultipleSelection = YES;//--“是否允许多选”
    openDlg.allowedFileTypes = @[@"mp3",@"flac",@"wav",@"aac",@"m4a",@"wma",@"ape",@"ogg",@"alac"];//---“允许的文件名后缀”
    openDlg.treatsFilePackagesAsDirectories = YES;
    openDlg.canCreateDirectories = YES;//显示“新建文件夹”按钮
    openDlg.title = @"导入歌曲列表";
    openDlg.message = @"选择需要导入的歌曲文件夹，每个文件夹就是一张表，歌曲按目录表展示";
    
    //初始化数据源
    __weak ZBPlayer_2 * weakSelf = self;
    self.treeModel = [[TreeNodeModel alloc]init];
    [openDlg beginWithCompletionHandler: ^(NSInteger result){
        if(result == NSModalResponseOK){
            NSArray *fileURLs = [openDlg URLs];//“保存用户选择的文件/文件夹路径path”
            NSLog(@"获取本地文件的路径：%@",fileURLs);
            
            //根据路径数组，分别读取本地路径下的文件（版本1，回调方法找寻文件）
            weakSelf.treeModel = [ZBAudioObject searchFilesInFolderPaths:[NSMutableArray arrayWithArray:fileURLs]];
            [weakSelf.audioListScrollOutlineView.outlineView reloadData];
            
            //版本2 使用文件系统寻找文件
            [weakSelf filemanagerDoInPath:[NSMutableArray arrayWithArray:fileURLs]];
        }
    }];
}

#pragma mark - 文件管理

-(void)filemanagerDoInPath:(NSMutableArray *)fileURLs{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i< fileURLs.count; i++) {
        NSLog(@"获取本地文件的路径：%@",fileURLs[i]);
//        [fm subpathsOfDirectoryAtPath:fileURLs[i] error:nil];//subpathsAtPath:fileURLs[i]]
//        [arr addObject:lsit];
//        NSLog(@"获取本地文件的路径：%@，，列表数据：%@",fileURLs[i],lsit);

    }
    NSLog(@"列表数据：%@",arr);

    
}



#pragma mark - 数据源
-(void)initData{

    self.musicStatusCtrl.currentRow = 0;
    //从历史记录中读取播放列表
    NSMutableArray *musicList = [ZBAudioObject getMusicList];
    if (musicList.count > 0) {
        self.treeModel = [[TreeNodeModel alloc]init];
        self.treeModel.childNodes = [NSMutableArray arrayWithArray:musicList];
        [self.audioListScrollOutlineView.outlineView reloadData];
    }else{
        self.treeModel = [[TreeNodeModel alloc]init];
        //根节点
        TreeNodeModel *rootNode1 = [ZBAudioObject node:@"默认列表" level:0 superLevel:-1];
        TreeNodeModel *history   = [ZBAudioObject node:@"播放历史" level:0 superLevel:-1];
        [self.treeModel.childNodes addObjectsFromArray:@[rootNode1,history]];
    }

}



#pragma mark - 音乐
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        [self changeAudio:YES];
    }
}


/** 切歌  isNext：是否是下一首歌*/
- (void)changeAudio:(BOOL)isNext{
    
    BOOL isStart = [self.musicStatusCtrl changeAudio:isNext dataSource:self.treeModel];
    if(isStart == YES){
        [self startPlaying];
    }else{
        NSLog(@"没有歌曲，不播放");
    }
    
}

#pragma mark 开始播放本地音乐
/*
 
 *参考:AVPlayer 为什么不能播放本地音乐~ http://www.cocoachina.com/bbs/read.php?tid-1743038.html
 1.要将target->capabilities->app sandbox->network->outgoing connection(clinet)勾选
 1.1 注：使用FileManager方式读取文件，似乎不用打开（待确实验证）
 
 2.如果遇到errors encountered while discovering extensions: Error Domain=PlugInKit Code=13 "query cancelled" UserInfo={NSLocalizedDescription=query cancelled}，只能加载部分文件就中断了。参考：https://my.oschina.net/rainwz/blog/2218590
 2.1 打开 Product > Scheme > Edit Scheme，在run或者其他地方的arguments下的Enviroment Variables下添加环境变量：OS_ACTIVITY_MODE 值：disable
 2.2 如果没法打印日志，那全局添加以下代码
 #ifdef DEBUG
 
 #define NSLog(format,...) printf("\n[%s] %s [第%d行] %s\n",__TIME__,__FUNCTION__,__LINE__,[[NSString stringWithFormat:format,## __VA_ARGS__] UTF8String]);
 #else
 #define NSLog(format, ...)
 #endif
 
 */
- (void)startPlaying{
    
    if(_avPlayer){
        _avPlayer = nil;
    }
    if (self.treeModel != nil && self.treeModel.childNodes.count > 0) {
      
        TreeNodeModel *model = (TreeNodeModel *)[self.treeModel.childNodes[self.musicStatusCtrl.currentSection] childNodes][self.musicStatusCtrl.currentRow];
        ZBAudioModel *audio = [model audio];
        NSError *error =  nil;
        ZBAudioObject *abo = [[ZBAudioObject alloc]init];
        if([abo isAVAudioPlayerMode:audio.extension] == YES){
            self.isVCLPlayMode = false;
            [self.vlcPlayer stop];
            
            //_player = [[AVAudioPlayer alloc] initWithData:self.audioData fileTypeHint:AVFileTypeMPEGLayer3 error:&error];
            _avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audio.path] error:&error];
            _avPlayer.delegate = self;
            [_avPlayer setVolume: [self.volumeString floatValue] / 100];
            [_avPlayer prepareToPlay];
            [_avPlayer play];
            self.progressSlider.maxValue = _avPlayer.duration;
        }else{
            self.isVCLPlayMode = true;
            [self.avPlayer stop];
            
            if (!self.vlcPlayer) {
                self.vlcPlayer = [[VLCMediaPlayer alloc]init];
            }
            VLCMedia *movie = [VLCMedia mediaWithURL:[NSURL fileURLWithPath:audio.path]];
            [self.vlcPlayer setMedia:movie];
            self.vlcPlayer.audio.volume = [self.volumeString intValue];
            [self.vlcPlayer play];
            //[_vlcPlayer setDelegate:self];
            //CGFloat currentSound = [NSSound systemVolume];

        }
        
//        [[(TreeNodeModel *)[self.treeModel.childNodes lastObject] childNodes] addObject:audio];
//        [self.audioListScrollOutlineView.outlineView reloadData];
//        [self.audioListScrollOutlineView.outlineView reloadItem:[self.treeModel.childNodes lastObject]];
//        [self.audioListScrollOutlineView.outlineView beginUpdates];
//        [self.audioListScrollOutlineView.outlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0]  inParent:@(1) withAnimation:NSTableViewAnimationEffectFade];
//        [self.audioListScrollOutlineView.outlineView endUpdates];
        self.progressSlider.integerValue = 0;
        self.audioNameTF.stringValue = audio.title;
        self.audioNameTF.toolTip = audio.title;
        [self.playBtn setImage:[NSImage imageNamed:@"statusBarPauseSelected"]];
        [self.playBtn setAlternateImage:[NSImage imageNamed:@"statusBarPause"]];
        [self runLoopTimerForRemainTime];
        [self reloadSectionStaus];
        
        //歌词 搜索
        //[self kugouApiSearchMusic:audio.title];
//        [self QQApiSearchMusic:audio.title];
        NSDictionary *id3 = [ZBAudioObject getAudioFileID3:audio.path];
        NSLog(@"即将播放：%@，error__%@,ID3_%@",audio.title,error,id3);
    }
}

/**
 调整列表的收起与展开，并定位到当前为止
 */
-(void)reloadSectionStaus{
    //如果切换了列表，收起旧列表，展开当前歌曲所在列表
    if(self.musicStatusCtrl.currentSection != self.musicStatusCtrl.lastSection){
        for (int i = 0; i < self.treeModel.childNodes.count - 1; i++) {//减去随机
            TreeNodeModel *mo = self.treeModel.childNodes[i];
            BOOL isE = NO;
            if (i == self.musicStatusCtrl.currentSection){
                mo.isExpand = YES;
                isE  = YES;
                [self.audioListScrollOutlineView.outlineView expandItem:mo expandChildren:YES];
            } else{
                mo.isExpand = NO;
                isE = NO;
                [self.audioListScrollOutlineView.outlineView collapseItem:mo collapseChildren:YES];
            }
            //这样做法可能比较耗资源
            [self.treeModel.childNodes removeObjectAtIndex:i];
            [self.treeModel.childNodes insertObject:mo atIndex:i];
            //改成这种方式
//            [[self.treeModel.childNodes objectAtIndex:i] setIsExpand:mo.isExpand];
        }
        
        for (id view in self.audioListScrollOutlineView.outlineView.subviews) {
            if([view isKindOfClass:[ZBPlayerSection class]]){
                ZBPlayerSection *sec = (ZBPlayerSection *)view;
                TreeNodeModel *mo = self.treeModel.childNodes[sec.model.rowIndex];
                sec.isImageExpand = mo.isExpand;
            }
        }
    }
    
    //位置计算错误
    NSLog(@"currSec:%ld,lastSecc:%ld,currRowc:%ld,lastRowc:%ld",self.musicStatusCtrl.currentSection,self.musicStatusCtrl.lastSection,self.musicStatusCtrl.currentRow,self.musicStatusCtrl.lastRow);
    //[self.audioListScrollOutlineView.outlineView reloadData];
    //页面滚动到当前row，根据row+section的数目总和确定位置，每+1代表多一行
    [self.audioListScrollOutlineView.outlineView scrollRowToVisible:(self.musicStatusCtrl.currentRow+1) + (self.musicStatusCtrl.currentSection+1) + 5];
    [self.audioListScrollOutlineView.outlineView deselectRow:(self.musicStatusCtrl.currentRow+1) + (self.musicStatusCtrl.currentSection+1) + 5];


}


#pragma mark - 监听窗口变化

/**
 监听窗口变化
 */
-(void)addNotification{

    //    //观察窗口拉伸
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(screenResize) name:NSWindowDidResizeNotification object:nil];
    //    //即将进入全屏
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willEnterFull:) name:NSWindowWillEnterFullScreenNotification object:nil];
    //    //即将推出全屏
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willExitFull:) name:NSWindowWillExitFullScreenNotification object:nil];
    //    //已经推出全屏
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didExitFull:) name:NSWindowDidExitFullScreenNotification object:nil];
    //    //NSWindowDidMiniaturizeNotification
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didMiniaturize:) name:NSWindowDidMiniaturizeNotification object:nil];
    //    //窗口即将关闭
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willClose:) name:NSWindowWillCloseNotification object:nil];
    
   
    
}







@end
