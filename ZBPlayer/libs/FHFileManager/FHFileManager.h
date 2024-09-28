//
//  FHFileManager.h
//  FHFileManager
//
//  Created by Forr on 15/10/10.
//  Copyright (c) 2015年 Forr. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kPATH_DOCUMENT   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]

#define kPATH_LIBRARY    [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)objectAtIndex:0]

#define kPATH_TEMPORARY   NSTemporaryDirectory()

#define kPATH_CACHES    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0]

@interface FHFileManager : NSObject
#pragma mark -文件读写-
/**
 *  是否存在某个文件
 *
 *  @param filePath 文件路径，必须是根目录的路径
 *
 *  @return 文件是否存在
 */
+ (BOOL)isExisitFileAtPath:(NSString *)rootPath;

/**
 *  是否存在某个文件夹
 *
 *  @param directoryPath 文件夹路径，必须是根目录的路径
 *
 *  @return 文件夹是否存在
 */
+ (BOOL)isExisitFileGroupAtPath:(NSString *)rootPath;


/**
 *  创建文件夹，文件格存在先删除
 *
 *  @param rootPath 文件夹路径，必要是根目录的路径
 */
+ (BOOL)createFileGroupAtPath:(NSString *)rootPath;

/**
 *  创建支持带目录的文件,文件存在会覆盖
 *
 *  @param rootPath 文件夹路径，必要是根目录的路径
 *  @param fileName 文件名称,可以为nil
 *  @param type     (NSData<图片、文本、音频、视频>、NSArray、NSDictionary、NSString)class
 *  @param object   (NSData<图片、文本、音频、视频>、NSArray、NSDictionary、NSString)对象
 *
 *  @return 创建状态
 */
+ (BOOL)createFileAtPath:(NSString *)rootPath
                fileName:(NSString *)fileName
                   class:(Class)type
                 content:(id)object;

/**
 *  删除文件或文件夹，若文件存在
 *
 *  @param rootPath 文件夹路径，必要是根目录的路径
 *  @param fileName 文件名称,可以为nil
 *
 *  @return 删除状态
 */
+ (BOOL)deleteFileAtPath:(NSString *)rootPath
                fileName:(NSString *)fileName;

/**
 *  获取文件或文件夹信息,如文件大小。。。
 *
 *  @param rootPath 目标路径
 *  @param fileName 文件名
 *
 *  @return 文件字典信息
 */
+ (NSDictionary *)getFileAttributesAtPath:(NSString *)rootPath
                                 fileName:(NSString *)fileName;

/**
 *  访问目标文件的内容
 *
 *  @param rootPath 文件夹路径，必要是根目录的路径
 *  @param fileName 文件名称,不可以为nil
 *  @param type     目标对象类型(NSData<图片、文本、音频、视频>、NSArray、NSDictionary、NSString)
 *
 *  @return 目标对象(NSData<图片、文本>、NSArray、NSDictionary、NSString)
 */
+ (id)getContentWithFilePath:(NSString *)rootPath
                    fileName:(NSString *)fileName
                       class:(Class)type;
#pragma mark -归档-
/**
 *  对(NSData<图片、文本、音频、视频>、NSArray、NSDictionary、NSString)或model归档，model需要遵循NSCoding协议编码和解码方法
 *
 *  @param rootPath        文件夹路径，必要是根目录的路径
 *  @param fileName        文件名称,不可以为nil
 *  @param object          写入的内容，可以是model，也可装有model数组、字典
 *  @param encodeObjectKey 编码key
 */
+ (void)archiverAtPath:(NSString *)rootPath
              fileName:(NSString *)fileName
                object:(id)object
       encodeObjectKey:(NSString *)encodeObjectKey;

/**
 *  解档
 *
 *  @param rootPath        文件夹路径，必要是根目录的路径
 *  @param fileName        文件名称,不可以为nil
 *  @param encodeObjectKey 解码key
 *
 *  @return 目标对象,可以是(NSData<图片、文本、音频、视频>、NSArray、NSDictionary、NSString)或model
 */
+ (id)unarchiverAtPath:(NSString *)rootPath
              fileName:(NSString *)fileName
       encodeObjectKey:(NSString *)encodeObjectKey;




@end
