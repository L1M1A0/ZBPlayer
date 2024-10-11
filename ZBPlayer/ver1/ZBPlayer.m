//
//  ZBPlayer.m
//  OSX
//
//  Created by Li28 on 2019/4/7.
//  Copyright © 2019 Li28. All rights reserved.
//


/**
 * 注：本文件目录结构以 控件初始化+功能实现 为一组，尽量
 
 
 */

#import "ZBPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <VLCKit/VLCKit.h>
#import "AFNetworking.h"
#import "Masonry.h"
//#import "ISSoundAdditions.h"//音量管理

#import "ZBDataObject.h"
#import "ZBMacOSObject.h"
#import "ZBMusicStatusControllerObject.h"
#import "ZBAudioModel.h"
#import "ZBAudioObject.h"
#import "ZBThemeObject.h"

#import "ZBPlayerSection.h"
#import "ZBPlayerRow.h"
#import "ZBPlayerSplitView.h"
#import "ZBScrollOutlineView.h"
#import "ZBScrollTableView.h"
#import "ZBScrollTextView.h"
#import "ZBTableRowView.h"
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
@interface ZBPlayer ()<NSSplitViewDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource,AVAudioPlayerDelegate,ZBPlayerSectionDelegate,ZBPlayerRowDelegate,NSTableViewDelegate,NSTableViewDataSource,NSFileManagerDelegate>
{
    
}
@property (nonatomic, strong) ZBMacOSObject *object;
@property (nonatomic, strong) ZBDataObject *dataObject;

/** 主题管理：颜色等*/
@property (nonatomic, strong) ZBThemeObject *themeObject;

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
@property (nonatomic, strong) NSButton *versionBtn;
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
@property (nonatomic, strong) NSView *splitRightView;
@property (nonatomic, strong) NSView *splitRightTopView;



#pragma mark - 数据
/** 本地路径音频数据，对localMusics进行加工包装，真正用于播放的数据 */
@property (nonatomic, strong) TreeNodeModel *treeModel;
/** 历史播放记录 */
//@property (nonatomic, strong) TreeNodeModel *historyPlayed;
/** 是否是使用VCL框架播放模式，0：AVAudioPlayer，1:vlcPlayer */
@property (nonatomic, assign) BOOL isVCLPlayMode;

/** 用于管理页面展示的版本*/
@property (nonatomic, copy) NSString *appVersionType;

#pragma mark - 播放器控制
/** 播发器 */
@property (nonatomic, strong) VLCMediaPlayer *vlcPlayer;
/** 播发器 */
@property (nonatomic, strong) AVAudioPlayer *avPlayer;
/** 播放状态控制器 */
@property (nonatomic, strong) ZBMusicStatusControllerObject *musicStatusCtrl;

///** 是否正在播放  */
@property (nonatomic, assign) BOOL isPlaying;


@property (nonatomic, assign) CFRunLoopTimerRef timerForRemainTime;
/** VLC 播放模式下，当前歌曲的播放进度 */
@property (nonatomic, assign) int vlcCurrentTime;
@property (nonatomic, strong) NSNotification *mainNoti;




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

    
    //是否不透明
    [self setOpaque:NO];
    //设置titlebar透明，实现titlebar的隐藏或显示效果
    self.titlebarAppearsTransparent = YES;
    //2、titlebar中的标题是否显示
    //self.titleVisibility = NSWindowTitleHidden;
    
    //3、设置窗口标题
    self.title = @"本地音乐播放器";
    
    //如果设置minSize后拉动窗口有明显的大小变化，需要在MainWCtrl.xib中勾选Mininum content size
    self.minSize = NSMakeSize(900, 556);//标准尺寸
    
    
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
    
    //初始化数据源
    [self initData];
    
    
    //注：似乎没法使用懒加载，只能手动调用了
    [self playerSplitView];
    [self controllBar];
    [self addSubviewsIntoSplitView];
    [self.audioListScrollOutlineView.outlineView reloadData];

    
    [self mainTheme];
    [self addNotification];//添加通知//无用

    
}
#pragma mark - 数据源
-(void)initData{
    self.themeObject = [[ZBThemeObject alloc]init];
    [self.themeObject colorModelWithType:0];
    
    self.object = [[ZBMacOSObject alloc]init];
    self.dataObject = [[ZBDataObject alloc]init];
    self.musicStatusCtrl = [[ZBMusicStatusControllerObject alloc]init];
   
    self.isVCLPlayMode = YES;
    
    //获取app的界面版本
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.appVersionType = [user stringForKey:kDefaultAppViewVersionKey];
    if(!self.appVersionType || [self.appVersionType isEqualToString:@""]){
        [user setValue:@"2" forKey:kDefaultAppViewVersionKey];
    }
    
    self.tableViewDatas = [NSMutableArray array];
//    NSMutableArray *arr1 =[NSMutableArray arrayWithArray:@[]];
//    NSMutableArray *arr2 =[NSMutableArray arrayWithArray:@[]];
//    for(int i = 0; i < 10000 ; i++){
//        NSString *str1 = [NSString stringWithFormat:@"A %d",i];
//        NSString *str2 = [NSString stringWithFormat:@"B %d",i];
//        [arr1 addObject:str1];
//        [arr2 addObject:str2];
//    }
//    [self.tableViewDatas addObjectsFromArray:@[arr1,arr2]];
//    [self.audioListScrollTableView.tableView reloadData];

    
    
    self.musicStatusCtrl.currentRow = 0;
    //从历史记录中读取播放列表
    NSMutableArray *musicList = [ZBAudioObject getMusicList];
    if (musicList.count > 0) {
        self.treeModel = [[TreeNodeModel alloc]init];
        self.treeModel.childNodes = [NSMutableArray arrayWithArray:musicList];
//        [self.audioListScrollOutlineView.outlineView reloadData];
    }else{
        self.treeModel = [[TreeNodeModel alloc]init];
        //根节点
        TreeNodeModel *rootNode1 = [ZBAudioObject node:@"默认列表" level:0 superLevel:-1];
        TreeNodeModel *history   = [ZBAudioObject node:@"播放历史" level:0 superLevel:-1];
        [self.treeModel.childNodes addObjectsFromArray:@[rootNode1,history]];
    }
    
}

