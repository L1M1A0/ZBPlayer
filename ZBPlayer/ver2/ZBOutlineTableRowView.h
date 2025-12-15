//
//  ZBOutlineTableRowView.h
//  ZBPlayer
//
//  Created by lzb on 2024/10/14.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBOutlineTableRowView : NSView


@property (nonatomic, strong) NSView *section;

@property (nonatomic, strong) NSTableView *tableView;

-(void)initWithView;

@end

NS_ASSUME_NONNULL_END
