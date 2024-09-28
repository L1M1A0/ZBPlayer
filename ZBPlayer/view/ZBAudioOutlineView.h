//
//  ZBAudioOutlineView.h
//  ZBPlayer
//
//  Created by Li28 on 2019/5/26.
//  Copyright © 2019 Li28. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBAudioOutlineView : NSOutlineView<NSTableViewDelegate>


@property (nonatomic, assign) id<NSTableViewDelegate> tableViewDelegate;

@end

NS_ASSUME_NONNULL_END