/// 主题设置
-(void)mainTheme{

    //窗口背景颜色
//    NSColor *windowBackgroundColor = [NSColor colorWithCalibratedWhite:0 alpha:0.3];// [NSColor colorWithRed:0 green:0 blue:0 alpha:0.2];//[NSColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1.0];
//    [self setBackgroundColor: windowBackgroundColor];
    
    //窗口标题栏透明
    self.titlebarAppearsTransparent = YES;
    
    [self setBackgroundColor: self.themeObject.mainWindowColor];
    //是否不透明
    [self setOpaque:NO];
    
    self.playerSplitView.layer.backgroundColor = self.themeObject.splitViewColor.CGColor; //[NSColor blueColor].CGColor;
    self.audioListScrollOutlineView.backgroundColor = self.themeObject.scrollViewColor;
    self.audioListScrollOutlineView.outlineView.backgroundColor = self.themeObject.outlineViewColor;
    self.audioListScrollTableView.backgroundColor = self.themeObject.scrollViewColor;
    self.audioListScrollTableView.tableView.backgroundColor = self.themeObject.tableViewColor;
    self.audioListScrollOutlineView.wantsLayer = YES;
    self.audioListScrollOutlineView.layer.backgroundColor = [[NSColor clearColor] colorWithAlphaComponent:0].CGColor;
    self.splitRightView.layer.backgroundColor = self.themeObject.splitViewColor.CGColor;
    self.splitRightTopView.layer.backgroundColor = self.themeObject.splitRightTopViewColor.CGColor;
    
//
//    self.audioListScrollTableView.alphaValue = self.themeObject.scrollViewAlphaValue;
//    self.audioListScrollTableView.tableView.alphaValue = self.themeObject.tableViewAlphaValue;
//    self.audioListScrollOutlineView.alphaValue  = self.themeObject.scrollViewAlphaValue;
//    self.audioListScrollOutlineView.outlineView.alphaValue = self.themeObject.outlineViewAlphaValue;
//    self.splitRightView.alphaValue = self.themeObject.scrollViewAlphaValue;
//    self.splitRightTopView.alphaValue = self.themeObject.splitRightTopViewAlphaValue;
    
    self.lastBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.playBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.nextBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.volumeBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.playbackModelBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.searchHistoryBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.searchBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.bgColorBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.versionBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.listActionBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.playActionBtn.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    
    self.searchScrollTextView.textView.layer.backgroundColor = self.themeObject.btnColor.CGColor;
    self.searchScrollTextView.textView.drawsBackground = NO;
    self.progressSlider.trackFillColor = self.themeObject.btnColor;
    
    
    for (id view in self.audioListScrollOutlineView.outlineView.subviews) {
        if([view isKindOfClass:[ZBPlayerSection class]]){
            ZBPlayerSection *sec = (ZBPlayerSection *)view;
            sec.layer.backgroundColor = self.themeObject.outlineSectionColor.CGColor;
        //    self.backgroundColor = color;
        }else if([view isKindOfClass:[ZBPlayerRow class]]){
            ZBPlayerRow *ro = (ZBPlayerRow *)view;
            ro.layer.backgroundColor = self.themeObject.outlineRowColor.CGColor;
        }
    }
    
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
    
    self.progressSlider = [self.object slider:NSSliderTypeLinear frame:NSZeroRect superView:self.contentView target:self action:@selector(progressAction:)];
    self.progressSlider.layer.backgroundColor = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.1].CGColor;
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
    btn.toolTip = [NSString stringWithFormat:@"单击右键，查看【%@】的更多功能",title];
    NSFont *font = [NSFont boldSystemFontOfSize:13];
    btn.font = font;
    
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
    }else if(sender.tag == 21){
        //版本切换
        
        
    }else if(sender.tag == 22){
        //搜索
        
    }else if(sender.tag == 23){
        //背景颜色
//        NSColorPicker
        NSColorPanel *colorPanel = [NSColorPanel sharedColorPanel];
        [NSColorPanel setPickerMask:NSColorPanelRGBModeMask];
        [NSColorPanel setPickerMode:NSColorPanelModeCrayon];
        [colorPanel setAction:@selector(colorAction:)];
        [colorPanel setTarget:self];
        [colorPanel orderFront:nil];
        
        
        
    }else if(sender.tag == 24){
        //列表操作
        //收起所已展开的列表
        [self.audioListScrollOutlineView.outlineView collapseItem:nil];
    }else if(sender.tag == 25){
        //播放管理
        
        
    }else if(sender.tag == 26){
       
    }
}


-(void)colorAction:(id)sender{
    NSLog(@"COLOR:%@",sender);
    NSColorPanel *colorpanel = sender;
    NSColor *color = colorpanel.color;
    [self.themeObject changeColor:color];
    [self mainTheme];
    [self.audioListScrollOutlineView.outlineView reloadData];
    [self.audioListScrollTableView.tableView reloadData];
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

#pragma mark - menu

-(NSMenu *)addMenu:(NSArray *)itemTitles{
    //列表操作
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    for (int i = 0; i < itemTitles.count; i++) {
        NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:itemTitles[i] action:@selector(menuItemAction:) keyEquivalent:@""];//keyEquivalent 快捷键
        item.target = self;//右键
        [menu insertItem:item atIndex:i];
    }
    //自定义的NSMenuItem
    //    NSView *vie = [[NSView alloc]initWithFrame:NSMakeRect(10, 10, 100, 80)];
    //    vie.wantsLayer = YES;
    //    vie.layer.backgroundColor = [NSColor redColor].CGColor;
    //    NSMenuItem *item3 = [[NSMenuItem alloc]init];
    //    item3.title = @"Item 3";
    //    item3.view = vie;
    //    item3.target = self;
    //    item3.action = @selector(beep:);
    //    [theMenu insertItem:item3 atIndex:2];
    //        NSEvent *ev = [NSEvent event];
    //        ev.type = NSEventTypeMouseEntered;
    //        [NSMenu popUpContextMenu:theMenu withEvent:ev forView:sender];
    //    [self.listActionBtn setMenu:menu];
    return menu;
}

-(void)menuItemAction:(NSMenuItem *)menuItem{
    
    if ([menuItem.title isEqualToString:kMenuItemImportFolderList]) {//导入歌曲文件夹
        [self openPanel];
    }else if ([menuItem.title isEqualToString:kMenuItemSectionInsert]) {//新增文件夹列表
        
    }else if ([menuItem.title isEqualToString:kMenuItemSectionUpdate]) {//更新本组（无）
        //        NSLog(@"当前组：%ld",playerRow.model.sectionIndex);
    }else if ([menuItem.title isEqualToString:kMenuItemSectionRemove]) {//移除本组（无）
        
    }else if ([menuItem.title isEqualToString:kMenuItemSectionCollapseAll])  {//收起所已展开的列表
        [self.audioListScrollOutlineView.outlineView collapseItem:nil];
    }else if ([menuItem.title isEqualToString:kMenuItemSectionSelectAll])  {//@"选中所有列表（所有列表的歌曲都可以播放）"
        
    }else if ([menuItem.title isEqualToString:kMenuItemSectionSelectUser])  {// @"自定义（只有被选中列表的歌曲才可以播放）"
        
    }
    else if ([menuItem.title isEqualToString:kMenuItemLocatePlaying]) {//当前播放
        [self reloadSectionStaus];
    }else if ([menuItem.title isEqualToString:kMenuItemShowInFinder]) {//定位文件
        TreeNodeModel *model = (TreeNodeModel *)[self.treeModel.childNodes[self.musicStatusCtrl.currentSection] childNodes][self.musicStatusCtrl.currentRow];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:model.audio.path]]];
    }else if ([menuItem.title isEqualToString:kMenuItemDeleteFileInFolder]) {//从本地删除歌曲
        
    }else if ([menuItem.title isEqualToString:kMenuItemPlayHistory])  {//播放历史
        
    }
    else if ([menuItem.title isEqualToString:kMenuItemSearchInCurrenSection])  {//从本列表中搜索"
        
    }else if ([menuItem.title isEqualToString:kMenuItemSearchInAllSection])  {//从所有表中搜索"
        
    }else if ([menuItem.title isEqualToString:kMenuItemSearchHistory]) {//查看搜索历史"
        
    }else if ([menuItem.title isEqualToString:kMenuItemSearchHistoryClear])  {//清除搜索历史
        
    }
    else if ([menuItem.title isEqualToString:kMenuItemAppVersion1])  {//切换 版本：1
        self.appVersionType = @"1";
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setValue:@"1" forKey:kDefaultAPPViewVersion];
        
        [self.audioListScrollOutlineView.outlineView reloadData];
        [self.tableViewDatas removeAllObjects];
        [self.audioListScrollTableView.tableView reloadData];
    }else if ([menuItem.title isEqualToString:kMenuItemAppVersion2])   {//切换 版本：2
        self.appVersionType = @"2";
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setValue:@"2" forKey:kDefaultAPPViewVersion];
        [self.audioListScrollOutlineView.outlineView reloadData];
        [self.tableViewDatas removeAllObjects];
        [self.tableViewDatas addObjectsFromArray:[self.treeModel.childNodes[0] childNodes]];
        [self.audioListScrollTableView.tableView reloadData];
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
            make.left.equalTo(self.contentView.mas_left).offset(5);
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


