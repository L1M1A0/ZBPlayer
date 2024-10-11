//
//  ZBTableRowView.m
//  ZBPlayer
//
//  Created by lzb on 2024/10/6.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import "ZBTableRowView.h"
#import "Masonry.h"
#import "TreeNodeModel.h"
#import "ZBThemeObject.h"

@implementation ZBTableRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithRow:(NSInteger)row{
    if(self = [super init]){
        [self creatViewWithRow:row];
    }
    return self;
}



-(void)creatViewWithRow:(NSInteger)row{
    self.row = row;
    NSInteger leftgap = 10;
    NSInteger topGap = 0;
    
//    NSInteger rowHeight = topGap * 2 + 30;
    
//    [rowView setBackgroundColor:[NSColor whiteColor]];
//    NSString *idet = [NSString stringWithFormat:@"childNode222_ss"];

    
    ZBThemeObject *theme = [[ZBThemeObject alloc]init];
    [theme colorModelWithType:0];
    
    
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
        make.left.equalTo(self.mas_left).offset(leftgap);
//        make.width.mas_equalTo(@310);//设置宽，同时设置setLineBreakMode支持换行
        make.right.equalTo(self.mas_right).offset(-topGap);
        make.centerY.equalTo(self.mas_centerY);//对齐前面的控件，垂直居中（不用设置高度,自动计算高度）
    }];

    
}

-(void)setModel:(TreeNodeModel *)model{
    _model = model;
    self.textField.stringValue = [NSString stringWithFormat:@"【%ld】%@",self.row+1,model.name];
}


@end
