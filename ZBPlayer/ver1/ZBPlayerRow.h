//
//  ZBPlayerRow.h
//  OSX
//
//  Created by Li28 on 2019/4/7.
//  Copyright © 2019 Li28. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TreeNodeModel.h"
NS_ASSUME_NONNULL_BEGIN
#define ZBPlayerRowHeight 40



@protocol ZBPlayerRowDelegate;

@interface ZBPlayerRow : NSTableRowView

//@property (nonatomic, assign) BOOL isSelectedMe;
@property (nonatomic, strong) NSImageView *imageView;
@property (nonatomic, strong) NSTextField *textField;
@property (nonatomic, strong) NSButton *moreBtn;//打开更多
@property (nonatomic, strong) TreeNodeModel *model;
@property (nonatomic, weak) id <ZBPlayerRowDelegate> delegate;
-(instancetype)initWithLevel:(NSInteger)level;

@end


@protocol ZBPlayerRowDelegate

-(void)playerRow:(ZBPlayerRow *)playerRow didSelectRowForModel:(TreeNodeModel *)model;
-(void)playerRow:(ZBPlayerRow *)playerRow menuItem:(NSMenuItem *)menuItem;
-(void)playerRowMoreBtn:(ZBPlayerRow *)playerRow;

@end

NS_ASSUME_NONNULL_END
