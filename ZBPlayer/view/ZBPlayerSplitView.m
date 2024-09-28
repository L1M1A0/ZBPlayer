//
//  ZBPlayerSplitView.m
//  OSX
//
//  Created by Li28 on 2019/4/16.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import "ZBPlayerSplitView.h"

@implementation ZBPlayerSplitView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)drawDividerInRect:(NSRect)rect{
//    NSLog(@"DividerInRect——%f",rect.size.width);
//    NSRect re1 = NSMakeRect(rect.origin.x, rect.origin.y, 50, rect.size.height);
//    NSRect selectionRect = NSInsetRect(re1, 1, 1);
    
    [[NSColor colorWithWhite:0.9 alpha:1] setStroke];
    [[NSColor colorWithCalibratedRed:0x22/255.0 green:0x22/255.0 blue:0x22/255.0 alpha:0xFF/255.0] setFill];
//    [[NSColor redColor] setFill];

    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    [path fill];
    [path stroke];
}


@end
