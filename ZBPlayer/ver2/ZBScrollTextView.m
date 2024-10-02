//
//  ZBScrollTextView.m
//  ZBPlayer
//
//  Created by lzb on 2024/10/2.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import "ZBScrollTextView.h"

@implementation ZBScrollTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithScrollTextView{
    if(self == [super init]){
        [self creatView];
    }
    return self;
}



-(void)creatView{
    
    
    [self setHasVerticalScroller:YES];
    [self setHasHorizontalScroller:YES];
    [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
//    self.backgroundColor = [NSColor purpleColor];


    self.textView = [[NSTextView alloc]initWithFrame:CGRectZero];
    self.textView.wantsLayer = YES;
    self.textView.layer.backgroundColor = [NSColor greenColor].CGColor;
    [self.textView setMinSize:NSMakeSize(100, self.frame.size.height-80)];
    [self.textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [self.textView setVerticallyResizable:YES];
    [self.textView setHorizontallyResizable:YES];
    [self.textView setAutoresizingMask:NSViewWidthSizable];
    [[self.textView textContainer]setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.textView textContainer]setWidthTracksTextView:YES];
    [self.textView setFont:[NSFont fontWithName:@"PingFang-SC-Regular" size:17.0]];
//    [self.textView setEditable:NO];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.lineSpacing = 10;//行间距
    [self.textView setDefaultParagraphStyle:style];
    //将NSTextView 设置为NSScrollView的DocumentView，使其可以滚动
    [self setDocumentView:self.textView];
//    [self.playerSplitView addSubview:slef];
    
    
}


@end
