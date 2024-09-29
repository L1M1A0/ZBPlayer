//
//  ZBAudioObject.h
//  OSX
//
//  Created by Li28 on 2019/5/8.
//  Copyright © 2019 Li28. All rights reserved.
//

/**
 * 音频数据管理模型
 * 1. 从本地读取音频数据列表，生成数据源
 * 2. 根据需求，生成适合播放器需求的数据结构
 */


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBAudioObject : NSObject


/**
 遍历之后获得的文件数组
 */
@property (nonatomic, strong) NSMutableArray *audios;


/**
 通过路径 获取本地音频文件（实现获取子文件中的文件）

 @param filePath 本地基础路径
 */
-(void)audioInPath:(NSString *)filePath;

/**
 根据文件基础路径，遍历该路径下的文件
 
 @param basePath 基础路径
 @param folder  子文件夹名字，可以是空字符串：@"",
 @param block  isFolder：是否是文件夹。basePath：当前基础路径。folder：子文件夹名字
 */
-(void)enumerateAudio:(NSString *)basePath folder:(NSString *)folder block:(void(^)(BOOL isFolder,NSString *basePath,NSString *folder))block;

/**
 根据扩展名，判断是不是音频文件

 @param extension 扩展名
 @return YES:音频文件
 */
-(BOOL)isAudioFile:(NSString *)extension;

/**
 是否是AVAudioPlayer支持的格式
 
 @param extension 格式
 @return YES：AVAudioPlayer支持的格式
 */
-(BOOL)isAVAudioPlayerMode:(NSString *)extension;



/**
 获取本地列表 在初始化播放列表之后，保存列表路径到本地，用于初始化程序的时候可以初始化列表

 @return 播放列表
 */
+ (NSMutableArray *)getPlayList;

/**
 保存播放列表到本地
 */
+ (void)savePlayList:(NSMutableArray *)list;

#pragma mark 获取音频文件的元数据 ID3
/**
 获取音频文件的元数据 ID3
 */
+(NSDictionary *)getID3:(NSString *)filePath;


+ (NSMutableArray *)getMusicList;

/**
 保存播放列表到本地
 */
+ (void)saveMusicList:(NSMutableArray *)list;


#pragma mark - 歌曲信息处理
/**
 传入歌曲的文件名字，分析歌名中包含的歌手（可能是多个）
 @param audioName 歌名
 @return 歌手数组
 */
+ (NSArray *)singersFromFileName:(NSString *)audioName;
/** 传入文件名，歌名处理，去除多于信息，保留干净的歌曲信息，格式：歌手 - 歌名 */
+(NSString *)musicNameFromFilename:(NSString *)filename;
/** 根据关键词，拆分字符串 */
+(NSString *)keyword:(NSString *)keyword separatkey:(NSString*)separatkey is0:(BOOL)is0;
@end

NS_ASSUME_NONNULL_END
