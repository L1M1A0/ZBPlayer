//
//  ZBTableRowView.h
//  ZBPlayer
//
//  Created by lzb on 2024/10/6.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TreeNodeModel;


@protocol ZBTableRowViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface ZBTableRowView : NSTableRowView


@property (nonatomic, strong) NSTextField *textField;
@property (nonatomic, strong) TreeNodeModel *model;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, weak) id <ZBTableRowViewDelegate> delegate;

-(instancetype)initWithRow:(NSInteger)row;
@end


@protocol ZBTableRowViewDelegate

-(void)playerRow:(ZBTableRowView *)playerRow didSelectRowForModel:(TreeNodeModel *)model;


@end

NS_ASSUME_NONNULL_END
