//
//  ZBMusicStatusControllerObject.h
//  ZBPlayer
//
//  Created by lzb on 2024/9/29.
//  Copyright © 2024 LiZB. All rights reserved.
//
/**
 *  ***通用
 *  用于管理播放器，当前播放的状态参数
 *  由于处理播放逻辑
 */


#import <Foundation/Foundation.h>

#import "TreeNodeModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface ZBMusicStatusControllerObject : NSObject

/** 当前播放的歌曲在总列表中的index 代表的是歌曲数据源列表，不能用于表示歌手列表的index*/
@property (nonatomic, assign) NSInteger currentSection;
/** 当前播放的歌曲在所在列表currentSection中的index 代表的是歌曲数据源列表中子节点的index，不能用于表示歌手列表的index,混用可能造成数组越界*/
@property (nonatomic, assign) NSInteger currentRow;
/** 上一次播放的歌曲在总列表中的index。与currentSection 相关联，记录上一次播放记录*/
@property (nonatomic, assign) NSInteger lastSection;
/** 上一次播放的歌曲在所在列表中的index，与currentRow 相关联，记录上一次播放记录*/
@property (nonatomic, assign) NSInteger lastRow;

//————————在版本2中使用，用于临时存储点击的列表，但还没开始真正使用，只有在开始播放时，才是同步设置为 currentSection 和 currentRow
/** 当前歌手总列表中的index，可能与currentSection是相同的，在播放前会因为选择歌手列表与currentSection不一样，所以两者不能混用*/
@property (nonatomic, assign) NSInteger artistSection;
/** 当前歌手在所在列表中的index，仅用于记录歌手在列表的的位置，混用可能会造成数据越界*/
@property (nonatomic, assign) NSInteger artistRow;


//~~~~~~~~~~~~~~状态管理

/** 是否正在播放  */
@property (nonatomic, assign) BOOL isPlaying;
/** 播放模式 是否是随机播放 优先级 */
@property (nonatomic, assign) BOOL isPlayModelRandom;
/** 播放模式 是否允许自动切换列表 优先级 */
@property (nonatomic, assign) BOOL isPlayModelSwitchList;
/** 播放模式 是否单曲循环 优先级最高 */
@property (nonatomic, assign) BOOL isPlayModelSingleRepeat;





/** 切歌  isNext：是否是下一首歌
 isStartPlay == YES，执行处理完逻辑之后，返回YES，开始播放
 */
- (BOOL)changeAudio:(BOOL)isNext dataSource:(TreeNodeModel *)treeModel;

@end

NS_ASSUME_NONNULL_END
