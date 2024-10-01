//
//  ZBScrollOutlineView.h
//  ZBPlayer
//
//  Created by lzb on 2024/10/1.
//  Copyright © 2024 LiZB. All rights reserved.
//

/**
 ZBScrollOutlineView: 在NSScrollView上面添加一个NSOutLineView，使其超出页面的部分可以滚动
 
 注意，创建一个可滚动的NSTableview也是同样思路。
 
 */


#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBScrollOutlineView : NSScrollView

@property(nonatomic,strong) NSOutlineView *outlineView;


/// 根据identifiers数组创建一个可滚动的outLineView，默认类型是NSOutlineView
/// @param identifiers 数组，存储outlineView的column的identifier，outlineView一般不建议添加多个column，之添加一个column就行，tableView可以根据需求数量添加
-(instancetype)initWithColumnIdentifiers:(NSArray *)identifiers;


/// 根据identifiers数组创建一个可滚动的outLineView，并且可以使用自定义的outlineView的Class
/// @param identifiers 数组，存储outlineView的column的identifier，outlineView一般不建议添加多个column，之添加一个column就行，tableView可以根据需求数量添加
/// @param className outlineView的Class名字。传入@""或者nil，表示使用默认的NSOutlineView类型；传入类名的字符串，就可以使用自定义的控件，如：@"ZBAudioOutlineView"
-(instancetype)initWithColumnIdentifiers:(NSArray *)identifiers className:(NSString *)className;

@end

NS_ASSUME_NONNULL_END
