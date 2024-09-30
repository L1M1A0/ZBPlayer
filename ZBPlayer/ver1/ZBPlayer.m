//
//  ZBPlayer.m
//  OSX
//
//  Created by Li28 on 2019/4/7.
//  Copyright © 2019 Li28. All rights reserved.
//

#import "ZBPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <VLCKit/VLCKit.h>
#import "AFNetworking.h"
#import "Masonry.h"
#import "ISSoundAdditions.h"//音量管理

#import "ZBDataObject.h"
#import "ZBMacOSObject.h"
#import "ZBPlayerSection.h"
#import "ZBPlayerRow.h"
#import "ZBAudioModel.h"
#import "ZBAudioObject.h"
#import "ZBPlayerSplitView.h"
#import "ZBSliderViewController.h"
#import "ZBPlaybackModelViewController.h"
//#import <objc/runtime.h>
#import "ZBAudioOutlineView.h"
#import "KRCOperate.h"

#define kListNamesKey @"kListNamesKey"//存数组转字符串，播放列表路径


@interface ZBPlayer ()<NSSplitViewDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource,AVAudioPlayerDelegate,ZBPlayerSectionDelegate,ZBPlayerRowDelegate,NSTableViewDelegate>
{
    
}
@property (nonatomic, strong) ZBMacOSObject *object;
@property (nonatomic, strong) ZBDataObject *dataObject;

#pragma mark - 常用功能
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
/** 歌词背景窗口 */
@property (nonatomic, strong) NSTextView *lrcTextView;
#pragma mark - 主功能
/** 创建列表 */
@property (nonatomic, strong) NSButton *createListBtn;


#pragma mark - 主界面
/** 播放器主活动界面 左边存放歌曲列表，右边显示歌词等其他界面 */
@property (nonatomic, strong) ZBPlayerSplitView *playerMainBoard;
/** 歌曲列表层级页面 */
@property (nonatomic, strong) ZBAudioOutlineView *audioListOutlineView;
/** 歌曲列表层级页面 的背景页面 */
@property (nonatomic, strong) NSScrollView *audioListScrollView;


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
/** 当前播放的歌曲在总列表中的index*/
@property (nonatomic, assign) NSInteger currentSection;
/** 当前播放的歌曲在所在列表中的index*/
@property (nonatomic, assign) NSInteger currentRow;
/** 上一次播放的歌曲在总列表中的index*/
@property (nonatomic, assign) NSInteger lastSection;
/** 上一次播放的歌曲在所在列表中的index*/
@property (nonatomic, assign) NSInteger lastRow;
/** 是否正在播放  */
@property (nonatomic, assign) BOOL isPlaying;
/** 播放模式 是否是随机播放 优先级 */
@property (nonatomic, assign) BOOL isPlayModelRandom;
/** 播放模式 是否允许自动切换列表 优先级 */
@property (nonatomic, assign) BOOL isPlayModelSwitchList;
/** 播放模式 是否单曲循环 优先级最高 */
@property (nonatomic, assign) BOOL isPlayModelSingleRepeat;

/** 主色调 */
@property (nonatomic, strong) NSColor *mainColor;

@property (nonatomic, assign) CFRunLoopTimerRef timerForRemainTime;
/** VLC 播放模式下，当前歌曲的播放进度 */
@property (nonatomic, assign) int vlcCurrentTime;

@end

@implementation ZBPlayer

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
    self.title = @"ZBPlayer";
    
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
    self.isVCLPlayMode = YES;
    [self initData];

    //注：似乎没法使用懒加载，只能手动调用了
    [self playerMainBoard];
    [self audioListOutlineView];
    [self audioListScrollView];
    [self controllBar];
    [self addNotification];
    [self addSubViews];
    [_audioListOutlineView reloadData];
    
//    NSTreeController *dfdf = [[NSTreeController alloc]init];

}


