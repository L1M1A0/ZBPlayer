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

@class TreeNodeModel;





NS_ASSUME_NONNULL_BEGIN

@interface ZBAudioObject : NSObject






#pragma mark - 歌曲信息处理
/**
 分析歌名中的歌手
 @param audioName 歌名
 @return 歌手数组
 */
+(NSArray *)singersFromFileName:(NSString *)audioName;
/** 歌名处理 */
+(NSString *)musicNameFromFilename:(NSString *)filename;
/** 去除歌名后半段的 注释关键词，返回歌名 */
+(NSString *)keyword:(NSString *)keyword separatkey:(NSString*)separatkey is0:(BOOL)is0;

/// 根据传入的字符串，使用key分隔成数组，返回前部分，最后如果有多的，用空格拼接成新的字符串
/// @param string 传入的字符串
/// @param separatedkey 分隔符
-(NSString *)artistNameInString:(NSString *)string separatedkey:(NSString *)separatedkey;
#pragma mark 获取音频文件的元数据 ID3
/**
 获取音频文件的元数据 ID3
 */
+(NSDictionary *)getAudioFileID3:(NSString *)filePath;
+(NSString *)checkNil:(NSString *)key;

#pragma mark 判断是不是音频文件

/**
 根据扩展名，判断是不是音频文件
 
 @param filename 文件名
 @return YES:音频文件
 */
-(BOOL)isAudioFile:(NSString *)filename;

/**
 是否是AVAudioPlayer支持的格式

 @param extension 格式
 @return YES：AVAudioPlayer支持的格式
 */
-(BOOL)isAVAudioPlayerMode:(NSString *)extension;



#pragma mark - 读取文件夹、获取本地文件列表
/**
 传入路径数组（文件夹数组），分别读取本地路径下的文件

 @param paths 传入路径数组（文件夹数组），分别读取本地路径下的文件
 */
+(TreeNodeModel *)searchFilesInFolderPaths:(NSMutableArray *)paths;

/**
 通过路径 获取本地音频文件（实现获取子文件中的文件）
 第1步：创建block回调方法
 
 注：这个方法不太好（应该有系统替代的方法，要去了解文件系统管理相关的API）
 
 @param filePath 本地基础路径
 */
-(void)blockSearchInPath:(NSString *)filePath;

/**
 通过路径 获取本地音频文件（实现获取子文件中的文件）
 第2步：根据文件基础路径，遍历该路径下的文件，真正的遍历查询方法
 
 注：（应该有系统替代的方法，要去了解文件系统管理相关的API）
 
 @param basePath 基础路径
 @param folder  子文件夹名字，可以是空字符串：@"",
 @param block  isFolder：是否是文件夹。basePath：当前基础路径。folder：子文件夹名字
 */
-(void)enumerateAudio:(NSString *)basePath folder:(NSString *)folder block:(void (^)(BOOL, NSString * _Nonnull, NSString * _Nonnull))block;

/**
 
 被选中的文件夹的路径作为基础路径，由此搜索该文件夹及其子目录下的所有符合条件的数据
 
 */
/// @param basePath 被选中的文件夹的路径作为基础路径
-(void)findAudiosInPath:(NSString *)basePath sectionTitle:(NSString *)sectionTitle countIndex:(int)countIndex;

/// 设置TreeNodeModel的节点信息
/// @param text 节点名字
/// @param level 当前节点的层级
/// @param superLevel 父级节点的层级
+(TreeNodeModel *)node:(NSString *)text level:(NSInteger)level superLevel:(NSInteger)superLevel;


#pragma mark - 数据本地化

/**
 获取本地文件夹路径列表 在初始化播放列表之后，保存列表路径到本地，用于初始化程序的时候可以初始化列表
 
 @return 播放列表
 */
+ (NSMutableArray *)getFolderPathList;
/**
 保存被选中的文件夹的路径列表到本地
 */
+ (void)saveFolderPathList:(NSMutableArray *)folderPathList;

/**
 保存播放列表到本地
 */
+ (void)saveMusicList:(NSMutableArray *)list;

/**
 读取上一次保存在本地的歌曲列表
 */
+ (NSMutableArray *)getMusicList;

@end

NS_ASSUME_NONNULL_END
