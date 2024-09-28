//
//  ZBPlayerSection.h
//  OSX
//
//  Created by Li28 on 2019/4/7.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TreeNodeModel.h"


NS_ASSUME_NONNULL_BEGIN

#define ZBPlayerSectionHeight 40

@protocol ZBPlayerSectionDelegate;

@interface ZBPlayerSection : NSTableRowView

@property (nonatomic, strong) NSImageView *imageView;
@property (nonatomic, strong) NSTextField *textField;//ZBTextFieldCell
@property (nonatomic, strong) NSButton *moreBtn;//导入
@property (nonatomic, strong) TreeNodeModel *model;
@property (nonatomic, assign) BOOL isImageExpand;
@property (nonatomic, assign) id <ZBPlayerSectionDelegate> delegate;

-(instancetype)initWithLevel:(NSInteger)level;
-(void)didSelected;

@end
@protocol ZBPlayerSectionDelegate <NSObject>

-(void)playerSectionDidSelect:(ZBPlayerSection *)playerSection;

-(void)playerSectionMoreBtn:(ZBPlayerSection *)playerSection;



@end
NS_ASSUME_NONNULL_END