- (void)addSubViews{
    NSView *view1 = [self viewForSplitView:[NSColor orangeColor]];
    //增加左右分栏视图,数量任意加
    [_playerMainBoard addSubview:view1];
    [view1 addSubview:_audioListScrollView];
    [_audioListScrollView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view1.mas_top).with.offset(0);
        make.bottom.equalTo(view1.mas_bottom).with.offset(0);
        make.left.equalTo(view1.mas_left).with.offset(0);
        make.right.equalTo(view1.mas_right).with.offset(0);
    }];
    
    NSScrollView *textScrollView = [[NSScrollView alloc]initWithFrame:CGRectMake(0, 0, 500, 500)];
    //    [textScrollView setBorderType:NSNoBorder];
    [textScrollView setHasVerticalScroller:YES];
    [textScrollView setHasHorizontalScroller:YES];
    [textScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    self.lrcTextView = [[NSTextView alloc]initWithFrame:NSMakeRect(0, 0, 400, 500)];
    self.lrcTextView.wantsLayer = YES;
    self.lrcTextView.layer.backgroundColor = [NSColor greenColor].CGColor;
    [self.lrcTextView setMinSize:NSMakeSize(0.0, textScrollView.frame.size.height - 80)];
    [self.lrcTextView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self.lrcTextView setVerticallyResizable:YES];
    [self.lrcTextView setHorizontallyResizable:YES];
    [self.lrcTextView setAutoresizingMask:NSViewWidthSizable];
    [[self.lrcTextView textContainer]setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.lrcTextView textContainer]setWidthTracksTextView:YES];
    [self.lrcTextView setFont:[NSFont fontWithName:@"PingFang-SC-Regular" size:17.0]];
    [self.lrcTextView setEditable:NO];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.lineSpacing = 10;//行间距
    [self.lrcTextView setDefaultParagraphStyle:style];

    [textScrollView setDocumentView:self.lrcTextView];
    [_playerMainBoard addSubview:textScrollView];
    
}

- (NSView *)viewForSplitView:(NSColor *)color{
    //设置frame的值似乎没什么意义
    NSView *leftView = [[NSView alloc]initWithFrame:NSZeroRect];
    leftView.autoresizingMask = NSViewMinXMargin;
    leftView.wantsLayer = YES;
    leftView.layer.backgroundColor = color.CGColor;
    [leftView setAutoresizesSubviews:YES];
    return leftView;
}


#pragma mark - UI


#pragma mark playerMainBoard
/**
 播发器主面板

 @return <#return value description#>
 */
-(ZBPlayerSplitView *)playerMainBoard{
    if(!_playerMainBoard){
        _playerMainBoard = [[ZBPlayerSplitView alloc]init];
        _playerMainBoard.dividerStyle = NSSplitViewDividerStyleThick;
        _playerMainBoard.vertical = YES;
        _playerMainBoard.delegate = self;
        _playerMainBoard.wantsLayer = YES;
        _playerMainBoard.layer.backgroundColor = [NSColor greenColor].CGColor;
        [_playerMainBoard adjustSubviews];
        [self.contentView addSubview:_playerMainBoard];
        [_playerMainBoard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(0);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-70);
            make.left.equalTo(self.contentView.mas_left).offset(0);
            make.right.equalTo(self.contentView.mas_right).offset(0);
        }];
        
        //增加左右视图
//        [_playerMainBoard addSubview:view1];
//        [_playerMainBoard addSubview:view2];
//    [_playerMainBoard insertArrangedSubview:[self viewForSplitView:[NSColor orangeColor]] atIndex:1];
//            [_playerMainBoard drawDividerInRect:NSMakeRect(80, 0, 50, 50)];
        [_playerMainBoard setPosition:100 ofDividerAtIndex:1];
    }
    return _playerMainBoard;
}



-(ZBAudioOutlineView *)audioListOutlineView{
    if (!_audioListOutlineView) {
     
        _audioListOutlineView = [[ZBAudioOutlineView alloc]init];
        _audioListOutlineView.delegate = self;
        _audioListOutlineView.dataSource = self;
        _audioListOutlineView.wantsLayer = YES;
        
        //设置行与行之间的交替变化属性，如颜色等
//        [_audioListOutlineView setIndentationPerLevel:11];
//        [_audioListOutlineView setAutoresizesOutlineColumn:NO];
//        [_audioListOutlineView setUsesAlternatingRowBackgroundColors:NO];
        
     
//        _audioListOutlineView.tableViewDelegate = self;
//        [_audioListOutlineView makeViewWithIdentifier:NSOutlineViewDisclosureButtonKey owner:self];
//        _audioListOutlineView.allowsMultipleSelection = NO;
        _audioListOutlineView.backgroundColor = [NSColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
        //    _audioListOutlineView.layer.backgroundColor = [NSColor blueColor].CGColor;
        //    [self.contentView addSubview:s_audioListOutlineView];
        //    _audioListOutlineView.outlineTableColumn.hidden = YES;
        NSTableColumn *column1 = [[NSTableColumn alloc]initWithIdentifier:@"name"];//NSOutlineViewDisclosureButtonKey
        column1.title = @" ";//@"可创建一个空的，不创建的话，内容会跑到bar底下";
        [_audioListOutlineView addTableColumn:column1];
        
    }
    
    return _audioListOutlineView;
}

-(NSScrollView *)audioListScrollView{
    if(!_audioListScrollView){
        _audioListScrollView = [[NSScrollView alloc] init];
        [_audioListScrollView setHasVerticalScroller:YES];
        [_audioListScrollView setHasHorizontalScroller:NO];
        [_audioListScrollView setFocusRingType:NSFocusRingTypeNone];
        [_audioListScrollView setAutohidesScrollers:YES];
        [_audioListScrollView setBorderType:NSBezelBorder];
        [_audioListScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [_audioListScrollView setDocumentView:_audioListOutlineView];
    }
    return _audioListScrollView;
}

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
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
        make.height.mas_equalTo(8);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
    
    self.audioNameTF = [self textField:NSMakeRect(270, 23, 450, 20) holder:@"歌名" fontsize:12];
    self.durationTF  = [self textField:NSMakeRect(270, 43, 450, 15) holder:@"时长" fontsize:10];
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
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumeSliderIsChanging:) name:@"volumeSliderIsChanging" object:nil];
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
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playModelChanging:) name:@"playbackModelChanging" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playModelSwitchList:) name:@"playbackModelSwitchList" object:nil];
    return _playbackModelPopover;
}

