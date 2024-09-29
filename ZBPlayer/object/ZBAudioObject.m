//
//  ZBAudioObject.m
//  OSX
//
//  Created by Li28 on 2019/5/8.
//  Copyright © 2019 Li28. All rights reserved.
//

#import "ZBAudioObject.h"
#import "ZBAudioModel.h"
#import "FHFileManager.h"
#import <AVFoundation/AVFoundation.h>

#import "TreeNodeModel.h"


@implementation ZBAudioObject

-(NSMutableArray *)audios{
    if (!_audios) {
        _audios = [NSMutableArray array];
    }
    return _audios;
}



/**
 通过路径 获取本地音频文件（实现获取子文件中的文件）
 
 @param filePath 本地基础路径
 */
-(void)audioInPath:(NSString *)filePath{
    
    //Objective-C get list of files and subfolders in a directory 获取某路径下的所有文件，包括子文件夹中的所有文件https://stackoverflow.com/questions/19925276/objective-c-get-list-of-files-and-subfolders-in-a-directory
    //    NSString *sourcePath = self.localMusicBasePath.length == 0 ? @"/Volumes/mac biao/music/日系/" : [NSString stringWithFormat:@"%@/",self.localMusicBasePath];
    //遍历文件夹，包括子文件夹中的文件。直至遍历完所有文件。此处嵌套了10层，嵌套层级越深，获取的目录层级越深。
    [self enumerateAudio:filePath folder:@"" block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
        if (isFolder == YES) {
            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                if (isFolder == YES) {
                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                        if (isFolder == YES) {
                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                if (isFolder == YES) {
                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                        if (isFolder == YES) {
                                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                if (isFolder == YES) {
                                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                        if (isFolder == YES) {
                                                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                                if (isFolder == YES) {
                                                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                                        if (isFolder == YES) {
                                                                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                                                if (isFolder == YES) {
                                                                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
                                                                                        if (isFolder == YES) {
                                                                                            
                                                                                        }
                                                                                    }];
                                                                                }
                                                                            }];
                                                                        }
                                                                    }];
                                                                }
                                                            }];
                                                        }
                                                    }];
                                                }
                                            }];
                                        }
                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}


/**
 根据文件基础路径，遍历该路径下的文件
 
 @param basePath 基础路径
 @param folder  子文件夹名字，可以是空字符串：@"",
 @param block  isFolder：是否是文件夹。basePath：当前基础路径。folder：子文件夹名字
 */
-(void)enumerateAudio:(NSString *)basePath folder:(NSString *)folder block:(void (^)(BOOL, NSString * _Nonnull, NSString * _Nonnull))block{
    //Objective-C get list of files and subfolders in a directory 获取某路径下的所有文件，包括子文件夹中的所有文件https://stackoverflow.com/questions/19925276/objective-c-get-list-of-files-and-subfolders-in-a-directory
    
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    NSString *newPath = [NSString stringWithFormat:@"%@/%@",basePath,folder];
    NSError *error;
    NSArray  *newDirs = [fileManager contentsOfDirectoryAtPath:newPath error:&error];
    NSLog(@"遍历：error：%@",error);
    __weak ZBAudioObject * weakSelf = self;
    [newDirs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *extension = [[filename pathExtension] lowercaseString];//文件格式
        if ([weakSelf isAudioFile:extension]  == YES) {
            
            //路径解码比较耗时间
            NSString *filePath = [newPath stringByAppendingPathComponent:filename];
            if([filePath containsString:@"file://"]){
                //去除file://
                filePath = [filePath substringFromIndex:7];
            }
            //url编码 解码路劲（重要）
            filePath = [filePath stringByRemovingPercentEncoding];
            
            NSLog(@"正在导入：%@",filename);
            ZBAudioModel *model = [[ZBAudioModel alloc]init];
            model.title = filename;
            model.path = filePath;
            model.extension = extension;
            //拼接路径
            [weakSelf.audios addObject:model];
        }else if(extension.length == 0){
            //如果是文件夹，那就继续遍历子文件夹中的
            block(YES,newPath,obj);
        }
    }];
}

/**
 根据扩展名，判断是不是音频文件
 
 @param extension 扩展名
 @return YES:音频文件
 */
-(BOOL)isAudioFile:(NSString *)extension{
    //@[@"mp3",@"flac",@"wav",@"aac",@"m4a",@"wma",@"ape",@"ogg",@"alac"]
    if ([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"flac"] ||//AVAudioPlayer
        [extension isEqualToString:@"wav"] || [extension isEqualToString:@"aac"] ||
        [extension isEqualToString:@"m4a"] ||
        [extension isEqualToString:@"wma"] || [extension isEqualToString:@"ape"] ||//VLCKit
        [extension isEqualToString:@"ogg"] || [extension isEqualToString:@"tta"] ||
        [extension isEqualToString:@"alac"]) {
        return YES;
    }else{
        return NO;
    }
}


