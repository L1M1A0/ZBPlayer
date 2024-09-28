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



- (id)makeViewWithIdentifier:(NSString *)identifier owner:(id)owner{
    id view = [super makeViewWithIdentifier:identifier owner:owner];
    if ([identifier isEqualToString:NSOutlineViewDisclosureButtonKey] && view){
        // Do your customization
        // return disclosure button view
        [view setImage:[NSImage imageNamed:@"list_show"]];
        [view setAlternateImage:[NSImage imageNamed:@"list_hide"]];
        [view setBordered:NO];
        [view setTitle:@" "];
        return view;

    }
    return view;
}

@end