#pragma mark  --- 给分屏控件组件添加 大纲目录列表视图 NSOutlineView
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
    self.splitRightView = [[NSView alloc]initWithFrame:NSMakeRect(0, 80, tempWidth, tempHeight)];
    self.splitRightView.wantsLayer = YES;
    self.splitRightView.layer.backgroundColor = self.themeObject.splitViewColor.CGColor;//[NSColor yellowColor].CGColor;
    [self.playerSplitView addSubview:self.splitRightView];
    
//
//    NSVisualEffectView *visualEffectView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, tempWidth, tempHeight)];
//    [visualEffectView setMaterial:NSVisualEffectMaterialDark];
//    [visualEffectView setMaskImage:[NSImage imageNamed:@"339_1024.jpg"]];
//    [visualEffectView setBlendingMode:NSVisualEffectBlendingModeWithinWindow];
//    [visualEffectView setState:NSVisualEffectStateActive];
//
//    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(300, 0, 100, 30)];
//    [textField setStringValue:@"Hello, World!"];
//
//    [visualEffectView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
////    [visualEffectView setAllowsVibrancy:YES];
//    [visualEffectView setWantsLayer:YES];
//    [visualEffectView setLayer:[[CALayer alloc] init]];
//
////    [splitRightTopView addSubview:[visualEffectView contentView]];
//    [splitRightView addSubview:textField];
//    [splitRightView addSubview:visualEffectView];
////    [visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.top.equalTo(splitRightView.mas_top).offset(10);
////        make.bottom.equalTo(splitRightView.mas_bottom).offset(-5);
////        make.left.equalTo(splitRightView.mas_left).offset(10);
////        make.width.equalTo(splitRightView.mas_width).offset(-20);
////        //        make.height.mas_equalTo(tempHeight/3);
////
////    }];
    
    
    CGFloat btnwidth = 65;
    CGFloat btnheight = 32;
    CGFloat topOff = 5;
    CGFloat splitRightTopViewHeight = btnheight * 2 + topOff * 3 + 15;
    
    self.audioListScrollTableView = [[ZBScrollTableView alloc]initWithColumnIdentifiers:@[@"column_table_ID0"] className:@""];
    self.audioListScrollTableView.tableView.delegate = self;
    self.audioListScrollTableView.tableView.dataSource = self;
    [self.splitRightView addSubview:self.audioListScrollTableView];
    [self.audioListScrollTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splitRightView.mas_top).offset(splitRightTopViewHeight);
        make.bottom.equalTo(self.splitRightView).offset(0);
        make.left.equalTo(self.splitRightView.mas_left).offset(10);
        make.width.equalTo(self.splitRightView.mas_width).offset(-20);
        //        make.height.mas_equalTo(tempHeight-100);
    }];
//    self.audioListScrollTableView.tableView.headerView.wantsLayer =YES;
//    self.audioListScrollTableView.tableView.headerView.layer.backgroundColor = [NSColor clearColor].CGColor;




    
    self.splitRightTopView = [[NSView alloc]initWithFrame:NSMakeRect(0, 80, tempWidth, tempHeight)];
    self.splitRightTopView.wantsLayer = YES;
    self.splitRightTopView.layer.backgroundColor =self.themeObject.splitRightTopViewColor.CGColor;// [NSColor greenColor].CGColor;
    [self.splitRightView addSubview:self.splitRightTopView];
    [self.splitRightTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splitRightView.mas_top).offset(10);
        make.bottom.equalTo(self.audioListScrollTableView.mas_top).offset(-5);
        make.left.equalTo(self.splitRightView.mas_left).offset(10);
        make.width.equalTo(self.splitRightView.mas_width).offset(-20);
        //        make.height.mas_equalTo(tempHeight/3);
        
    }];
 
    
    
    /** 版本切换按钮 */
    self.versionBtn = [self buttonTitle:@"版本切换" tag:21 superView:self.splitRightTopView];
    [self.versionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splitRightTopView.mas_top).offset(topOff);
        make.left.equalTo(self.splitRightTopView.mas_left).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);
    }];
    NSMenu *versionMenu = [self addMenu:@[kMenuItemAppVersion1,kMenuItemAppVersion2]];
    [self.versionBtn setMenu:versionMenu];
  
    
    
    self.searchScrollTextView = [[ZBScrollTextView alloc]initWithScrollTextView];
    [self.splitRightTopView addSubview:self.searchScrollTextView];
    [self.searchScrollTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splitRightTopView.mas_top).offset(topOff);
        make.left.equalTo(self.versionBtn.mas_right).offset(10);
        make.width.mas_equalTo(230);
        make.height.mas_equalTo(btnheight);
        
    }];
    
    /** 搜索按钮 */
    self.searchBtn = [self buttonTitle:@"搜索" tag:22 superView:self.splitRightTopView];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splitRightTopView.mas_top).offset(topOff);
        make.left.equalTo(self.searchScrollTextView.mas_right).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);
    }];
    NSMenu *searchMenu = [self addMenu:@[kMenuItemSearchInCurrenSection,kMenuItemSearchInAllSection,kMenuItemSearchHistory,kMenuItemSearchHistoryClear]];
    [self.searchBtn setMenu:searchMenu];
    
    
    /** 更换背景颜色按钮 */
    self.bgColorBtn = [self buttonTitle:@"背景颜色" tag:23 superView:self.splitRightTopView];
    [self.bgColorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splitRightTopView.mas_top).offset(topOff);
        make.left.equalTo(self.searchBtn.mas_right).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);
        
    }];
    
    
    /** 列表操作按钮 */
    self.listActionBtn = [self buttonTitle:@"列表管理" tag:24 superView:self.splitRightTopView];
    [self.listActionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.versionBtn.mas_bottom).offset(5);
        make.left.equalTo(self.splitRightTopView.mas_left).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);
    }];
    NSMenu *listMenu = [self addMenu:@[kMenuItemImportFolderList,kMenuItemSectionInsert,kMenuItemSectionUpdate,kMenuItemSectionRemove,kMenuItemSectionSelectAll,kMenuItemSectionSelectUser,kMenuItemSectionCollapseAll]];
    [self.listActionBtn setMenu:listMenu];
   
    

    /** 播放管理按钮*/
    self.playActionBtn = [self buttonTitle:@"播放管理" tag:25 superView:self.splitRightTopView];
    [self.playActionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.listActionBtn.mas_top);
        make.left.equalTo(self.versionBtn.mas_right).offset(10);
        make.width.mas_equalTo(btnwidth);
        make.height.mas_equalTo(btnheight);
    }];
    NSMenu *playMenu = [self addMenu:@[kMenuItemLocatePlaying,kMenuItemShowInFinder,kMenuItemDeleteFileInFolder,kMenuItemPlayHistory]];
    [self.playActionBtn setMenu:playMenu];
  
    

