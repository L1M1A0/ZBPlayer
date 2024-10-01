//
//  ZBScrollTableView.m
//  ZBPlayer
//
//  Created by lzb on 2024/10/2.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import "ZBScrollTableView.h"

@implementation ZBScrollTableView

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

-(void)creatViewWithColumnIdentifiers:(NSArray *)identifiers className:(NSString *)className{
    
    
    if(!className || [className isEqualToString:@""]){
        //使用默认的NSOutlineView
        self.tableView = [[NSTableView alloc]init];
    }else{
        //使用自定义的outlineView
        Class viewClass = NSClassFromString(className);
        self.tableView = [[viewClass alloc]init];
    }
    self.tableView.wantsLayer = YES;
    self.tableView.backgroundColor = [NSColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.1];
    

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
        [self.tableView addTableColumn:column1];
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
//    scrollViewOnSplitLeft.backgroundColor = [NSColor lightGrayColor];
    [self setDocumentView:self.tableView];
    //添加到父视图
//    [self.playerSplitView addSubview:scrollViewOnSplitLeft];

    
}



@end
