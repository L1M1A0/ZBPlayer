//
//  ZBScrollOutlineView.m
//  ZBPlayer
//
//  Created by lzb on 2024/10/1.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import "ZBScrollOutlineView.h"
#import "ZBThemeObject.h"

@implementation ZBScrollOutlineView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithColumnIdentifiers:(NSArray *)identifiers{
    if(self == [super init]){
        [self creatViewWithColumnIdentifiers:identifiers className:nil];
    }
    return self;
}

-(instancetype)initWithColumnIdentifiers:(NSArray *)identifiers className:(NSString *)className{
    if(self == [super init]){
        [self creatViewWithColumnIdentifiers:identifiers className:className];
    }
    return self;
}

/// <#Description#>
/// @param identifiers <#identifiers description#>
/// @param className <#className description#>
-(void)creatViewWithColumnIdentifiers:(NSArray *)identifiers className:(NSString *)className{
    
    
    if(!className || [className isEqualToString:@""]){
        //使用默认的NSOutlineView
        self.outlineView = [[NSOutlineView alloc]init];
    }else{
        //使用自定义的outlineView
        Class viewClass = NSClassFromString(className);
        self.outlineView = [[viewClass alloc]init];
    }
//

    ZBThemeObject *theme = [[ZBThemeObject alloc]init];
    [theme colorModelWithType:0];
    
    self.outlineView.wantsLayer = YES;
    self.outlineView.backgroundColor = theme.outlineViewColor;//[NSColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
    self.backgroundColor = theme.scrollViewColor;

//    self.outlineView.delegate = self;
//    self.outlineView.dataSource = self;

    //设置行与行之间的交替变化属性，如颜色等
//    [self.outlineView setIndentationPerLevel:11];
//    [self.outlineView setAutoresizesOutlineColumn:NO];
//    [self.outlineView setUsesAlternatingRowBackgroundColors:NO];
//    [self.outlineView makeViewWithIdentifier:NSOutlineViewDisclosureButtonKey owner:self];
//    self.outlineView.allowsMultipleSelection = NO;//是否可以同时选择多个
//    self.outlineView.layer.backgroundColor = [NSColor blueColor].CGColor;
//    self.outlineView.outlineTableColumn.hidden = YES;//隐藏列表
    
    for(int i = 0;i < identifiers.count;i++){
        NSTableColumn *column1 = [[NSTableColumn alloc]initWithIdentifier:identifiers[i]];
        column1.title = [NSString stringWithFormat:@"第%d列",i];//@"可创建一个空的，不创建的话，内容会跑到bar底下";
        column1.headerToolTip = @"列头提示";
        
        //注意，要先添加column才能设置conerview，不然显示不出来
        [self.outlineView addTableColumn:column1];
        //注意：先将column1添加到addTableColumn:之后才能设置背景颜色，不然不显示
    //    column1.tableView.backgroundColor = [NSColor redColor];
        
        //注意：以下方法为生效，留待以后重试。
//        NSView *vv =  [[NSView alloc]initWithFrame:NSMakeRect(0, 0, 100, 30)];
//        vv.wantsLayer = YES;
//        [column1.tableView.cornerView addSubview:vv];
//        column1.tableView.cornerView.wantsLayer = YES;
//        column1.tableView.cornerView.layer.backgroundColor = [NSColor yellowColor].CGColor;

        
        
    }

    
    //需要添加滚动视图，超出页面显示部分才能滚动查看，不然显示不全
//    NSScrollView *scrollView = [[NSScrollView alloc] init];
    [self setHasVerticalScroller:YES];
    [self setHasHorizontalScroller:NO];
    [self setFocusRingType:NSFocusRingTypeNone];
    [self setAutohidesScrollers:YES];
    [self setBorderType:NSBezelBorder];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setDocumentView:self.outlineView];
    /**
     重要：******禁止绘制ScrollView的背景，【解决ScrollView无法设置透明背景问题】***
     但是，此后所有【绘制背景的方法都失效】
     */
    [self setDrawsBackground:NO];
//    self.contentView.backgroundColor  = [[NSColor clearColor] colorWithAlphaComponent:0.1];
//    self.documentView.wantsLayer = YES;
//    self.documentView.layer.backgroundColor = [NSColor greenColor].CGColor;
//    self.backgroundColor = [NSColor blueColor];

    //添加到父视图
//    [self.playerSplitView addSubview:scrollViewOnSplitLeft];

    
}



@end