//    self.playActionBtn = [self buttonTitle:@"" tag:26 superView:splitRightTopView];
//    [self.playActionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.listActionBtn.mas_top);
//        make.left.equalTo(self.listActionBtn.mas_right).offset(10);
//        make.width.mas_equalTo(btnwidth);
//        make.height.mas_equalTo(btnheight);
//    }];
//    NSMenu *historyMenu = [self addMenu:@[kMenuItemSearchHistory,kMenuItemPlayHistory]];
//    [self.searchHistoryBtn setMenu:historyMenu];
    

    NSSplitViewController *spc = [[NSSplitViewController alloc]init];
    
    
}




#pragma mark --- NSSplitViewDelegate 分屏组件代理
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

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDivider:(NSInteger)dividerIndex {
    return YES;
}

#pragma mark - NSOutlineView 歌曲大纲列表、目录结构组件


//3.实现数据源协议
#pragma mark --- DataSource 大纲目录、列表结构数据源
//设置节点以及子节点的列表数量
-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    //当item为空时表示根节点.
    if([self.appVersionType isEqualToString:@"1"]){
        if(!item){
            return [self.treeModel.childNodes count];
        } else{
            TreeNodeModel *nodeModel = item;
            return [nodeModel.childNodes count];
        }
        
    }else {
        if(!item){
            return [self.treeModel.childNodes count];
        } else{
            if([item isKindOfClass:[TreeNodeModel class]]){
                TreeNodeModel *nodeModel = item;
                return [nodeModel.artists count];
            }else{
                return 0;
            }
            
        }
    }
    
}


//绑定数据
-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{

    if([self.appVersionType isEqualToString:@"1"]){
        if(!item){
            return self.treeModel.childNodes[index];
        }else{
            TreeNodeModel *nodeModel = item;
            return nodeModel.childNodes[index];
        }
        
    }else {
        if(!item){//没有数据，表示为根节点，需要赋值
            return self.treeModel.childNodes[index];
        } else{
            //item为根节点，找到根节点的数据，给子节点创建row
            TreeNodeModel *nodeModel = item;
            return nodeModel.artists[index];
            
            
        }
    }
}

#pragma mark --- 数据 判断节点是否可以展开

//根据数据源判断该节点是否有子集节点数据，如果有，允许展开，如果没有，不允许展开
-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(nonnull id)item{
    //count 大于0表示有子节点,需要允许Expandable
    
    return [self checkItem:item];
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
    if([self.appVersionType isEqualToString:@"1"]){
        if(!item){
            return [self.treeModel.childNodes count] > 0 ? YES : NO;
        } else {
            return model.childNodes.count > 0 ? YES : NO;
        }
        
    }else {
        if(model.nodeLevel == 0){
            return [self.treeModel.childNodes count] > 0 ? YES : NO;
        }else{
            return NO;//[self.treeModel.artists count] > 0 ? YES : NO;
        }
       
    }
}



#pragma mark --- 方法 数据节点的【折叠】与【展开】的相关方法
/**
 此处4个方法，用于管理outlineView 展开与折叠 发生的四种生命周期活动。用户无需手动管理，完成之后的业务需求即可。
 如果还在此处手动管理，有可能会发生重复调用执行不断地开、关工作。
 
 */

- (void)outlineViewItemWillExpand:(NSNotification *)notification{
    NSLog(@"outlineViewItemWillExpand_即将展开节点前_%@",notification);
    
}
- (void)outlineViewItemDidExpand:(NSNotification *)notification{
    NSLog(@"outlineViewItemDidExpand_完成展开节点_%@",notification);
    //记录展开的列表，意味着可能会使用这个列表的数据
    [self outlineViewNotification:notification];

    
}
- (void)outlineViewItemWillCollapse:(NSNotification *)notification{
   
    NSLog(@"outlineViewItemWillCollapse_即将收拢节点_%@",notification);
    
    
}
- (void)outlineViewItemDidCollapse:(NSNotification *)notification{
    NSLog(@"outlineViewItemDidCollapse_完成收拢节点_%@",notification);
    [self outlineViewNotification:notification];
}

-(void)outlineViewNotification:(NSNotification *)notification{

    if([self.appVersionType isEqualToString:@"2"]){
        id obj = notification.userInfo[@"NSObject"];


        ZBAudioOutlineView  *outlineView =(ZBAudioOutlineView *)notification.object;
        if([obj isKindOfClass:[TreeNodeModel class]]){
            TreeNodeModel *model = (TreeNodeModel *)obj;
            NSInteger index = model.nodeLevel == 0 ? model.rowIndex : model.sectionIndex;

//            self.musicStatusCtrl.tempSection = index;
//            [self reloadOutlineView:outlineView model:model index:index];
//            [self relodSectionImageStatus];
            NSLog(@"当前节点_%ld,%d,%d,%d,%d,%d,%@",model.nodeLevel,model.rowIndex,model.sectionIndex,[model.childNodes count],self.musicStatusCtrl.currentSection,self.musicStatusCtrl.currentRow,model);
        }
    }
}



