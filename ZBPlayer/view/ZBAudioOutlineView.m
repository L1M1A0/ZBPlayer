//
//  ZBAudioOutlineView.m
//  ZBPlayer
//
//  Created by Li28 on 2019/5/26.
//  Copyright © 2019 Li28. All rights reserved.
//

#import "ZBAudioOutlineView.h"

@implementation ZBAudioOutlineView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


/**
 自定义图标和样式 方法1：与方法2的原理是一样的。都可以实现。
 两种思路都有参考学习价值
 */
-(void)layout{
    [super layout];
    for (NSView *view in self.subviews) {
        for (NSView *subView in view.subviews) {
            if ([subView.identifier isEqualToString:NSOutlineViewDisclosureButtonKey]) {
               // 设置图片
               NSButton *disclosure = (NSButton *)subView;
               disclosure.imageScaling = NSImageScaleProportionallyUpOrDown;//设置图片显示模式，此参数可以防止图片变形
               disclosure.image = [NSImage imageNamed:@"list_show"];
               disclosure.alternateImage = [NSImage imageNamed:@"statusBarNext"];
               // 设置frame，修改其位置，默认是在左边的。
//               CGFloat x = view.frame.size.width - 100;
//               CGFloat y = disclosure.frame.origin.y;
//               [disclosure setFrameOrigin:NSMakePoint(x, y)];
           }
        }
    }
    
}

/**
 自定义图标和样式 方法2：与方法1的原理是一样的。都可以实现。
 两种思路都有参考学习价值
 */
- (id)makeViewWithIdentifier:(NSString *)identifier owner:(id)owner{
    id view = [super makeViewWithIdentifier:identifier owner:owner];
    if ([identifier isEqualToString:NSOutlineViewDisclosureButtonKey] && view){
        // Do your customization
        // return disclosure button view
        [view setImage:[NSImage imageNamed:@"list_show"]];
        [view setAlternateImage:[NSImage imageNamed:@"statusBarNext"]];
        [view setImageScaling:NSImageScaleProportionallyUpOrDown];//设置图片显示模式，此参数可以防止图片变形
        [view setBordered:NO];
        [view setTitle:@"111"];
        return view;

    }
    return view;
    
}



@end