/**
 是否是AVAudioPlayer支持的格式

 @param extension 格式
 @return YES：AVAudioPlayer支持的格式
 */
-(BOOL)isAVAudioPlayerMode:(NSString *)extension{
    if ([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"flac"] ||
        [extension isEqualToString:@"wav"] || [extension isEqualToString:@"aac"] ||
        [extension isEqualToString:@"m4a"] ) {
        return YES;
    }else{
        return NO;
    }
}

/**
 获取本地列表 在初始化播放列表之后，保存列表路径到本地，用于初始化程序的时候可以初始化列表
 
 @return 播放列表
 */
+ (NSMutableArray *)getPlayList {
    return [FHFileManager unarchiverAtPath:kPATH_DOCUMENT fileName:@"ZBAudioList" encodeObjectKey:@"ZBAudioListKey"];
}

/**
 保存播放列表到本地
 */
+ (void)savePlayList:(NSMutableArray *)list {
    [FHFileManager archiverAtPath:kPATH_DOCUMENT fileName:@"ZBAudioList" object:list encodeObjectKey:@"ZBAudioListKey"];
}

+ (NSMutableArray *)getMusicList {
    
    
    NSMutableArray *list = [FHFileManager unarchiverAtPath:kPATH_DOCUMENT fileName:@"ZBMusicList" encodeObjectKey:@"ZBMusicListKey"];
    NSMutableArray *mainList = [NSMutableArray array];
    for (int i = 0; i < list.count; i++) {
        NSDictionary *mainDic = list[i];
        TreeNodeModel *mainNode = [[TreeNodeModel alloc]init];

        NSMutableArray *childNodes = [NSMutableArray array];
        for (int j = 0; j < [mainDic[@"childNodes"] count]; j++) {
            
            NSDictionary *childDic = mainDic[@"childNodes"][j];
            TreeNodeModel *childNode = [[TreeNodeModel alloc]init];

            ZBAudioModel *childAudio = [[ZBAudioModel alloc]init];
            childAudio.title = childDic[@"audio"][@"title"];
            childAudio.path = childDic[@"audio"][@"path"];
            childAudio.extension = childDic[@"audio"][@"extension"];

            childNode.audio = childAudio;;
            childNode.name = childDic[@"name"];
            childNode.childNodes = childDic[@"childNodes"];//
            childNode.isExpand = [childDic[@"isExpand"] boolValue];
            childNode.nodeLevel = [childDic[@"nodeLevel"] integerValue];//当前层级
            childNode.superLevel = [childDic[@"superLevel"] integerValue];//父层级
            childNode.sectionIndex = [childDic[@"sectionIndex"] integerValue];
            childNode.rowIndex = [childDic[@"rowIndex"] integerValue];

            [childNodes addObject:childNode];
          }
        
        ZBAudioModel *mainAudio = [[ZBAudioModel alloc]init];
        mainAudio.title = mainDic[@"audio"][@"title"];
        mainAudio.path = mainDic[@"audio"][@"path"];
        mainAudio.extension = mainDic[@"audio"][@"extension"];
        
        mainNode.audio = mainAudio;;
        mainNode.name = mainDic[@"name"];
        mainNode.childNodes = childNodes;//
        mainNode.isExpand = [mainDic[@"isExpand"] boolValue];
        mainNode.nodeLevel = [mainDic[@"nodeLevel"] integerValue];//当前层级
        mainNode.superLevel = [mainDic[@"superLevel"] integerValue];//父层级
        mainNode.sectionIndex = [mainDic[@"sectionIndex"] integerValue];
        mainNode.rowIndex = [mainDic[@"rowIndex"] integerValue];

        [mainList addObject:mainNode];

    }
    
    
    return mainList;
}



/**
 保存播放列表到本地
 */