#pragma mark --- Delegate 大纲、目录结构视图代理
//根据数据item 创建TableRowView、展示数据
-(NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item{
    
//    if([self.appVersionType isEqualToString:@"1"]){
        TreeNodeModel *nodeModel = item;
        if (nodeModel.nodeLevel == 0) {
            //        idet = NSOutlineViewDisclosureButtonKey;
            NSString *idet = [NSString stringWithFormat:@"superNode_%ld",nodeModel.nodeLevel];
            ZBPlayerSection *rowView = [outlineView makeViewWithIdentifier:idet owner:self];
            
            if (rowView == nil) {
                rowView = [[ZBPlayerSection alloc]initWithLevel:nodeModel.nodeLevel];
                rowView.identifier = idet;
            }
            rowView.delegate = self;
            rowView.model = nodeModel;
            return rowView;
        }else{
            
            //使用分级来做标识符更节省内存
            NSString *idet = [NSString stringWithFormat:@"childNode_%ld",nodeModel.nodeLevel];
            ZBPlayerRow *rowView = [outlineView makeViewWithIdentifier:idet owner:self];
            
            if (rowView == nil) {
                rowView = [[ZBPlayerRow alloc]initWithLevel:nodeModel.nodeLevel];
                rowView.identifier = idet;
            }
            rowView.model = nodeModel;
            rowView.delegate = self;
            return rowView;
  
        }

}



//4.实现代理方法,绑定数据到节点视图
//列表滚动时,出现新的column时，会执行这个代理，重载数据
-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    
//    if([self.appVersionType isEqualToString:@"1"]){
        TreeNodeModel *model = item;
        //根据标识符取column上的子view
        NSView *result  =  [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
        //可以通过这个代理填充数据，也可以通过NSTableRowView（可以自定义）中的drawRect:方法赋值。注：此处需要注意子控件的类型
        NSArray *subviews = [result subviews];
        //NSImageView *imageView = subviews[0];
        NSTextField *field = subviews[1];
        field.stringValue = model.name;
        [field setDoubleValue:NO];
        [field setBezelStyle:NSTextFieldRoundedBezel];
        
        return result;
//    }else {
//
//    }
    
    
}




-(CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    if([self.appVersionType isEqualToString:@"1"]){
        TreeNodeModel *model = item;
        if(model.nodeLevel == 0){
            return ZBPlayerSectionHeight;
        }else{
            return ZBPlayerRowHeight;
        }
        
    }else{
        return ZBPlayerRowHeight;
    }
    
}

#pragma mark ---【tableColumn】的相关方法

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


#pragma mark --- 点击tableColumn中的【row】 触发的事件响应过 及其方法
/**
 在点击tableColumn的时候执行，判断是否允许outlineview执行改变操作（比如点击之后的响应方法是否允许执行）
 YES：默认值，此时，点击tableColumn时，可以执行操作，比如点击此行之后，播放选中的歌曲
 NO：此时，点击tableColumn时，不会执行操作，比如点击此行之后，不会有动作响应
 
 使用方法，可以用来拦截用户手动断上一个方法，比如正在播放一首歌曲，当用户选中下一首歌，准备播放，此时NO就不允许用户切换，需要等歌曲完成播放，将值改为YES，用户才会被允许点击其他行播放下一首歌
 也可以用于区别其他outlineView，有的允许操作，有的不允许操作
 
 selectionShouldChangeInOutlineView: 方法会优先于outlineViewSelectionIsChanging：之前执行，先判断是否允许选中，如果不允许，就不会发生选择改变。
 
 */
- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)outlineView{
    //    NSLog(@"outlineView 点击row 触发了 selectionShouldChangeInOutlineView");
    return YES;
}

- (void)outlineViewSelectionIsChanging:(NSNotification *)notification{
    //    NSLog(@"outlineView 点击row 触发了 outlineViewSelectionIsChanging_选中其他行数据_%@",notification);
}

