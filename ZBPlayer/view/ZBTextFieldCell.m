//
//  ZBTextFieldCell.m
//  OSX
//
//  Created by Li28 on 2019/4/20.
//  Copyright © 2019 Li28. All rights reserved.
//

#import "ZBTextFieldCell.h"

@implementation ZBTextFieldCell


- (NSRect)adjustedFrameToVerticallyCenterText:(NSRect)frame {
    // super would normally draw text at the top of the cell
    CGFloat fontSize = self.font.boundingRectForFont.size.height;
    NSInteger offset = floor((NSHeight(frame) - ceilf(fontSize))/2)-1;
    NSRect centeredRect = NSInsetRect(frame, 0, offset);
    return centeredRect;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView
               editor:(NSText *)editor delegate:(id)delegate event:(NSEvent *)event {
    [super editWithFrame:[self adjustedFrameToVerticallyCenterText:aRect]
                  inView:controlView editor:editor delegate:delegate event:event];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView
                 editor:(NSText *)editor delegate:(id)delegate
                  start:(NSInteger)start length:(NSInteger)length {
    
    [super selectWithFrame:[self adjustedFrameToVerticallyCenterText:aRect]
                    inView:controlView editor:editor delegate:delegate
                     start:start length:length];
}

- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)view {
    [super drawInteriorWithFrame:
     [self adjustedFrameToVerticallyCenterText:frame] inView:view];
}

//原文：https://blog.csdn.net/freewaywalker/article/details/10815589

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
    if([self isHighlighted]) { // 该单元格处于选中状态时
//        color = [NSColor cyanColor];
//        [color set];
        NSRectFill(cellFrame);
        
        NSDictionary *attribs = [[NSMutableDictionary alloc] init];
        [attribs setValue:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paraStyle setFirstLineHeadIndent:12.0];
        [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        [attribs setValue:paraStyle forKey:NSParagraphStyleAttributeName];
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:14];
        [attribs setValue:font forKey:NSFontAttributeName];
        [[self title] drawInRect:cellFrame withAttributes:attribs];
        
    }
    else { // 该单元格处于未选中状态时
        NSDictionary *attribs = [[NSMutableDictionary alloc] init];
        [attribs setValue:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [paraStyle setFirstLineHeadIndent:12.0];
        [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        [attribs setValue:paraStyle forKey:NSParagraphStyleAttributeName];
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:14];
        [attribs setValue:font forKey:NSFontAttributeName];
        [[self title] drawInRect:cellFrame withAttributes:attribs];
    }
}

@end
