//
//  TreeNodeModel.m
//  OSX
//
//  Created by 李振彪 on 2018/3/14.
//  Copyright © 2018年 李振彪. All rights reserved.
//

#import "TreeNodeModel.h"

@implementation TreeNodeModel

-(instancetype)init{
    if(self = [super init]){
        self.name = @"";
        self.childNodes = [NSMutableArray array];
        self.isExpand = NO;
    }
    return self;
}


@end