//“5.节点选择的变化事件通知
//实现代理方法 outlineViewSelectionDidChange获取到选择节点后的通知（注：点击节点的三角指使标不会走这个方法，点击数据行才会执行）
-(void)outlineViewSelectionDidChange:(NSNotification *)notification{
    //    NSLog(@"outlineView 点击row 触发了 outlineViewSelectionDidChange：%@",notification);
    ZBAudioOutlineView *treeView = notification.object;
    
    /*
     注意1：
     用于表示当前选中的row 在整个【outlineView】中的index，而不是在当前section的index
     当前所有已展开的row的顺数index(包含前方所有未展开的section的数量+当前的section+当前row所在section中的index)
     可以是section,可以是row
     
     注意2：
     点击左侧大纲列表的根节点折叠和展开控件的时候，[treeView selectedRow]没有值，因为点击的不是row或者section，所以拿不到index，导致[treeView childIndexForItem:model]也没有index,数组越界
     */
    NSInteger selectedRowAtOulineViewAllIndex = [treeView selectedRow];
    //由于selectedRowAtOulineViewAllIndex所代表的含义，所以获取的可能是根节点的数据，也可能获取的是子节点某一个row的数据，数据类型可能不一样
    TreeNodeModel *model = (TreeNodeModel*)[treeView itemAtRow:selectedRowAtOulineViewAllIndex];
    
    
    //根据位置index，获取当前item的层级序号，由于selectedRowAtOulineViewAllIndex所代表的含义，所以level可以代表根节点、也可能是次级节点，也可能是其他更下级的节点
    NSInteger levelForRow  = [treeView levelForRow:selectedRowAtOulineViewAllIndex];
    //根据数据item，获取当前item的层级序号。作用与levelForRow相同。
    NSInteger levelForItem = [treeView levelForItem:model];
    
    //比较灵活的index，点击根层级节点时，代表的是其在根层级节点的index，也就是sectionIndex；但是，当点击的是当前节点中的列表时，显示的是当前节点列表中的index，也就是rowIndex
    NSInteger childIndexForItem = [treeView childIndexForItem:model];
    NSLog(@"点击了outlineView row=%ld，name=%@，levelForRow=%ld，levelForItem=%ld，childIndexForItem=%ld",selectedRowAtOulineViewAllIndex,model.name,levelForRow,levelForItem,childIndexForItem);
    
    //统计当前选中的item(列表节点下方有多少个子项，不管展开与否，都可以统计)
    NSInteger levelForItemdd = [treeView numberOfChildrenOfItem:model];
    //根据childIndex获取当前item下，指定childIndex对应的数据（不用去查找数据源）
    //    id  chi = [treeView child:childIndexForItem ofItem:model];//在新数据刷新展示到页面之前执行，导致数组越界
    
    //    NSIndexSet *indexset = [treeView selectedRowIndexes];
    //    NSInteger inlevel = treeView.indentationPerLevel;
    //    NSIndexSet *hidenrowIndexSets = [treeView hiddenRowIndexes];
    
    
    if([self.appVersionType isEqualToString:@"1"]){
      
        //控制根节点的展开、折叠收起
        if(levelForRow == 0){
            
            //系统方法（在此处不用手动实现，只要实现outlineView对应的代理就可以了）
            //        if([treeView isItemExpanded:model] == YES){
            //            [treeView collapseItem:model  collapseChildren:NO];//“collapseChildren 参数表示是否收起所有的子节点。”
            //        }else{
            //            [treeView expandItem:model expandChildren:NO];//“expandChildren 参数表示是否展开所有的子节点。”
            //        }
            //
            //手动管理outlineView的展开与折叠（不建议这么做，控件自带的代理已经实现逻辑）
            [self reloadOutlineView2:treeView model:nil index:childIndexForItem];////减去手动加入的、并未存储在数据库中的数据表，如“播放历史”等
            

            
        }else if (levelForRow == 1) {
            
            //次级节点，点击row，确定数据逻辑
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
                    NSLog(@"点击的row 所在的的section：%ld，row：%ld ",model.sectionIndex,childIndexForItem);
                }else{
                    NSLog(@"点击row,正在播放：%@",model.name);
                }
        }
    }else{
   
        
        if(model.nodeLevel == 0){
            //点击列表，只切换右侧列表  不播放
            if(model){
                NSArray *arr = [self.treeModel.childNodes[childIndexForItem] childNodes];
                [self.tableViewDatas removeAllObjects];
                [self.tableViewDatas addObjectsFromArray:arr];
                [self.audioListScrollTableView.tableView reloadData];
                
                [self reloadOutlineView2:treeView model:nil index:childIndexForItem];////减去手动加入的、并未存储在数据库中的数据表，如“播放历史”等
            }else{
                //点击左侧大纲列表的根节点折叠和展开控件的时候，[treeView selectedRow]没有值，因为点击的不是row或者section，所以拿不到index，导致[treeView childIndexForItem:model]也没有index,数组越界
                NSLog(@"越界了啊啊啊——%ld,%ld",[self.treeModel.childNodes count],childIndexForItem);

            }
  
        }else{
            //记录上一次播放的位置
            self.musicStatusCtrl.lastSection = self.musicStatusCtrl.currentSection;//更换列表
            //            self.musicStatusCtrl.lastRow     = self.musicStatusCtrl.currentRow;
            
            //更新播放位置
            //            self.musicStatusCtrl.currentSection = childIndexForItem;
            //            self.musicStatusCtrl.currentRow = childIndexForItem;
            //            self.isPlaying = YES;
            
            self.searchScrollTextView.textView.string = model.name;
            //记录歌手所在的列表，但是不一定会开始播放，如果用户点击有些tableview，就可以联合rowindex，获取正确的歌曲了，在播放的时候，在同步修改到currentSection
            self.musicStatusCtrl.artistSection = model.sectionIndex;
            NSLog(@"点击了 歌手section：%ld，childIndexForItem:%ld，层级：%ld",self.musicStatusCtrl.artistSection,childIndexForItem,levelForRow);
    
            //~~~~~点击左侧歌手名字。读取并在右侧tableview中显示其所在列表， 定向滚动到当前 歌手 在歌曲列表所在的位置。匹配歌手的位置
            //注意，当这个歌手的名字出现在别的歌手的歌曲名字里面的时候，点击歌手名字，而显示在右边列表的时候，可能显示的就是那位歌手的那首歌，由此导致错误。比如：想要查找周杰伦的歌，但是可能会停止在 二珂 - 告白气球（原唱：周杰伦）.mp3
            NSInteger foundIndex = NSNotFound;
            NSArray *tabledatas = [self.treeModel.childNodes[model.sectionIndex] childNodes];
            for(int i = 0 ; i < tabledatas.count; i++){
                TreeNodeModel *tempModel = tabledatas[i];
                if ([tempModel.name rangeOfString:model.name].location != NSNotFound) {
                    //解决歌名中存在歌手的名字，但是不是以改歌手名字为开头的（是其他歌手的歌）：比如歌曲：本兮、徐良
                    if([tempModel.name hasPrefix:model.name]){
                        foundIndex = i;
                        break;
                    }
                }
            }

            [self.tableViewDatas removeAllObjects];
            [self.tableViewDatas addObjectsFromArray:tabledatas];
            [self.audioListScrollTableView.tableView reloadData];
            //页面滚动到当前row，根据row+section的数目总和确定位置，每+1代表多一行
            [self.audioListScrollTableView.tableView scrollRowToVisible:foundIndex];
            NSLog(@"寻找歌手在列表中出现的第一个位置_%ld，总数据_%ld",foundIndex,tabledatas.count);
            
            NSTableColumn *col = [self.audioListScrollTableView.tableView tableColumns][0];
            col.title = [NSString stringWithFormat:@"当前列表；%@",[self.treeModel.childNodes[self.musicStatusCtrl.artistSection] name]];
            
        }
        
    }
    
    
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
    [self menuItemAction:menuItem];
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
    //点击section时、更新列表时调用 要统一这两个的规则 确定section、index问题
    TreeNodeModel *myModel = playerSection.model;
    [self reloadOutlineView:(ZBAudioOutlineView *)self.audioListScrollOutlineView.outlineView model:myModel index:myModel.rowIndex];
    [self relodSectionImageStatus];
}

#pragma mark - 更新outlineView的折叠状态
//手动点击列表时，切换状态使用
-(void)reloadOutlineView:(ZBAudioOutlineView *)outlineView model:(TreeNodeModel *)currentModel index:(NSInteger)index{
    NSInteger iii = [self.appVersionType isEqualToString:@"1"] == YES ? 1 : 0;
    for (int i = 0; i < self.treeModel.childNodes.count - iii; i++) {//减去随机
        TreeNodeModel *mo = self.treeModel.childNodes[i];
        if(i == index){
            mo = currentModel;
            //如果是当前点击的，状态如果是展开，那就关闭，反之同理
            if(currentModel.isExpand == YES){
//                mo.isExpand = NO;
                [outlineView expandItem:currentModel expandChildren:NO];
            }else{
//                mo.isExpand = YES;
                [outlineView collapseItem:currentModel collapseChildren:NO];
            }
        }else{
            //关闭所有非当前点击，曾经已经打开的
            if(currentModel.isExpand == YES){
                mo.isExpand = NO;
                [outlineView collapseItem:mo collapseChildren:NO];
            }
        }
//        [self.treeModel.childNodes removeObjectAtIndex:i];
//        [self.treeModel.childNodes insertObject:mo atIndex:i];
        [self.treeModel.childNodes[i] setIsExpand:mo.isExpand];
    }
    
    
}
-(void)relodSectionImageStatus{
    for (id view in self.audioListScrollOutlineView.outlineView.subviews) {
        if([view isKindOfClass:[ZBPlayerSection class]]){
            ZBPlayerSection *sec = (ZBPlayerSection *)view;
            TreeNodeModel *mo = self.treeModel.childNodes[sec.model.rowIndex];
            sec.isImageExpand = mo.isExpand;
        }
    }
}
//自动切换，变更数据数据时刷新列表状态使用
-(void)reloadOutlineView2:(ZBAudioOutlineView *)outlineView model:(TreeNodeModel *)currentModel index:(NSInteger)index{

//    NSMutableArray *array = [NSMutableArray array];
//    if([self.appVersionType isEqualToString:@"1"]){
//        [array addObjectsFromArray:self.treeModel.childNodes];
//    }else{
//        [array addObjectsFromArray:self.treeModel.artists];
//    }
    
    NSInteger iii = [self.appVersionType isEqualToString:@"1"] == YES ? 1 : 0;
//    if([self.appVersionType isEqualToString:@"1"]){
        for (int i = 0; i < self.treeModel.childNodes.count - iii; i++) {//减去手动加入的、并未存储在数据库中的数据表，如“播放历史”等
            TreeNodeModel *mo = self.treeModel.childNodes[i];
            if(i == index){
                if(mo.isExpand == YES){
                    mo.isExpand = NO;
                    [outlineView collapseItem:mo collapseChildren:YES];//“collapseChildren 参数表示是否收起所有的子节点。”
                }else{
                    mo.isExpand = YES;
                    [outlineView expandItem:mo expandChildren:YES];//“expandChildren 参数表示是否展开所有的子节点。”
                }
            }else{
                mo.isExpand = NO;
                [outlineView collapseItem:mo collapseChildren:YES];
            }
            
            [self.treeModel.childNodes removeObjectAtIndex:i];
            [self.treeModel.childNodes insertObject:mo atIndex:i];
        }
//    }else{
//
//    }
    
 
    for (id view in outlineView.subviews) {
        if([view isKindOfClass:[ZBPlayerSection class]]){
            ZBPlayerSection *sec = (ZBPlayerSection *)view;
            NSLog(@"sec.index___%d,inde_%ld",sec.model.rowIndex,index);
            TreeNodeModel *mo = self.treeModel.childNodes[sec.model.rowIndex];
            sec.model.isExpand = mo.isExpand;
            if(sec.model.rowIndex == index){
                //NSLog(@"ZBPlayerSection_2_%ld,%ld",sec.model.rowIndex,childIndexForItem);
                [sec didSelected];//
            }
        }
    }
 
    
}