-(void)playModelChanging:(NSNotification *)noti{
    NSNumber *tag = noti.object[@"playbackModel"];
    if ([tag isEqual:@(0)]) {
        NSLog(@"isCrossList_noti_随机播放_%@",tag);
        self.isPlayModelRandom = YES;
        self.isPlayModelSingleRepeat = NO;
        [self.playbackModelBtn setTitle:@"随机"];
    }else if ([tag isEqual:@(1)]){
        NSLog(@"isCrossList_noti_循序播放_%@",tag);
        self.isPlayModelRandom = NO;
        self.isPlayModelSingleRepeat = NO;
        [self.playbackModelBtn setTitle:@"顺序"];
    }else if ([tag isEqual:@(2)]){
        NSLog(@"isCrossList_noti_单曲循环_%@",tag);
        [self.playbackModelBtn setTitle:@"单曲"];
        self.isPlayModelSingleRepeat = YES;
    }
}
-(void)playModelSwitchList:(NSNotification *)noti{
    NSNumber *tag = noti.object[@"isSwitchList"];
    if ([tag isEqual:@(0)]) {
        NSLog(@"isSwitchList_noti_不允许跨列表_%@",tag);
        self.isPlayModelSwitchList = NO;
    }else if ([tag isEqual:@(1)]){
        NSLog(@"isSwitchList_noti_允许跨列表_%@",tag);
        self.isPlayModelSwitchList = YES;
    }
    
}

/** 随机播放 下一首音轨随机计算*/
-(void)randomNum{
    //允许自动切换列表的时候才改变currentSection的值
    if(self.isPlayModelSwitchList == YES){
        u_int32_t sectionCount = (u_int32_t)self.treeModel.childNodes.count - 1;//减去播放历史的表
        u_int32_t section = arc4random_uniform(sectionCount);
        self.currentSection = section;
    }
    u_int32_t childsCount = (u_int32_t)[[self.treeModel.childNodes[self.currentSection] childNodes] count];
    u_int32_t row = arc4random_uniform(childsCount);
    self.currentRow = row;
}

