//
//  ZBPlayerSection.m
//  OSX
//
//  Created by Li28 on 2019/4/7.
//  Copyright © 2019 Li28. All rights reserved.
//

#import "ZBPlayerSection.h"
#import "Masonry.h"
#import "ZBThemeObject.h"

@interface ZBPlayerSection()<NSTextFieldDelegate>{
    NSString *appVersionType;
}

@end

@implementation ZBPlayerSection

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    //跟踪鼠标
    
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways owner:self userInfo:@{@"aaa":@"你比"}];
    [self addTrackingArea:trackingArea];
    
}

-(instancetype)initWithLevel:(NSInteger)level{
    if(self = [super init]){
        [self creatViewWithLevel:level];
    }
    return self;
}



-(void)creatViewWithLevel:(NSInteger)level{
    
    //获取app的界面版本
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    appVersionType = [user stringForKey:kDefaultAppViewVersionKey];
  
    ZBThemeObject *theme = [[ZBThemeObject alloc]init];
    [theme colorModelWithType:0];
    
    
    NSInteger leftgap = 15;
    NSInteger topGap = 5;
    NSInteger rowHeight = ZBPlayerSectionHeight - 5 * 2;
    NSColor *color = theme.outlineSectionColor;//[NSColor colorWithCalibratedWhite:0 alpha:0.5];//[NSColor colorWithRed:100 green:100 blue:1 alpha:0];
    
    
    self.wantsLayer = YES;
    self.layer.backgroundColor = color.CGColor;
//    self.backgroundColor = color;
    

    
    
    //用于展示选中或者取消选择的状态，而不再是指示列表的折叠与展开（系统控制）
    self.imageView = [[NSImageView alloc]initWithFrame:NSZeroRect];
    self.imageView.wantsLayer = YES;
//    self.imageView.layer.backgroundColor = theme.outlineSectionImageViewColor.CGColor;//color.CGColor;
    self.imageView.image = [NSImage imageNamed:@"list_hide"];
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(leftgap+leftgap*level);
        make.top.equalTo(self.mas_top).offset(topGap);
        make.width.mas_equalTo(rowHeight);
        make.height.mas_equalTo(rowHeight);
    }];
    

    self.textField = [NSTextField wrappingLabelWithString:@""];//[[NSTextField alloc]initWithFrame:NSZeroRect];
    self.textField.textColor = [NSColor whiteColor];
    self.textField.alignment = NSTextAlignmentLeft;
    self.textField.font = [NSFont systemFontOfSize:13];
    self.textField.delegate = self;
    [self.textField setBezeled:NO];
    [self.textField setEditable:NO];
    [self.textField setDrawsBackground:NO];
    [self.textField setSelectable:NO];
    [self.textField setMaximumNumberOfLines:2];//最多支持换行的数量
    [[self.textField cell] setLineBreakMode:NSLineBreakByCharWrapping];//支持换行模式
    [[self.textField cell] setTruncatesLastVisibleLine:YES];//过长字符，显示省略号...

        self.textField.wantsLayer = YES;
//        self.textField.layer.backgroundColor = theme.outlineSectionTextFieldColor.CGColor;
    //    self.textField.stringValue = @"";
    [self addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right).offset(topGap);
//        make.width.mas_equalTo(@310);//设置宽，同时设置setLineBreakMode支持换行
        make.right.equalTo(self.mas_right).offset(-35);
        make.centerY.equalTo(self.imageView.mas_centerY);//对齐前面的控件，垂直居中（不用设置高度,自动计算高度）
    }];
    

    
    
    self.moreBtn = [[NSButton alloc]initWithFrame:NSZeroRect];
    [self.moreBtn setButtonType:NSButtonTypeMomentaryChange];
    self.moreBtn.bezelStyle = NSBezelStyleRounded;
    self.moreBtn.title = @"";
    self.moreBtn.image = [NSImage imageNamed:@"cellMore"];
    self.moreBtn.hidden = YES;
    self.moreBtn.bordered = NO;//是否带边框
    self.moreBtn.wantsLayer = YES;
//    self.moreBtn.layer.backgroundColor = color.CGColor;
    self.moreBtn.target = self;
    self.moreBtn.action = @selector(btnAction:);
    [self addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.textField.mas_right).offset(10);
        make.right.equalTo(self.mas_right).offset(-topGap);
        make.width.mas_equalTo(@25);
        make.centerY.equalTo(self.textField.mas_centerY);
    }];
    

    
}