+ (void)saveMusicList:(NSMutableArray *)list {
    
    //直接保存模型会报错，所以转换成基本数组模型
    NSMutableArray *mainList = [NSMutableArray array];
    for (int i = 0; i < list.count ; i++) {
        TreeNodeModel *mainNode = list[i];

        NSMutableArray *childs = [NSMutableArray array];
        for (int j = 0; j < mainNode.childNodes.count ; j++) {
            TreeNodeModel *childNode = mainNode.childNodes[j];
            NSDictionary *childAudio = @{@"title":@"",@"path":@"",@"extension":@""};;
            if (childNode.audio) {
                childAudio = @{@"title":childNode.audio.title,@"path":childNode.audio.path == nil ? @"" : childNode.audio.path,@"extension":childNode.audio.extension};
            }
            NSDictionary * childDic = @{@"audio":childAudio,@"name":childNode.name,
                                        @"isExpand":@(childNode.isExpand),@"nodeLevel":@(childNode.nodeLevel),
                                        @"superLevel":@(childNode.superLevel),@"sectionIndex":@(childNode.sectionIndex),
                                        @"rowIndex":@(childNode.rowIndex),@"childNodes":childNode.childNodes};
            [childs addObject:childDic];
            
        }
        
        NSDictionary *audio = @{@"title":@"",@"path":@"",@"extension":@""};;
        if (mainNode.audio) {
            audio = @{@"title":mainNode.audio.title,@"path":mainNode.audio.path == nil ? @"" : mainNode.audio.path,@"extension":mainNode.audio.extension};
        }
        NSDictionary *dic = @{@"audio":audio,@"name":mainNode.name,
                              @"isExpand":@(mainNode.isExpand),@"nodeLevel":@(mainNode.nodeLevel),
                              @"superLevel":@(mainNode.superLevel),@"sectionIndex":@(mainNode.sectionIndex),
                              @"rowIndex":@(mainNode.rowIndex),@"childNodes":childs};
        
        [mainList addObject:dic];
        
    }

    [FHFileManager archiverAtPath:kPATH_DOCUMENT fileName:@"ZBMusicList" object:mainList encodeObjectKey:@"ZBMusicListKey"];
}




#pragma mark 获取音频文件的元数据 ID3
/**
 获取音频文件的元数据 ID3
 */
+(NSDictionary *)getID3:(NSString *)filePath{
    //    filePath = [[NSBundle mainBundle]pathForResource:@"松本晃彦 - 栄の活躍" ofType:@"mp3"];//[self.wMp3URL objectAtIndex: 0 ];//随便取一个，说明
    //文件管理，取得文件属性
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *dictAtt = [fm attributesOfItemAtPath:filePath error:nil];
    
    
    //取得音频数据
    NSURL *fileURL=[NSURL fileURLWithPath:filePath];
    AVURLAsset *mp3Asset=[AVURLAsset URLAssetWithURL:fileURL options:nil];
    
    NSString *singer;//歌手
    NSString *song;//歌曲名
    //    NSImage *songImage;//图片
    NSString *albumName;//专辑名
    NSString *fileSize;//文件大小
    NSString *quality;//音质类型
    NSString *fileStyle;//文件类型
    NSString *creatDate;//创建日期
    NSString *savePath; //存储路径
    
    NSString *dur = @"";
    for (NSString *format in [mp3Asset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [mp3Asset metadataForFormat:format]) {
            if([metadataItem.commonKey isEqualToString:@"title"]){
                song = (NSString *)metadataItem.value;//歌曲名
            }else if ([metadataItem.commonKey isEqualToString:@"artist"]){
                singer = [NSString stringWithFormat:@"%@",metadataItem.value];//歌手
            } else if ([metadataItem.commonKey isEqualToString:@"albumName"]) {
                albumName = (NSString *)metadataItem.value;
            }else if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                //                NSDictionary *dict=(NSDictionary *)metadataItem.value;
                //                NSData *data=[dict objectForKey:@"data"];
                //                image=[NSImage imageWithData:data];//图片
            }
            dur = [NSString stringWithFormat:@"%d",metadataItem.duration.timescale];
        }
    }
    savePath = filePath;
    float tempFlo = [[dictAtt objectForKey:@"NSFileSize"] floatValue]/(1024*1024);
    fileSize = [NSString stringWithFormat:@"%.2fMB",[[dictAtt objectForKey:@"NSFileSize"] floatValue]/(1024*1024)];
    NSString *tempStrr  = [NSString stringWithFormat:@"%@", [dictAtt objectForKey:@"NSFileCreationDate"]] ;
    creatDate = [tempStrr substringToIndex:19];
    fileStyle = [filePath substringFromIndex:[filePath length]-3];
    if(tempFlo <= 2){
        quality = @"普通";
    }else if(tempFlo > 2 && tempFlo <= 5){
        quality = @"良好";
    }else if(tempFlo > 5 && tempFlo < 10){
        quality = @"标准";
    }else if(tempFlo > 10){
        quality = @"高清";
    }
    
    //    NSArray *tempArr = [[NSArray alloc] initWithObjects:@"歌手:",@"歌曲名称:",@"专辑名称:",@"文件大小:",@"音质类型:",@"文件格式:",@"创建日期:",@"保存路径:", nil];
    //    NSArray *tempArrInfo = [[NSArray alloc] initWithObjects:singer,song,albumName,fileSize,quality,fileStyle,creatDate,savePath, nil];
    
    NSDictionary *dic =@{@"singer":[self checkNil:singer],
                         @"song":[self checkNil:song],
                         @"album":[self checkNil:albumName],
                         @"size":[self checkNil:fileSize],
                         @"quality":[self checkNil:quality],
                         @"extension":[self checkNil:fileStyle],
                         @"creatDate":[self checkNil:creatDate],
                         @"path":[self checkNil:savePath],
                         @"duration":[self checkNil:dur]};