/** 是否播放 */
-(void)setIsPlaying:(BOOL)isPlaying{
    _isPlaying = isPlaying;
    if(isPlaying == YES){
        //播放
        if (self.currentRow > [[self.treeModel.childNodes[self.currentSection] childNodes] count] || !self.currentRow) {
            self.currentRow = 0;
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

#pragma mark -  NSSplitViewDelegate
/** 设置每个栏的最小值，可以根据dividerIndex单独设置 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (dividerIndex == 0) {
        return 400;
    }else{
        return 600;
    }
}
/** 设置每个栏的最大值，可以根据dividerIndex单独设置 */
-(CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex{
    if (dividerIndex == 0) {
        return 500;
    }else{
        return 600;
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


//3.实现数据源协议
#pragma mark - NSOutlineViewDataSource
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

#pragma mark - NSOutlineViewDelegate

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
-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{

    TreeNodeModel *model = item;

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



-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TreeNodeModel *model = (TreeNodeModel*)[self.audioListOutlineView itemAtRow:row];

    NSView *result  =  [self.audioListOutlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    //可以通过这个代理填充数据，也可以通过NSTableRowView（可以自定义）中的drawRect:方法赋值。注：此处需要注意子控件的类型
    NSArray *subviews = [result subviews];
    //NSImageView *imageView = subviews[0];
    NSTextField *field = subviews[1];
    field.stringValue = model.name;
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


-(void)outlineView:(NSOutlineView *)outlineView didClickTableColumn:(NSTableColumn *)tableColumn{
    NSLog(@"tableColumn_%@",tableColumn);
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
            self.currentRow != childIndexForItem ||
//            (self.currentSection == self.lastSection && self.currentRow != childIndexForItem) ||
            (self.currentRow == childIndexForItem && self.currentSection != self.lastSection)
            ){
            //记录上一次播放的位置
            self.lastSection = self.currentSection;
            self.lastRow     = self.currentRow;
            
            //更新播放位置
            self.currentSection = model.sectionIndex;
            self.currentRow = childIndexForItem;
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
    NSInteger childIndexForItem = [self.audioListOutlineView childIndexForItem:model];
    if (model.nodeLevel == 1) {
        //列表第一层 播放
        if(self.currentRow != childIndexForItem){
            self.currentRow = childIndexForItem;
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
                [self.audioListOutlineView expandItem:myModel expandChildren:NO];
            }else{
                [self.audioListOutlineView collapseItem:myModel collapseChildren:NO];
            }
        }else{
            if(myModel.isExpand == YES){
                mo.isExpand = NO;
                [self.audioListOutlineView collapseItem:mo collapseChildren:NO];
            }
        }
        [self.treeModel.childNodes removeObjectAtIndex:i];
        [self.treeModel.childNodes insertObject:mo atIndex:i];
    }
    
    for (id view in self.audioListOutlineView.subviews) {
        if([view isKindOfClass:[ZBPlayerSection class]]){
            ZBPlayerSection *sec = (ZBPlayerSection *)view;
            TreeNodeModel *mo = self.treeModel.childNodes[sec.model.rowIndex];
            sec.isImageExpand = mo.isExpand;
        }
    }
}


#pragma mark - 面板：NSOpenPanel 读取电脑文件 获取文件名，路径
- (void)openPanel{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES ;//----------“是否允许选择文件”
    openDlg.canChooseDirectories = YES;//-----“是否允许选择目录”
    openDlg.allowsMultipleSelection = YES;//--“是否允许多选”
    openDlg.allowedFileTypes = @[@"mp3",@"flac",@"wav",@"aac",@"m4a",@"wma",@"ape",@"ogg",@"alac"];//---“允许的文件名后缀”
    openDlg.treatsFilePackagesAsDirectories = YES;
    __weak ZBPlayer * weakSelf = self;
    [openDlg beginWithCompletionHandler: ^(NSInteger result){
        if(result == NSModalResponseOK){
            NSArray *fileURLs = [openDlg URLs];//“保存用户选择的文件/文件夹路径path”
            NSLog(@"获取本地文件的路径：%@",fileURLs);
            [weakSelf localFiles:[NSMutableArray arrayWithArray:fileURLs]];
        }
    }];
}

#pragma mark - 数据源
-(void)initData{

    self.currentRow = 0;
    //获取缓存在本地的列表路径
    //1.重新查找
//    NSMutableArray *arr =  [ZBAudioObject getPlayList];
//    if (arr.count > 0) {
//        [self localFiles:arr];
//    }
    //2. 从历史记录中读取
    NSMutableArray *musicList = [ZBAudioObject getMusicList];
    if (musicList.count > 0) {
        self.treeModel = [[TreeNodeModel alloc]init];
        self.treeModel.childNodes = [NSMutableArray arrayWithArray:musicList];
        [self.audioListOutlineView reloadData];
    }else{
        self.treeModel = [[TreeNodeModel alloc]init];
        //根节点
        TreeNodeModel *rootNode1 = [self node:@"默认列表" level:0 superLevel:-1];
        TreeNodeModel *history   = [self node:@"播放历史" level:0 superLevel:-1];
        [self.treeModel.childNodes addObjectsFromArray:@[rootNode1,history]];
    }


}

-(TreeNodeModel *)node:(NSString *)text level:(NSInteger)level superLevel:(NSInteger)superLevel{
    TreeNodeModel *nod = [[TreeNodeModel alloc]init];
    nod.name = text;
    nod.isExpand = NO;
    nod.nodeLevel = level;
    nod.superLevel = superLevel;
    return nod;
}

/**
 根据路径数组，分别读取本地路径下的文件

 @param fileURLs <#fileURLs description#>
 */
-(void)localFiles:(NSMutableArray *)fileURLs{
    [ZBAudioObject savePlayList:fileURLs];
    NSMutableArray *baseUrls = [NSMutableArray array];
    NSMutableArray *sectionTitles = [NSMutableArray array];
    for(NSURL *url in fileURLs) {
        //NSString *string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        NSString *filePath = [[NSString stringWithFormat:@"%@",url] stringByRemovingPercentEncoding];
        NSArray *ar = [filePath componentsSeparatedByString:@"/"];
        if([ar.lastObject isEqualToString:@""]){
            NSLog(@"folderName：%@，filePath：%@",ar[ar.count - 2],filePath);
            [baseUrls addObject:url.path];
            [sectionTitles addObject:ar[ar.count-2]];
        }
    }
    //NSString *sourcePath = self.localMusicBasePath.length == 0 ? @"/Volumes/mac biao/music/日系/" : [NSString stringWithFormat:@"%@/",self.localMusicBasePath];
    //dispatch_queue_t que = dispatch_queue_create("rer", DISPATCH_QUEUE_CONCURRENT);
    NSMutableArray *localMusics = [NSMutableArray array];
    for (int i = 0; i < sectionTitles.count; i++) {
        NSMutableArray *arr = [NSMutableArray array];
        [localMusics addObject:arr];
        //dispatch_async(que, ^{
        //更新列表
        ZBAudioObject *ado = [[ZBAudioObject alloc]init];
        [ado audioInPath:baseUrls[i]];
        [localMusics[i] addObjectsFromArray:ado.audios];
        //});
    }
    self.treeModel = [[TreeNodeModel alloc]init];
    
    //2级节点
    for(int i = 0; i< localMusics.count; i++){
        NSMutableArray *audios = localMusics[i];
        //根节点
        TreeNodeModel *rootNode1 = [self node:[NSString stringWithFormat:@"%@ [%ld]",sectionTitles[i],audios.count] level:0 superLevel:-1];
        rootNode1.sectionIndex = -1;//根节点没有sectionIndex
        rootNode1.rowIndex = i;
        
        //排序
        //NSMutableArray *sortAudios = [weakSelf defaultSort:audios];
        NSMutableArray *sortAudios = [self.dataObject localSort:audios];
        for(int j = 0; j < [sortAudios count]; j++){
            ZBAudioModel *audio = sortAudios[j];
            TreeNodeModel *childNode = [self node:audio.title level:1 superLevel:0];
            childNode.audio = audio;
            childNode.sectionIndex = i;
            childNode.rowIndex     = j;
            [rootNode1.childNodes addObject:childNode];
        }
        [self.treeModel.childNodes addObjectsFromArray:@[rootNode1]];
    }
    TreeNodeModel *history   = [self node:@"播放历史" level:0 superLevel:-1];
    history.sectionIndex = -1;//根节点没有sectionIndex
    history.rowIndex     = localMusics.count;
    [self.treeModel.childNodes addObject:history];
    [self.audioListOutlineView reloadData];
    

    [ZBAudioObject saveMusicList:self.treeModel.childNodes];

}

#pragma mark - 音乐
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        [self changeAudio:YES];
    }
}


/** 切歌  isNext：是否是下一首歌*/
- (void)changeAudio:(BOOL)isNext{
    if (self.treeModel != nil && self.treeModel.childNodes.count > 0) {
        //记录上一次播放的位置
        self.lastSection = self.currentSection;
        self.lastRow     = self.currentRow;
        
        if (self.isPlayModelSingleRepeat == YES) {
            //单曲循环，不切换音频索引
            [self startPlaying];
        }else{
            if (self.isPlayModelRandom == YES) {
                //随机播放，并判断是否需要切换列表
                [self randomNum];
            }else{
                //下一首歌
                if(isNext == YES){
                    if(self.isPlayModelSwitchList == YES){
                        //循序播放，自动切换列表
                        if (self.currentRow + 1 >= [[self.treeModel.childNodes[self.currentSection] childNodes] count]) {
                            if (self.currentSection + 1 >= self.treeModel.childNodes.count) {
                                self.currentSection = 0;
                            }else{
                                self.currentSection = self.currentSection + 1;
                            }
                            self.currentRow = 0;
                        }else{
                            self.currentRow = self.currentRow + 1;
                        }
                    }else{
                        //循序播放，不切换列表
                        if (self.currentRow + 1 >= [[self.treeModel.childNodes[self.currentSection] childNodes] count]) {
                            self.currentRow = 0;
                        }else{
                            self.currentRow = self.currentRow + 1;
                        }
                    }
                }else{
                    //上一首(不支持切换列表，以后考虑支持记忆前面播放的一首歌)
                    if (self.currentRow - 1 < 0) {
                        self.currentRow = 0;
                    }else{
                        self.currentRow = self.currentRow - 1;
                    }
                }
            }
            [self startPlaying];
        }
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
      
        TreeNodeModel *model = (TreeNodeModel *)[self.treeModel.childNodes[self.currentSection] childNodes][self.currentRow];
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
//        [self.audioListOutlineView reloadData];
//        [self.audioListOutlineView reloadItem:[self.treeModel.childNodes lastObject]];
//        [self.audioListOutlineView beginUpdates];
//        [self.audioListOutlineView insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0]  inParent:@(1) withAnimation:NSTableViewAnimationEffectFade];
//        [self.audioListOutlineView endUpdates];
        self.progressSlider.integerValue = 0;
        self.audioNameTF.stringValue = audio.title;
        self.audioNameTF.toolTip = audio.title;
        [self.playBtn setImage:[NSImage imageNamed:@"statusBarPauseSelected"]];
        [self.playBtn setAlternateImage:[NSImage imageNamed:@"statusBarPause"]];
        [self runLoopTimerForRemainTime];
        [self reloadSectionStaus];
        //歌词
        //[self kugouApiSearchMusic:audio.title];
//        [self QQApiSearchMusic:audio.title];
        NSDictionary *id3 = [ZBAudioObject getID3:audio.path];
        NSLog(@"即将播放：%@，error__%@,ID3_%@",audio.title,error,id3);
    }
}
-(void)reloadSectionStaus{
    //如果切换了列表，收起旧列表，展开当前歌曲所在列表
    if(self.currentSection != self.lastSection){
        for (int i = 0; i < self.treeModel.childNodes.count - 1; i++) {//减去随机
            TreeNodeModel *mo = self.treeModel.childNodes[i];
            if (i == self.currentSection){
                mo.isExpand = YES;
                [self.audioListOutlineView expandItem:mo expandChildren:YES];
            } else{
                mo.isExpand = NO;
                [self.audioListOutlineView collapseItem:mo collapseChildren:YES];
            }
            [self.treeModel.childNodes removeObjectAtIndex:i];
            [self.treeModel.childNodes insertObject:mo atIndex:i];
        }
        
        for (id view in self.audioListOutlineView.subviews) {
            if([view isKindOfClass:[ZBPlayerSection class]]){
                ZBPlayerSection *sec = (ZBPlayerSection *)view;
                TreeNodeModel *mo = self.treeModel.childNodes[sec.model.rowIndex];
                sec.isImageExpand = mo.isExpand;
            }
        }
    }
    
    //位置计算错误
//    for (id view in self.audioListOutlineView.subviews) {
//        if([view isKindOfClass:[ZBPlayerRow class]]){
//            ZBPlayerRow *ro = (ZBPlayerRow *)view;
//            NSLog(@"ro.model.rowIndex_%ld",ro.model.rowIndex);
//            if(ro.model.sectionIndex == self.currentSection){
//                if(ro.model.rowIndex == self.currentRow){
//                    ro.isSelectedMe = YES;
//                }else{
//                    ro.isSelectedMe = NO;
//                }
//            }else{
//                ro.isSelectedMe = NO;
//            }
//        }
//    }
    NSLog(@"currSec:%ld,lastSecc:%ld,currRowc:%ld,lastRowc:%ld",self.currentSection,self.lastSection,self.currentRow,self.lastRow);
    //[self.audioListOutlineView reloadData];
    //页面滚动到当前row
    [self.audioListOutlineView scrollRowToVisible:self.currentRow + self.currentSection + 5];
    [self.audioListOutlineView deselectRow:self.currentRow + self.currentSection + 5];


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

#pragma mark - 歌词
/**
 分析歌名中的歌手
 @param audioName 歌名
 @return 歌手数组
 */
- (NSArray *)singers:(NSString *)audioName{
    
    NSMutableArray *singles = [NSMutableArray array];
    //前半段
    NSArray *arr1 = [audioName componentsSeparatedByString:@" -"];
    if(arr1.count == 1){
        arr1 = [audioName componentsSeparatedByString:@"-"];
    }
    NSString *name = arr1.count > 1 ? arr1[0] : audioName;
    [singles addObject:name];
    
    
    //附加歌名
    NSArray *arr2 = [audioName componentsSeparatedByString:@"- "];
    NSString *title = arr2.count > 1 ? arr2[1] : audioName;
    NSString *key = [title substringToIndex:title.length - 4];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"." withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"：" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@":" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"、" withString:@"&"];
    key = [key stringByReplacingOccurrencesOfString:@"（" withString:@"&"];
    key = [key stringByReplacingOccurrencesOfString:@"[" withString:@"&"];
    key = [key stringByReplacingOccurrencesOfString:@"【" withString:@"&"];
    key = [key stringByReplacingOccurrencesOfString:@")" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"）" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"]" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"】" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"(by" withString:@"&by"];


    //冴えない彼女-2C112- DOUBLE RAINBOW DREAMS（by：澤村・スペンサー・英梨々&大西沙織&霞ヶ丘詩羽&茅野愛衣.mp3
    NSInteger oldL = key.length;
    key = [self keyword:key separatkey:@"&by" is0:NO];
    key = [key localizedLowercaseString];
    key = [key stringByReplacingOccurrencesOfString:@"cv" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"(" withString:@"&"];

    if([key containsString:@"&"]){//多个歌手
        NSArray *mults = [key componentsSeparatedByString:@"&"];
        [singles addObjectsFromArray:mults];
    }else if (oldL > key.length){
        [singles addObject:key];
    }
    
    //去除重复
    NSArray *result = [singles valueForKeyPath:@"@distinctUnionOfObjects.self"];
    NSMutableArray *lastArr = [NSMutableArray array];
    for (int i = 0; i < result.count; i++) {
        if(![result[i] isEqualToString:@""] || [result[i] length] > 0){
            [lastArr addObject:result[i]];
        }
    }
    return [lastArr mutableCopy];
}
/** 歌名处理 */
-(NSString *)keyword:(NSString *)keyword{
    NSArray *arr1 = [keyword componentsSeparatedByString:@" -"];
    if(arr1.count == 1){
        arr1 = [keyword componentsSeparatedByString:@"-"];
    }
    NSArray *arr2 = [keyword componentsSeparatedByString:@"- "];
    NSString *name = arr1.count > 1 ? arr1[0] : keyword;
    NSString *title = arr2.count > 1 ? arr2[1] : keyword;
    NSString *key = @"";
    if (arr1.count < 2  || arr2.count < 2 ) {
        key = keyword;
    }else{
        key = [NSString stringWithFormat:@"%@ - %@",name,title];
    }
    key = [key substringToIndex:key.length - 4];
    NSString *point = [key substringFromIndex:key.length-1];
    key = [point isEqualToString:@"."] ? [key substringToIndex:key.length - 1] : key;
    key = [key stringByReplacingOccurrencesOfString:@"（" withString:@"("];
    key = [key stringByReplacingOccurrencesOfString:@"[" withString:@"("];
    key = [key stringByReplacingOccurrencesOfString:@"【" withString:@"("];
    key = [self keyword:key separatkey:@"(by"  is0:YES];
    return key;
}

/** 去除歌名后半段的 注释关键词，返回歌名 */
-(NSString *)keyword:(NSString *)keyword separatkey:(NSString*)separatkey is0:(BOOL)is0{
    keyword = [keyword localizedLowercaseString];
    if([keyword containsString:separatkey]){
        if(is0 == YES){
            return  [keyword componentsSeparatedByString:separatkey][0];
        }else{
            return  [keyword componentsSeparatedByString:separatkey][1];
        }
    }else{
        return keyword;
    }
}
/**
 查询歌曲，获取hash
 */
- (void)kugouApiSearchMusic:(NSString *)keyword{
    keyword = [self keyword:keyword];
    AFHTTPSessionManager *ma = [AFHTTPSessionManager manager];
    ma.requestSerializer = [AFJSONRequestSerializer serializer];
    ma.responseSerializer = [AFJSONResponseSerializer serializer];
    ma.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *url = [NSString stringWithFormat:@"http://mobilecdn.kugou.com/api/v3/search/song?format=json&keyword=%@&page=1&pagesize=20&showtype=1",keyword];

    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    __weak ZBPlayer * weakSelf = self;
    [ma GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"searchMusicFromKugou：%@",responseObject);
        NSArray *ar = responseObject[@"data"][@"info"];
        if (ar.count > 0) {
            [weakSelf kugouApiSearchKrc:ar[0][@"hash"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"searchMusicFromKugouError：%@",error);
    }];
}

- (void)kugouApiSearchKrc:(NSString *)hash{
    AFHTTPSessionManager *ma = [AFHTTPSessionManager manager];
    ma.requestSerializer = [AFJSONRequestSerializer serializer];
    ma.responseSerializer = [AFJSONResponseSerializer serializer];
    ma.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
//    http://www.kugou.com/yy/index.php?r=play/getdata&hash=67f4b520ee80d68959f4bf8a213f6774
    NSString *url = [NSString stringWithFormat:@"http://www.kugou.com/yy/index.php?r=play/getdata&hash=%@",hash];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    __weak ZBPlayer * weakSelf = self;
    [ma GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"searchKRCFromKugou：%@",responseObject);
        if([responseObject[@"data"] count]>0){
            weakSelf.lrcTextView.string = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"lyrics"]];
        }else{

            NSString *d = [NSString stringWithFormat:@"currentSection：%ld，lastSection：%ld,currentRow：%ld,lastRow：%ld",self.currentSection,self.lastSection,self.currentRow,self.lastRow];
            weakSelf.lrcTextView.string = [NSString stringWithFormat:@"歌词下载失败：err_code: %ld\n%@",[responseObject[@"err_code"] integerValue],d];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"searchKRCFromKugouError：%@",error);
    }];
}


/**
 查询歌曲，获取hash
 */
- (void)QQApiSearchMusic:(NSString *)keyword{
    
    NSArray *singers = [self singers:keyword];
    keyword = [self keyword:keyword];
    
    AFHTTPSessionManager *ma = [AFHTTPSessionManager manager];
    ma.requestSerializer = [AFJSONRequestSerializer serializer];
    ma.responseSerializer = [AFJSONResponseSerializer serializer];
    ma.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *url = [NSString stringWithFormat:@"https://api.bzqll.com/music/tencent/search?key=579621905&s=%@&limit=100&offset=0&type=lrc",keyword];
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    __weak ZBPlayer * weakSelf = self;
    [ma GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"QQApiSearchMusic：%@",responseObject);
        NSArray *ar = responseObject[@"data"];
        
        //对比失误率较高，应该允许选择
        NSString *songName = [keyword componentsSeparatedByString:@"- "][1];
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i < ar.count; i++){
            NSDictionary *dic = ar[i];
            NSArray *dicSingers = dic[@"singer"];
            BOOL isSameSinger   = NO;
            for (int j = 0; j < dicSingers.count; j++) {
                NSDictionary *dicj = dicSingers[j];
                NSString *js = [NSString stringWithFormat:@"%@",dicj[@"name"]];
                for (int k = 0; k < singers.count; k++) {
                    NSString *ks = [NSString stringWithFormat:@"%@",singers[k]];
                    if ([ks isEqualToString:js]) {
                        isSameSinger = YES;
                    }
                }
            }
            
            NSString *dicSong = dic[@"songname"];
            BOOL isSameSong   = NO;
            songName = [songName localizedLowercaseString];
            dicSong = [dicSong localizedLowercaseString];
            songName = [songName stringByReplacingOccurrencesOfString:@" " withString:@""];
            dicSong = [dicSong stringByReplacingOccurrencesOfString:@" " withString:@""];
            if([songName isEqualToString:dicSong]){
                isSameSong = YES;
            }else if (songName.length == dicSong.length){
                isSameSong = YES;
            }
            //
            if(isSameSong == YES && isSameSinger == YES){
                [arr addObject:dic];
            }
                
//            float pe = [self likePercent:songName OrString:dicSong];
//            NSLog(@"当前：%@，\n字段：%@",songName,dicSong);
        }
        
        if (arr.count > 0) {
            NSString *str = [NSString stringWithFormat:@"%@",arr[0][@"content"]];
            str = [str stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
            str = [str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            str = [str stringByReplacingOccurrencesOfString:@"\n " withString:@"\n"];
            weakSelf.lrcTextView.string = [NSString stringWithFormat:@"%@",str];
        }else{
            weakSelf.lrcTextView.string = keyword;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"searchMusicFromKugouError：%@",error);
        NSString *d = [NSString stringWithFormat:@"currentSection：%ld，lastSection：%ld,currentRow：%ld,lastRow：%ld",self.currentSection,self.lastSection,self.currentRow,self.lastRow];
        weakSelf.lrcTextView.string = [NSString stringWithFormat:@"歌词下载失败：err_code: %ld\n%@",error.code,d];
    }];
}

//- (float)likePercent:(NSString *)target OrString:(NSString *)orString{
//
//    int n = (int)orString.length;
//    int m = (int)target.length;
//    if (m == 0) return n;
//    if (n == 0) return m;
//    //Construct a matrix, need C99 support
//
//    int matrix[n + 1][m + 1];
//    memset(&matrix[0], 0, m+1);
//    for(int i=1; i<=n; i++) {
//        memset(&matrix[i], 0, m+1);
//        matrix[i][0]=i;
//    }
//    for(int i=1; i<=m; i++) {
//        matrix[0][i]=i;
//    }
//    for(int i=1;i<=n;i++) {
//        unichar si = [orString characterAtIndex:i-1];
//        for(int j=1;j<=m;j++){
//
//            unichar dj = [target characterAtIndex:j-1];
//            int cost;
//            if(si==dj){
//                cost=0;
//            }
//            else{
//                cost=1;
//            }
//            const int above=matrix[i-1][j]+1;
//            const int left=matrix[i][j-1]+1;
//            const int diag=matrix[i-1][j-1]+cost;
//            matrix[i][j]=min(above,min(left,diag));
//        }
//    }
//    return 100.0 - 100.0*matrix[n][m]/target.length;
//
//}



@end