#pragma mark - 右侧，NSTableView的代理
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [self.tableViewDatas count];//由于每列的row数量是相等的，所以选0即可
    
    
}


-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([tableColumn.identifier isEqualToString:@"column_table_ID0"]){
        return [NSString stringWithFormat:@"%ld",row+1];//self.tableViewDatas[row];
    }else{
        return self.tableViewDatas[row];
    }
    
}

/***
 * 创建tableview时执行，滚动列表时不会再执行(似乎屏蔽代码不执行也没问题)
 * 页面中没有tableView，也没有需要实现的tableView的代理
 */
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    NSString *idet = [NSString stringWithFormat:@"childNode222_ss"];
    if ([self.appVersionType isEqualToString:@"1"]) {
        
        ZBPlayerRow *rowView = [tableView makeViewWithIdentifier:idet owner:self];
        TreeNodeModel *nodeModel = self.tableViewDatas[row];
        if (rowView == nil) {
            rowView = [[ZBPlayerRow alloc]initWithLevel:1];
            rowView.identifier = idet;
        }
        
        rowView.model = nodeModel;
        //    rowView.delegate = self;
        return rowView;
    }else{
        
        NSTableRowView *rowView = [tableView makeViewWithIdentifier:idet owner:self];
        //        [rowView setBackgroundColor:[NSColor whiteColor]];
        //
        //
        //        NSTextView *rowViewTF = [[NSTextView alloc]initWithFrame:NSMakeRect(0, 0, 300, 40)];
        //        [rowView addSubview:rowViewTF];
        //
        //        TreeNodeModel *nodeModel = self.tableViewDatas[row];
        //        if (rowView == nil) {
        //            rowView = [tableView makeViewWithIdentifier:idet owner:self];
        //            rowView.identifier = idet;
        //
        //
        //        }
        //        rowViewTF.string = nodeModel.name;
        //        rowViewTF.backgroundColor = [NSColor redColor];
        
        //    rowView.model = nodeModel;
        //    rowView.delegate = self;
        return rowView;
        
    }
    
}

-(NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    
    ZBTableRowView *rowView = [[ZBTableRowView alloc]initWithRow:row];
//    [rowView setBackgroundColor:[NSColor whiteColor]];
//    [rowView setBackgroundColor:self.themeObject.tableViewColor];
    NSString *idet = [NSString stringWithFormat:@"childNode222_ss"];
    
    TreeNodeModel *nodeModel = self.tableViewDatas[row];
    if (rowView == nil) {
        rowView = [tableView makeViewWithIdentifier:idet owner:self];
        rowView.identifier = idet;
    }
    
    rowView.model = nodeModel;
    
    return rowView;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return ZBPlayerRowHeight;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
    ZBScrollTableView *scTView = [[ZBScrollTableView alloc]init];
    scTView.tableView  = notification.object;
    
    /*
     用于表示当前选中的row 在整个【outlineView】中的index，而不是在当前section的index
     当前所有已展开的row的顺数index(包含前方所有未展开的section的数量+当前的section+当前row所在section中的index)
     */
    NSInteger selectedTableViewRowAllIndex = [scTView.tableView selectedRow];
    //由于selectedRowAtOulineViewAllIndex所代表的含义，所以获取的可能是根节点的数据，也可能获取的是子节点某一个row的数据，数据类型可能不一样
    //        TreeNodeModel *model = (TreeNodeModel*)[scTView.tableView itemAtRow:selectedRowAtOulineViewAllIndex];

    //        //统计当前选中的item(列表节点下方有多少个子项，不管展开与否，都可以统计)
    //        NSInteger levelForItemdd = [scTView.tableView numberOfChildrenOfItem:model];
    NSLog(@"触发了 tableViewSelectionDidChange：%ld,%@",selectedTableViewRowAllIndex,notification);
    
    //如果点击的是正在播放的，不要重瞳开始播放
    if(selectedTableViewRowAllIndex != self.musicStatusCtrl.currentRow){
        //记录上一次播放的位置
        //    self.musicStatusCtrl.lastSection = self.musicStatusCtrl.currentSection;//更换列表
        self.musicStatusCtrl.lastRow     = self.musicStatusCtrl.currentRow;
        
        //更新播放位置
        //    self.musicStatusCtrl.currentSection = selectedTableViewRowAllIndex;
        self.musicStatusCtrl.currentRow = selectedTableViewRowAllIndex;
        
        self.musicStatusCtrl.lastSection = self.musicStatusCtrl.currentSection;
        //先点击歌手列表中的歌手名字，然后点歌曲列表，此时就这样设置，但如果是其他情况呢？
        self.musicStatusCtrl.currentSection = self.musicStatusCtrl.artistSection;
        
        
        self.isPlaying = YES;
    }

    
}

