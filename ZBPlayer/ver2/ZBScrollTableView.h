//
//  ZBScrollTableView.h
//  ZBPlayer
//
//  Created by lzb on 2024/10/2.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBScrollTableView : NSScrollView


@property(nonatomic,strong) NSTableView *tableView;

/// 根据identifiers数组创建一个可滚动的tableView，默认类型是NSTableView
/// @param identifiers 数组，存储tableView的column的identifier
-(instancetype)initWithColumnIdentifiers:(NSArray *)identifiers;


/// 根据identifiers数组创建一个可滚动的tableView，并且可以使用自定义的tableView的Class
/// @param identifiers 数组，存储tableView的column的identifier
/// @param className outlineView的Class名字。传入@""或者nil，表示使用默认的NSTableView类型；传入类名的字符串，就可以使用自定义的控件，如：@"ZBAudioOutlineView"
-(instancetype)initWithColumnIdentifiers:(NSArray *)identifiers className:(NSString *)className;


@end

NS_ASSUME_NONNULL_END
