//
//  ZBPlayerRow.m
//  OSX
//
//  Created by Li28 on 2019/4/7.
//  Copyright © 2019 Li28. All rights reserved.
//

#import "ZBPlayerRow.h"
#import "Masonry.h"


@implementation ZBPlayerRow

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    //跟踪鼠标
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]initWithRect:dirtyRect options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
 
//    self.textField.stringValue = self.model.name;
    //ZBTextFieldCell
//    [self.textField drawInteriorWithFrame:NSMakeRect(50, 0, self.frame.size.width, self.frame.size.height) inView:self];
//    [self.textField drawWithFrame:self.frame inView:self];

}
-(void)drawSelectionInRect:(NSRect)dirtyRect{
    if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyleNone ){
        NSRect selectionRect = NSInsetRect(self.bounds, 1, 1);//重绘的范围
        [[NSColor colorWithWhite:0.9 alpha:1] setStroke];//绘制边框
//        [[NSColor greenColor] setFill];//绘制背景色
        
        //重绘
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:10 yRadius:20];
        //NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
        [selectionPath fill];
        [selectionPath stroke];
    }
}

//-(void)setIsSelectedMe:(BOOL)isSelectedMe{
//    _isSelectedMe = isSelectedMe;
//    if (isSelectedMe == YES) {
//        self.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.3].CGColor;
//    }else{
//        self.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.0].CGColor;
//    }
//}


-(instancetype)initWithLevel:(NSInteger)level{
    if(self = [super init]){
        [self creatViewWithLevel:level];
    }
    return self;
}



-(void)creatViewWithLevel:(NSInteger)level{
    //0：不向右缩进。1、2等其他数字，像右缩进倍数
    level = 0;
    NSInteger leftgap = 10;
    NSInteger topGap = 5;
    NSInteger rowHeight = ZBPlayerRowHeight - topGap * 2;
    NSColor *color = [NSColor colorWithRed:1 green:1 blue:1 alpha:0];

    self.wantsLayer = YES;
    self.layer.backgroundColor = color.CGColor;
    self.imageView = [[NSImageView alloc]initWithFrame:NSZeroRect];
    self.imageView.wantsLayer = YES;
    self.imageView.layer.backgroundColor = color.CGColor;
    self.imageView.image = [NSImage imageNamed:@"more_addTo"];
    self.imageView.hidden  = YES;//鼠标滑过的时候显示
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(leftgap+leftgap*level);
        make.top.equalTo(self.mas_top).offset(topGap);
        make.width.mas_equalTo(rowHeight);
        make.height.mas_equalTo(rowHeight);
    }];
    
    
    //ZBTextFieldCell
//    self.textField = [[ZBTextFieldCell alloc]init];
//    self.textField.textColor = [NSColor whiteColor];
//    self.textField.alignment = NSTextAlignmentLeft;
//    self.textField.drawsBackground = YES;
//    self.textField.backgroundColor = [NSColor greenColor];

    self.textField = [NSTextField wrappingLabelWithString:@""];//[[NSTextField alloc]initWithFrame:NSZeroRect];
    self.textField.textColor = [NSColor whiteColor];
    self.textField.alignment = NSTextAlignmentLeft;
    self.textField.font = [NSFont systemFontOfSize:11];
    [self.textField setBezeled:NO];
    [self.textField setEditable:NO];
    [self.textField setDrawsBackground:NO];
    [self.textField setMaximumNumberOfLines:2];//最多支持换行的数量
    [[self.textField cell] setLineBreakMode:NSLineBreakByCharWrapping];//支持换行模式
    [[self.textField cell] setTruncatesLastVisibleLine:YES];//过长字符，显示省略号...
//    self.textField.wantsLayer = YES;
//    self.textField.layer.backgroundColor = [NSColor orangeColor].CGColor;
//    self.textField.stringValue = @"";
//    self.textField.backgroundColor = [NSColor cyanColor];
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
    self.moreBtn.layer.backgroundColor = color.CGColor;
    self.moreBtn.target = self;
    self.moreBtn.action = @selector(btnAction:);
    [self addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.textField.mas_right).offset(topGap);
        make.right.equalTo(self.mas_right).offset(-topGap);
        make.width.mas_equalTo(@25);
        make.centerY.equalTo(self.textField.mas_centerY);
    }];
}

-(void)setModel:(TreeNodeModel *)model{
    _model = model;
    self.textField.stringValue = model.name;
    self.textField.toolTip = model.name;
}


//鼠标进入
-(void)mouseEntered:(NSEvent *)event{
    self.textField.textColor = [NSColor redColor];
    self.imageView.hidden  = NO;
    self.moreBtn.hidden = NO;
    self.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0.3].CGColor;
}
//鼠标移出
-(void)mouseExited:(NSEvent *)event{
    self.textField.textColor = [NSColor whiteColor];
    self.imageView.hidden  = YES;
    self.moreBtn.hidden = YES;
    self.layer.backgroundColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:0].CGColor;
}


-(void)rightMouseDown:(NSEvent *)event{
//    NSLog(@"按下了鼠标右键");
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
//    NSArray *arr = @[@"初始列表",@"新增列表",@"更新本组",@"删除本组",@"当前播放",@"搜索音乐",@"定位文件"];
    NSArray *arr = @[kMenuItemInitializeList,kMenuItemInsertSection,kMenuItemUpdateSection,
                     kMenuItemDeleteSection,kMenuItemLocatePlaying,kMenuItemSearchMusic,kMenuItemShowAll,kMenuItemShowInFinder];

    for (int i = 0; i < arr.count; i++) {
        [theMenu insertItem:[self menuItem:arr[i] tag:i] atIndex:i];
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
    [NSMenu popUpContextMenu:theMenu withEvent:event forView:self];
}
- (NSMenuItem *)menuItem:(NSString *)title tag:(NSInteger)tag{
    //keyEquivalent 快捷键
    NSMenuItem *item = [[NSMenuItem alloc]initWithTitle:title action:@selector(menuItemAction:) keyEquivalent:@""];
    item.tag = tag;
    return item;
}

-(void)menuItemAction:(NSMenuItem *)menuItem{
    NSLog(@"点击了菜单：%@,%ld,%@",menuItem.title,menuItem.tag,menuItem.keyEquivalent);
    if (self.delegate) {
        [self.delegate playerRow:self menuItem:menuItem];
    }
}

-(void)mouseDown:(NSEvent *)event{
    NSLog(@"按下了鼠标左键");
    if(self.delegate){
        //ZBTextFieldCell
        //[self.delegate playerRow:self didSelectRowForModel:self.model];
    }
}

-(void)btnAction:(NSButton *)sender{
    if(self.delegate){
        [self.delegate playerRowMoreBtn:self];
    }
}

@end