#pragma mark - 面板：NSOpenPanel 读取电脑文件 获取文件名，路径
- (void)openPanel{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    openDlg.canChooseFiles = YES ;//----------“是否允许选择文件”
    openDlg.canChooseDirectories = YES;//-----“是否允许选择目录”
    openDlg.allowsMultipleSelection = YES;//--“是否允许多选”
    openDlg.allowedFileTypes = @[@"mp3",@"flac",@"wav",@"aac",@"m4a",@"wma",@"ape",@"ogg",@"alac"];//---“允许的文件名后缀”，此处是没什么作用？
    openDlg.treatsFilePackagesAsDirectories = YES;
    openDlg.canCreateDirectories = YES;//显示“新建文件夹”按钮
    openDlg.title = @"导入歌曲列表";
    openDlg.message = @"选择需要导入的歌曲文件夹，每个文件夹就是一张表，歌曲按目录表展示";
    
    //初始化数据源
    __weak ZBPlayer * weakSelf = self;
    self.treeModel = [[TreeNodeModel alloc]init];
    [openDlg beginWithCompletionHandler: ^(NSInteger result){
        if(result == NSModalResponseOK){
            NSArray *fileURLs = [openDlg URLs];//“保存用户选择的文件/文件夹路径path”
            NSLog(@"获取本地文件的路径：%@",fileURLs);
            
            if([self.appVersionType isEqualToString:@"1"]){
                //根据路径数组，分别读取本地路径下的文件（版本1，回调方法找寻文件）
                weakSelf.treeModel = [ZBAudioObject searchFilesInFolderPaths:[NSMutableArray arrayWithArray:fileURLs]];
                [weakSelf.audioListScrollOutlineView.outlineView reloadData];
                
            }else {
                weakSelf.treeModel = [ZBAudioObject searchFilesInFolderPaths:[NSMutableArray arrayWithArray:fileURLs]];
                [weakSelf.audioListScrollOutlineView.outlineView reloadData];
                
                NSArray *arr = [self.treeModel.childNodes[0] childNodes];//默认展示第一个列表的数据
                [weakSelf.tableViewDatas removeAllObjects];
                [weakSelf.tableViewDatas addObjectsFromArray:arr];
                [weakSelf.audioListScrollTableView.tableView reloadData];
                
            }
            
        }
    }];
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
    
    NSInteger count0 = [self.treeModel.childNodes count];
    NSInteger count1 = [[self.treeModel.childNodes[self.musicStatusCtrl.currentSection] childNodes] count];
//    NSInteger countS = [self.treeModel.childNodes count];
//    NSInteger countS = [self.treeModel.childNodes count];
//    NSInteger countS = [self.treeModel.childNodes count];
    NSLog(@"startPlaying 共 %ld 个列表，当前是第%ld个列表，共有%ld个子项，现在是第 %ld 项",count0,self.musicStatusCtrl.currentSection,count1,self.musicStatusCtrl.currentRow);
    
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
        //        NSDictionary *id3 = [ZBAudioObject getAudioFileID3:audio.path];
        NSLog(@"即将播放：%@，error__%@",audio.title,error);
    }
}

/**
 调整列表的收起与展开，并定位到当前为止
 */
-(void)reloadSectionStaus{
    
    if([self.appVersionType isEqualToString:@"1"]){
        //如果切换了列表，收起旧列表，展开当前歌曲所在列表
        if(self.musicStatusCtrl.currentSection != self.musicStatusCtrl.lastSection){
            for (int i = 0; i < self.treeModel.childNodes.count - 1; i++) {//减去随机
                TreeNodeModel *mo = self.treeModel.childNodes[i];
                if (i == self.musicStatusCtrl.currentSection){
                    mo.isExpand = YES;
                    [self.audioListScrollOutlineView.outlineView expandItem:mo expandChildren:YES];
                } else{
                    mo.isExpand = NO;
                    [self.audioListScrollOutlineView.outlineView collapseItem:mo collapseChildren:YES];
                }
                //这样做法可能比较耗资源
                [self.treeModel.childNodes removeObjectAtIndex:i];
                [self.treeModel.childNodes insertObject:mo atIndex:i];
                //改成这种方式
                //[[self.treeModel.childNodes objectAtIndex:i] setIsExpand:mo.isExpand];
            }
            
            [self relodSectionImageStatus];
            
        }
        
        
        //位置计算错误
        NSLog(@"currSec:%ld,currRowc:%ld,,,,lastSecc:%ld,lastRowc:%ld",self.musicStatusCtrl.currentSection,self.musicStatusCtrl.currentRow,self.musicStatusCtrl.lastSection,self.musicStatusCtrl.lastRow);
        //[self.audioListScrollOutlineView.outlineView reloadData];
        //页面滚动到当前row，根据row+section的数目总和确定位置，每+1代表多一行
        [self.audioListScrollOutlineView.outlineView scrollRowToVisible:(self.musicStatusCtrl.currentRow+1) + (self.musicStatusCtrl.currentSection+1) + 5];
        //取消选中row的位置？？
        //    [self.audioListScrollOutlineView.outlineView deselectRow:(self.musicStatusCtrl.currentRow+1) + (self.musicStatusCtrl.currentSection+1) + 5];
        
    }else if ([self.appVersionType isEqualToString:@"2"]) {
        
        //如果切换了列表，收起旧列表，展开当前歌曲对应的歌手所在列表
        if(self.musicStatusCtrl.currentSection != self.musicStatusCtrl.lastSection){
            for (int i = 0; i < self.treeModel.childNodes.count; i++) {//减去随机
                TreeNodeModel *mo = self.treeModel.childNodes[i];
                if (i == self.musicStatusCtrl.currentSection){
                    mo.isExpand = YES;
                    [self.audioListScrollOutlineView.outlineView expandItem:mo expandChildren:YES];
                } else{
                    mo.isExpand = NO;
                    [self.audioListScrollOutlineView.outlineView collapseItem:mo collapseChildren:YES];
                }
                //这样做法可能比较耗资源
                [self.treeModel.childNodes removeObjectAtIndex:i];
                [self.treeModel.childNodes insertObject:mo atIndex:i];
                //改成这种方式
                //[[self.treeModel.childNodes objectAtIndex:i] setIsExpand:mo.isExpand];
            }
            
            [self relodSectionImageStatus];
            
        }
        
        
        //位置计算错误
        NSLog(@"currSec:%ld,currRowc:%ld,,,,lastSecc:%ld,lastRowc:%ld",self.musicStatusCtrl.currentSection,self.musicStatusCtrl.currentRow,self.musicStatusCtrl.lastSection,self.musicStatusCtrl.lastRow);
        //[self.audioListScrollOutlineView.outlineView reloadData];
        //页面滚动到当前row，根据row+section的数目总和确定位置，每+1代表多一行
        [self.audioListScrollOutlineView.outlineView scrollRowToVisible:(self.musicStatusCtrl.artistRow+1) + (self.musicStatusCtrl.artistSection+1) + 5];
        //取消选中row的位置？？
        //    [self.audioListScrollOutlineView.outlineView deselectRow:(self.musicStatusCtrl.currentRow+1) + (self.musicStatusCtrl.currentSection+1) + 5];
        
        
        
        
        
        NSArray *arr = [self.treeModel.childNodes[self.musicStatusCtrl.currentSection] childNodes];//默认展示第一个列表的数据
        [self.tableViewDatas removeAllObjects];
        [self.tableViewDatas addObjectsFromArray:arr];
        [self.audioListScrollTableView.tableView reloadData];
        //页面滚动到当前row，根据row+section的数目总和确定位置，每+1代表多一行
        [self.audioListScrollTableView.tableView scrollRowToVisible:self.musicStatusCtrl.currentRow];
        
        
        NSTableColumn *col = [self.audioListScrollTableView.tableView tableColumns][0];
        col.title = [NSString stringWithFormat:@"当前列表；%@",[self.treeModel.childNodes[self.musicStatusCtrl.currentSection] name]];
        
        
        
        
    }
    
    
    
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
