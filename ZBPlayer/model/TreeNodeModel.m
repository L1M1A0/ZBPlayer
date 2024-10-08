//
//  TreeNodeModel.m
//  OSX
//
//  Created by Li28 on 2018/3/14.
//  Copyright © 2018年 Li28. All rights reserved.
//

#import "TreeNodeModel.h"

@implementation TreeNodeModel

-(instancetype)init{
    if(self = [super init]){
        self.name = @"";
        self.childNodes = [NSMutableArray array];
        self.artists = [NSMutableArray array];
        self.isExpand = NO;
        self.isSelected = YES;
    }
    return self;
}


@end
