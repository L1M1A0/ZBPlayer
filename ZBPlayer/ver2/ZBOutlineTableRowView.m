//
//  ZBOutlineTableRowView.m
//  ZBPlayer
//
//  Created by lzb on 2024/10/14.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import "ZBOutlineTableRowView.h"
#import "Masonry.h"

@implementation ZBOutlineTableRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)initWithView{
    NSView *section = [[NSView alloc]init];
    [self addSubview:section];
    [section mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(40);
    }];
    
    NSTableView *tableView = [[NSTableView alloc]init];
//    tableView.dataSource = self;
//    tableView.dataSource = self;
    [self addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(section.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    
}

@end
