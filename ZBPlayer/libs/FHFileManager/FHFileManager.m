//
//  FHFileManager.m
//  FHFileManager
//
//  Created by Forr on 15/10/10.
//  Copyright (c) 2015年 Forr. All rights reserved.
//

#import "FHFileManager.h"

@implementation FHFileManager
#pragma mark -文件读写-
/**
 *  是否存在某个文件
 *
 *  @param filePath 文件路径，必须是根目录的路径
 *
 *  @return 文件是否存在
 */
+ (BOOL)isExisitFileAtPath:(NSString *)rootPath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:rootPath];
}

/**
 *  是否存在某个文件夹
 *
 *  @param directoryPath 文件夹路径，必须是根目录的路径
 *
 *  @return 文件夹是否存在
 */
+ (BOOL)isExisitFileGroupAtPath:(NSString *)rootPath
{
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:rootPath
                                             isDirectory:&isDirectory])
    {
        isDirectory = YES;
    }
    return isDirectory;
}

/**
 *  创建文件，文件存在先删除
 *
 *  @param rootPath 文件路径，必要是根目录的路径
 */
+ (BOOL)createFileAtPath:(NSString *)rootPath
                contents:(NSData *)contents
{
    BOOL success = NO;
    [FHFileManager deleteFileAtPath:rootPath fileName:nil];
    success = [[NSFileManager defaultManager] createFileAtPath:rootPath
                                                      contents:contents
                                                    attributes:nil];
    if (success==NO)
    {
        NSLog(@"创建文件失败，file path = %@",rootPath);
    }
    return success;
}

/**
 *  创建文件夹，文件夹存在先删除
 *
 *  @param rootPath 文件夹路径，必要是根目录的路径
 */
+ (BOOL)createFileGroupAtPath:(NSString *)rootPath
{
    BOOL success = NO;
    [FHFileManager deleteFileAtPath:rootPath fileName:nil];
    NSError *error;
    
    success = [[NSFileManager defaultManager] createDirectoryAtPath:rootPath
                                        withIntermediateDirectories:YES
                                                         attributes:nil
                                                              error:&error];
    if (error)
    {
        NSLog(@"创建文件夹失败，file path = %@,error:%@",rootPath,error.description);
    }
    return success;
}

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
{
    BOOL success = NO;
    if (rootPath && rootPath.length>0)
    {
        rootPath = [rootPath stringByAppendingPathComponent:fileName];
        if ([FHFileManager isExisitFileAtPath:rootPath])
        {
            NSError *error;
            success = [[NSFileManager defaultManager] removeItemAtPath:rootPath
                                                                 error:&error];
            if (error)
            {
                NSLog(@"删除文件失败，file path = %@,error:%@",rootPath,error.description);
            }
            
        }
    }
    return success;
}


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
                 content:(id)object
{
    BOOL success = NO;
    if (rootPath && rootPath.length>0)
    {
        if (![FHFileManager isExisitFileGroupAtPath:rootPath]) {
            [FHFileManager createFileGroupAtPath:rootPath];
        }
        if (fileName && fileName.length>0)
        {
            rootPath = [rootPath stringByAppendingPathComponent:fileName];
            if (object && type)
            {
                //支持office文件、pdf、rar、zip、apk、ipa、plist等等
                if (type==[NSData class]) {
                    NSData *data = (NSData *)object;
                    success = [data writeToFile:rootPath atomically:YES];
                }else if (type==[NSDictionary class]){
                    NSDictionary *dictionary = (NSDictionary *)object;
                    success = [dictionary writeToFile:rootPath atomically:YES];
                }else if (type==[NSArray class]){
                    NSArray *array = (NSArray *)object;
                    success = [array writeToFile:rootPath atomically:YES];
                }else if (type==[NSString class]){
                    NSString *text = (NSString *)object;
                    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
                    success = [FHFileManager createFileAtPath:rootPath contents:data];
                }
            }
            else//空文件
            {
                success = [FHFileManager createFileAtPath:rootPath contents:nil];
            }
        }
    }
    return success;
}

