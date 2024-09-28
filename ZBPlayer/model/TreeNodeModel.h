//
//  TreeNodeModel.h
//  OSX
//
//  Created by 李振彪 on 2018/3/14.
//  Copyright © 2018年 李振彪. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZBAudioModel;

@interface TreeNodeModel : NSObject

@property (nonatomic, strong) ZBAudioModel *audio;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *childNodes;//
@property (nonatomic, assign) BOOL isExpand;
@property (nonatomic, assign) NSInteger nodeLevel;//当前层级
//附加
@property (nonatomic, assign) NSInteger superLevel;//父层级
@property (nonatomic, assign) NSInteger sectionIndex;
@property (nonatomic, assign) NSInteger rowIndex;

@end
