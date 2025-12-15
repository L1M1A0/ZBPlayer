//
//  ZBScrollOutlineTableView.h
//  ZBPlayer
//
//  Created by lzb on 2024/10/14.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ZBOutlineTableRowView.h""

NS_ASSUME_NONNULL_BEGIN

@interface ZBScrollOutlineTableView : NSScrollView


@property (nonatomic, strong) NSMutableArray *views;

@end

NS_ASSUME_NONNULL_END
