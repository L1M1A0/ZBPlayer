//
//  ZBScrollOutlineTableView.m
//  ZBPlayer
//
//  Created by lzb on 2024/10/14.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import "ZBScrollOutlineTableView.h"
#import "Masonry.h"
#import "TreeNodeModel.h"


@implementation ZBScrollOutlineTableView//<NSTableViewDelegate,NSTableViewDataSource>

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)ViewWithDataSource:(NSMutableArray *)dataSource{
    CGFloat rowOpenTableHeight = 100;
    CGFloat rowHeight = 40;
    self.views = [NSMutableArray array];
    
    for(int i = 0; i<dataSource.count;i++){
        ZBOutlineTableRowView *outlineview = [[ZBOutlineTableRowView alloc]init];
//        outlineview.tableView.dataSource = self;
//        outlineview.tableView.delegate = self;
        [self addSubview:outlineview];
        [outlineview mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.mas_top).offset(rowHeight*i+rowHeight*5+rowHeight);
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
//            make.height.mas_equalTo(rowHeight+rowHeight*5);
            
        }];
        
        [self.views addObject:outlineview];
    }
}

//-(void)updateViewWithDataSource:()
@end