-(void)drawSelectionInRect:(NSRect)dirtyRect{
//    NSLog(@"selectionHighlightStyle_%ld",self.selectionHighlightStyle);
//    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone ){
//        NSRect selectionRect = NSInsetRect(self.bounds, 1, 1);//重绘的范围
//        [[NSColor colorWithWhite:0.9 alpha:1] setStroke];//绘制边框
//        [[NSColor colorWithWhite:0.8 alpha:1] setFill];//绘制背景色
//        
//        //重绘
////        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:10 yRadius:20];
//        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
//        [selectionPath fill];
//        [selectionPath stroke];
//    }
    
}


-(void)setModel:(TreeNodeModel *)model{
    _model = model;
    self.textField.stringValue = model.name;
    
}
//鼠标进入
-(void)mouseEntered:(NSEvent *)event{
    self.textField.textColor = [NSColor redColor];
    self.moreBtn.hidden = NO;
//    NSLog(@"执行鼠标进入");
}
//鼠标移出
-(void)mouseExited:(NSEvent *)event{
//    NSLog(@"执行鼠标离开");
    self.textField.textColor = [NSColor whiteColor];
    self.moreBtn.hidden = YES;
}

- (void)rightMouseDown:(NSEvent *)event{
//    NSLog(@"执行鼠标右键方法");
}
- (void)otherMouseDown:(NSEvent *)event{
//    NSLog(@"otherMouseDown");
}
- (void)mouseUp:(NSEvent *)event{
//    NSLog(@"mouseUp");
}
- (void)rightMouseUp:(NSEvent *)event{
//    NSLog(@"rightMouseUp");
}
- (void)otherMouseUp:(NSEvent *)event{
//    NSLog(@"otherMouseUp");
}
- (void)mouseMoved:(NSEvent *)event{
//    NSLog(@"mouseMoved");
}
- (void)mouseDragged:(NSEvent *)event{
//    NSLog(@"mouseDragged");
}
- (void)scrollWheel:(NSEvent *)event{
//    NSLog(@"scrollWheel");
}

-(void)mouseDown:(NSEvent *)event{
//    [NSApp sendAction:@selector(imageViewAction) to:self.imageView from:self];
//    NSLog(@"执行鼠标左键点击方法");
    if (self.model.isExpand == YES) {
        self.model.isExpand = NO;
    }else{
        self.model.isExpand = YES;
    }
    [self didSelected];
}

-(void)didSelected{
//    NSLog(@"self.model.isExpand_%d,sec_%ld,Row_%ld,next_%hhd,pre_%hhd,sel_%hhd",self.model.isExpand,self.model.sectionIndex,self.model.rowIndex,self.nextRowSelected,self.previousRowSelected,self.selected);
    
    if (self.model.isExpand == YES) {
        self.imageView.image = [NSImage imageNamed:@"list_show"];
    }else{
        self.imageView.image = [NSImage imageNamed:@"list_hide"];
    }
    if(self.delegate){
        [self.delegate playerSectionDidSelect:self];
    }
}

-(void)btnAction:(NSButton *)sender{
    if(self.delegate){
        [self.delegate playerSectionMoreBtn:self];
    }
}

-(void)setIsImageExpand:(BOOL)isImageExpand{
    _isImageExpand = isImageExpand;
    if (isImageExpand == YES) {
        self.model.isExpand = YES;
        self.imageView.image = [NSImage imageNamed:@"list_show"];
    }else{
        self.model.isExpand = NO;
        self.imageView.image = [NSImage imageNamed:@"list_hide"];
    }
}


#pragma mark NSTextFieldDelegate



-(void)textFieldAction{
    NSLog(@"textFieldAction");
}

-(void)imageViewAction:(id)sender{
    NSLog(@"imageViewAction");
    if(self.delegate){
        
//        if (self.model.isExpand == YES) {
//            self.imageView.image = [NSImage imageNamed:@"list_show"];
//        }else{
//            self.imageView.image = [NSImage imageNamed:@"list_hide"];
//        }
        [self.delegate playerSectionImageAction:self];
    }
}

@end