//    NSLog(@"音频文件信息：%@",dic);
    return dic;
}

+(NSString *)checkNil:(NSString *)key{
    if(!key){
        key = @"";
    }
    return key;
}


#pragma mark - 歌曲信息处理
/**
 分析歌名中的歌手
 @param audioName 歌名
 @return 歌手数组
 */
+ (NSArray *)singersFromFileName:(NSString *)audioName{
    
    NSMutableArray *singles = [NSMutableArray array];
    //前半段
    NSArray *arr1 = [audioName componentsSeparatedByString:@" -"];
    if(arr1.count == 1){
        arr1 = [audioName componentsSeparatedByString:@"-"];
    }
    NSString *name = arr1.count > 1 ? arr1[0] : audioName;
    [singles addObject:name];
    
    
    //附加歌名
    NSArray *arr2 = [audioName componentsSeparatedByString:@"- "];
    NSString *title = arr2.count > 1 ? arr2[1] : audioName;
    NSString *key = [title substringToIndex:title.length - 4];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"." withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"：" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@":" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"、" withString:@"&"];
    key = [key stringByReplacingOccurrencesOfString:@"（" withString:@"&"];
    key = [key stringByReplacingOccurrencesOfString:@"[" withString:@"&"];
    key = [key stringByReplacingOccurrencesOfString:@"【" withString:@"&"];
    key = [key stringByReplacingOccurrencesOfString:@")" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"）" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"]" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"】" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"(by" withString:@"&by"];


    //冴えない彼女-2C112- DOUBLE RAINBOW DREAMS（by：澤村・スペンサー・英梨々&大西沙織&霞ヶ丘詩羽&茅野愛衣.mp3
    NSInteger oldL = key.length;
    key = [self keyword:key separatkey:@"&by" is0:NO];
    key = [key localizedLowercaseString];
    key = [key stringByReplacingOccurrencesOfString:@"cv" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"(" withString:@"&"];

    if([key containsString:@"&"]){//多个歌手
        NSArray *mults = [key componentsSeparatedByString:@"&"];
        [singles addObjectsFromArray:mults];
    }else if (oldL > key.length){
        [singles addObject:key];
    }
    
    //去除重复
    NSArray *result = [singles valueForKeyPath:@"@distinctUnionOfObjects.self"];
    NSMutableArray *lastArr = [NSMutableArray array];
    for (int i = 0; i < result.count; i++) {
        if(![result[i] isEqualToString:@""] || [result[i] length] > 0){
            [lastArr addObject:result[i]];
        }
    }
    return [lastArr mutableCopy];
}
/** 歌名处理 */
+(NSString *)musicNameFromFilename:(NSString *)filename{
    NSArray *arr1 = [filename componentsSeparatedByString:@" -"];
    if(arr1.count == 1){
        arr1 = [filename componentsSeparatedByString:@"-"];
    }
    NSArray *arr2 = [filename componentsSeparatedByString:@"- "];
    NSString *name = arr1.count > 1 ? arr1[0] : filename;
    NSString *title = arr2.count > 1 ? arr2[1] : filename;
    NSString *key = @"";
    if (arr1.count < 2  || arr2.count < 2 ) {
        key = filename;
    }else{
        key = [NSString stringWithFormat:@"%@ - %@",name,title];
    }
    key = [key substringToIndex:key.length - 4];
    NSString *point = [key substringFromIndex:key.length-1];
    key = [point isEqualToString:@"."] ? [key substringToIndex:key.length - 1] : key;
    key = [key stringByReplacingOccurrencesOfString:@"（" withString:@"("];
    key = [key stringByReplacingOccurrencesOfString:@"[" withString:@"("];
    key = [key stringByReplacingOccurrencesOfString:@"【" withString:@"("];
//    __weak __typeof(self) weakSelf = self;
    key = [self keyword:key separatkey:@"(by"  is0:YES];
    return key;
}

/** 去除歌名后半段的 注释关键词，返回歌名 */
+(NSString *)keyword:(NSString *)keyword separatkey:(NSString*)separatkey is0:(BOOL)is0{
    keyword = [keyword localizedLowercaseString];
    if([keyword containsString:separatkey]){
        if(is0 == YES){
            return  [keyword componentsSeparatedByString:separatkey][0];
        }else{
            return  [keyword componentsSeparatedByString:separatkey][1];
        }
    }else{
        return keyword;
    }
}


@end