/**
 *  获取文件或文件夹信息
 *
 *  @param rootPath 目标路径
 *  @param fileName 文件名
 *
 *  @return 文件字典信息
 */
+ (NSDictionary *)getFileAttributesAtPath:(NSString *)rootPath
                                 fileName:(NSString *)fileName
{
    if (rootPath && rootPath.length>0)
    {
        if (fileName==nil)
        {
            NSDirectoryEnumerator *directoryEnumer = [[NSFileManager defaultManager] enumeratorAtPath:rootPath];
            return [directoryEnumer directoryAttributes];
        }
        else
        {
            rootPath = [rootPath stringByAppendingPathComponent:fileName];
            NSError *error = nil;
            return [[NSFileManager defaultManager] attributesOfItemAtPath:rootPath error:&error];
        }
    }
    NSLog(@"获取文件信息失败！你访问的文件不存在，file path = %@",rootPath);
    return nil;
}

/**
 *  访问目标文件的内容
 *
 *  @param rootPath 文件夹路径，必要是根目录的路径
 *  @param fileName 文件名称,不可以为nil
 *  @param type     (NSData<图片、文本、音频、视频>、NSArray、NSDictionary、NSString)class
 *
 *  @return (NSData<图片、文本、音频、视频>、NSArray、NSDictionary、NSString)对象
 */
+ (id)getContentWithFilePath:(NSString *)rootPath
                    fileName:(NSString *)fileName
                       class:(Class)type;
{
    if (rootPath && rootPath.length>0 &&
        fileName && fileName.length>0)
    {
        NSError *error;
        rootPath = [rootPath stringByAppendingPathComponent:fileName];
        if (type==[NSString class]){
            return [NSString stringWithContentsOfFile:rootPath
                                             encoding:NSUTF8StringEncoding
                                                error:&error];
        }else if (type==[NSDictionary class]){
            return [NSDictionary dictionaryWithContentsOfFile:rootPath];
        }else if (type==[NSArray class]){
            return [NSArray arrayWithContentsOfFile:rootPath];
        }else if (type==[NSData class]){
            return [NSData dataWithContentsOfFile:rootPath];
        }
    }
    NSLog(@"解析内容失败，file path = %@",rootPath);
    return nil;
}

#pragma mark -归档-
/**
 *  对(NSData<图片、文本、音频、视频>、NSArray、NSDictionary、NSString)或model归档，model需要遵循NSCoding协议编码和解码方法
 *
 *  @param rootPath        文件夹路径，必要是根目录的路径
 *  @param fileName        文件名称,不可以为nil
 *  @param object          可以是model，也可装有model数组、字典
 *  @param encodeObjectKey 编码key
 */
+ (void)archiverAtPath:(NSString *)rootPath
              fileName:(NSString *)fileName
                object:(id)object
       encodeObjectKey:(NSString *)encodeObjectKey
{
    if (rootPath==nil || rootPath.length==0 ||
        fileName==nil || fileName.length==0)
    {
        NSLog(@"归档失败！你访问的文件不存在, file path = %@",[rootPath stringByAppendingPathComponent:fileName]);
        return;
    }
    if (![FHFileManager isExisitFileGroupAtPath:rootPath]) {
        [FHFileManager createFileGroupAtPath:rootPath];
    }
    rootPath = [rootPath stringByAppendingPathComponent:fileName];
    NSMutableData *mData = [NSMutableData new];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:mData];
    [archiver encodeObject:object forKey:encodeObjectKey];
    [archiver finishEncoding];
    [mData writeToFile:rootPath atomically:YES];
}
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
       encodeObjectKey:(NSString *)encodeObjectKey
{
    if (rootPath==nil || rootPath.length==0 ||
        fileName==nil || fileName.length==0)
    {
        NSLog(@"解档失败！你访问的文件不存在, file path = %@",[rootPath stringByAppendingPathComponent:fileName]);
        return nil;
    }
    rootPath = [rootPath stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:rootPath];
    NSKeyedUnarchiver *unarcher = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    id object = [unarcher decodeObjectForKey:encodeObjectKey];
    [unarcher finishDecoding];
    return object;
}




@end
