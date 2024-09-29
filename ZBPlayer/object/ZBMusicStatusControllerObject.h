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

/** 当前播放的歌曲在总列表中的index*/
@property (nonatomic, assign) NSInteger currentSection;
/** 当前播放的歌曲在所在列表中的index*/
@property (nonatomic, assign) NSInteger currentRow;
/** 上一次播放的歌曲在总列表中的index*/
@property (nonatomic, assign) NSInteger lastSection;
/** 上一次播放的歌曲在所在列表中的index*/
@property (nonatomic, assign) NSInteger lastRow;
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
