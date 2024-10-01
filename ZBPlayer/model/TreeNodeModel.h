//
//  TreeNodeModel.h
//  OSX
//
//  Created by Li28 on 2018/3/14.
//  Copyright © 2018年 Li28. All rights reserved.
//

/**
 目录结构、大纲列表的数据模型
 
 详细使用方法在 ZBAudioObject.m 中
 
 由于本模型可以构成很复杂的数据目录结构列表，所以需要通过层级level和index等多重数据才能确定位置，如下：
 基本层级结构如下：层级（列表1（数据1，数据2...）、列表2（数据1，数据2...）...），层级之外除了根层级(0)没有父层级（-1），其他都有父层级，一层一层+1
 英文表示结构如下：level（section1（row1，row2...）、section2（row1，row2...））...），
 同一层级的层级是一样的，通过层级，可以快速获取所需要的数据所在层级，减少查找工作，然后通过寻找该层级下的列表的sectionIndex，再定位到rowIndex指向的数据。
 
 */


#import <Foundation/Foundation.h>

@class ZBAudioModel;

@interface TreeNodeModel : NSObject

@property (nonatomic, strong) ZBAudioModel *audio;
@property (nonatomic, strong) NSString *name;//当前节点的名字
@property (nonatomic, strong) NSMutableArray *childNodes;//当前节点的数据源
@property (nonatomic, assign) BOOL isExpand;//YES展开、NO收起

/**
 节点层级：
 nodeLevel：表示当前数据的层级。
 superLevel：当前数据的父节点的层级。根节点无层级：-1；
 根级节点的层级为0，其父层级为-1，表示没有父层级。
 
 */
@property (nonatomic, assign) NSInteger nodeLevel;//当前节点的层级
@property (nonatomic, assign) NSInteger superLevel;//父节点的层级。无层级：-1；
/**
 通过{nodeLevel，sectionIndex，rowIndex}可以很快确定当前数据在当前列表的数据源中所在的位置，相当与身份证。
 根节点：没有sectionIndex，用-1表示，代表是根级目录，没有父层级；根节点的rowIndex是他们在数据源所在的位置
 次级节点：自身的sectionIndex是父级节点的rowIndex，自身的rowIndex是其在当前列表宗中所在的位置。
 */
@property (nonatomic, assign) NSInteger sectionIndex;//数据源阶段自动生成此数据在的列表的section位置。
@property (nonatomic, assign) NSInteger rowIndex;//数据源阶段自动生成此数据所在列表中的row的位置

@end
