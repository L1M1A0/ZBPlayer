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
#import "ZBDataObject.h"



//数据库，保存了“被选中的文件夹的对应的基础地址”，存到本地,通过下方的key获取。
#define kAudioFolderBasePathList    @"ZBAudioFolderBasePathList"
#define kAudioFolderBasePathListKEY @"ZBAudioFolderBasePathListKEY"
//数据库，保存了整理后的歌曲文件的数据源列表，存到本地,通过下方的key获取。
#define kAudioFileDataList      @"ZBAudioFileDataList"
#define kAudioFileDataListKEY   @"ZBAudioFileDataListKEY"
//支持读取的音频格式
#define kAudioExtensions @[@"mp3",@"flac",@"wav",@"aac",@"m4a",@"wma",@"ape",@"ogg",@"alac"]

@interface ZBAudioObject ()
/**
 遍历之后获得的文件数组，数据使用之后，要将数组中的数据清除，否则会占用大量内存，因为数据量很大。
 */
@property (nonatomic, strong) NSMutableArray *audios;
@property (nonatomic, strong) NSMutableArray *artistsInList;

@end

@implementation ZBAudioObject

-(NSMutableArray *)audios{
    if (!_audios) {
        _audios = [NSMutableArray array];
    }
    return _audios;
}
-(NSMutableArray *)artistsInList{
    if (!_artistsInList) {
        _artistsInList = [NSMutableArray array];
    }
    return _artistsInList;
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


/// 根据传入的字符串，使用key分隔成数组，返回前部分，最后如果有多的，用空格拼接成新的字符串
/// @param string 传入的字符串
/// @param separatedkey 分隔符
-(NSString *)artistNameInString:(NSString *)string separatedkey:(NSString *)separatedkey{
    
    NSMutableArray *fileNameCuts = [NSMutableArray arrayWithArray:[string componentsSeparatedByString:separatedkey]];//一般歌手与歌名是格式是 “歌手 - 歌名”、也有些是 “歌手-歌名”,为了兼顾这两种情况，所以分开剪切
    
    for(int i = 0;i<fileNameCuts.count; i++){
        if([fileNameCuts[i] isEqualToString:@""]){
            [fileNameCuts removeObjectAtIndex:i];
        }
    }
    
    NSString *artist = fileNameCuts[0];//artists.count > 1 ? [artists firstObject] : artists[0];//不管怎么分，第一个肯定是歌曲的歌手
    if(fileNameCuts.count > 1){
        //比如外国歌手的名字：shari kara tiaff - song name。其名字包含字符比较多，可能有较多间隔，所以移除空空格之后，还要将中间的重新拼接
        artist =[fileNameCuts componentsJoinedByString:@" "];
    }
    return artist;
}

#pragma mark 获取音频文件的元数据 ID3
/**
 获取音频文件的元数据 ID3
 */
+(NSDictionary *)getAudioFileID3:(NSString *)filePath{
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
    savePath = filePath;//[filePath stringByRemovingPercentEncoding];
    fileSize = [NSString stringWithFormat:@"%.2fMB",[[dictAtt objectForKey:@"NSFileSize"] floatValue]/(1024*1024)];
    fileStyle = [filePath pathExtension];//[filePath substringFromIndex:[filePath length]-3];
    NSString *tempStrr  = [NSString stringWithFormat:@"%@", [dictAtt objectForKey:@"NSFileCreationDate"]] ;
    creatDate = [tempStrr substringToIndex:19];
   
 
    
    //    NSArray *tempArr = [[NSArray alloc] initWithObjects:@"歌手:",@"歌曲名称:",@"专辑名称:",@"文件大小:",@"音质类型:",@"文件格式:",@"创建日期:",@"保存路径:", nil];
    //    NSArray *tempArrInfo = [[NSArray alloc] initWithObjects:singer,song,albumName,fileSize,quality,fileStyle,creatDate,savePath, nil];
    
    NSDictionary *dic =@{@"singer":[self checkNil:singer],
                         @"song":[self checkNil:song],
                         @"album":[self checkNil:albumName],
                         @"size":[self checkNil:fileSize],
                         @"extension":[self checkNil:fileStyle],
//                         @"creatDate":[self checkNil:creatDate],
                         @"path":[self checkNil:savePath],
//                         @"duration":[self checkNil:dur]
                         
    };
//    NSLog(@"音频文件信息：%@",dic);
    return dic;
}

+(NSString *)checkNil:(NSString *)key{
    if(!key){
        key = @"";
    }
    return key;
}

#pragma mark 判断是不是音频文件

/**
 根据文件名，判断是不是音频文件
 
 @param filename 文件名
 
 @return YES:音频文件
 */
-(BOOL)isAudioFile:(NSString *)filename{
    
    //这种方法不准确
//    if ([extension isEqualToString:@"mp3"] || [extension isEqualToString:@"flac"] ||//AVAudioPlayer
//        [extension isEqualToString:@"wav"] || [extension isEqualToString:@"aac"] ||
//        [extension isEqualToString:@"m4a"] ||
//        [extension isEqualToString:@"wma"] || [extension isEqualToString:@"ape"] ||//VLCKit
//        [extension isEqualToString:@"ogg"] || [extension isEqualToString:@"tta"] ||
//        [extension isEqualToString:@"alac"]) {
//        return YES;
//    }else{
//
//        return NO;
//    }
    
    /**
     这种遍历方式是挨个文件读取文件名，因为读取的是文件名（包括文件夹的名字），所以容易出错。（此处问题已经解决）

    注意：此方法判断容易出问题：如以歌手名字命名的文件夹名字中，有些歌手的名字中包含小数点”.“文件会以此判断格式类型，此时会出现判断格式错误，如作曲家 S.E.N.S 会判断当前格式为“s”，再如歌手[.que]会被判断格式为'que]'。
    再或者，只要文件夹名字出现小数点，都有可能会被判定为其他格式的文件，而不会认为是文件夹
    从而，遍历器就会误判其是一个文件，而跳过该文件夹，去执行扫描下个一个文件，导致前者里面的文件无法扫描到，造成遗漏。
     */
//    NSString *extension = [[filename pathExtension] lowercaseString];//文件格式
    
    // 搜索音频文件的扩展名数组
    NSArray *audioExtensions = kAudioExtensions;
    NSString *extension = [filename pathExtension];

    // 检查文件扩展名是否在音频文件扩展名数组中
    if ([audioExtensions containsObject:extension]) {
        return YES;
    }else {
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



#pragma mark - 读取文件夹 数据源整理 主管方法
/**
 传入路径数组（文件夹数组），分别读取本地路径下的文件

 @param paths 传入路径数组（文件夹数组），分别读取本地路径下的文件
 */
+(TreeNodeModel *)searchFilesInFolderPaths:(NSMutableArray *)paths{
    //保存选中文件列表
    [self saveFolderPathList:paths];
    
    //基础路径 数组
    NSMutableArray *baseUrls = [NSMutableArray array];
    //列表名字 数组
    NSMutableArray *sectionTitles = [NSMutableArray array];
    for(NSURL *url in paths) {
        
        //处理文件夹路径为统一的编码格式。
        //NSString *string = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        NSString *filePath = [[NSString stringWithFormat:@"%@",url] stringByRemovingPercentEncoding];
        
        //将文件夹的详细路径拆分为 路径 和 文件夹的名字 等两个数组
        NSArray *ar = [filePath componentsSeparatedByString:@"/"];
        if([ar.lastObject isEqualToString:@""]){
            NSLog(@"读取文件夹：%@，filePath：%@",ar[ar.count - 2],filePath);
            [baseUrls addObject:url.path];
            [sectionTitles addObject:ar[ar.count-2]];
        }
    }
    
    //初始化数据源，将拿到的初始数据二次加工，生成符合页面展示要求的数据结构模型。
    TreeNodeModel *treeModel = [[TreeNodeModel alloc]init];//处理后，拥有准确结构的数据
    ZBDataObject *dataObject = [[ZBDataObject alloc]init];//
    //NSString *sourcePath = self.localMusicBasePath.length == 0 ? @"/Volumes/mac biao/music/日系/" : [NSString stringWithFormat:@"%@/",self.localMusicBasePath];
    
    //通过路径列表，遍历出符合要求的音频初始数据（非正式的数据源，需要二次加工成符合需要的结构）
    NSMutableArray *localMusics = [NSMutableArray array];
    NSMutableArray *artists= [NSMutableArray array];
    for (int i = 0; i < sectionTitles.count; i++) {
        NSMutableArray *arr = [NSMutableArray array];
        NSMutableArray *arr2 = [NSMutableArray array];
        [localMusics addObject:arr];
        [artists addObject:arr2];
        //查询文件夹下方的歌曲文件，更新列表
        ZBAudioObject *ado = [[ZBAudioObject alloc]init];
        if([kDefaultAPPViewVersion isEqualToString:@"1"]){
            //数据源获取方式1：block回调方式：手动回调（递归的思路，但不完全是递归，比较被动）
            [ado blockSearchInPath:baseUrls[i]];
            [localMusics[i] addObjectsFromArray:ado.audios];
        }else{
            //数据获取方式2：
            [ado findAudiosInPath: baseUrls[i] sectionTitle:sectionTitles[i] countIndex:i];
            [localMusics[i] addObjectsFromArray:ado.audios];
            [artists[i] addObjectsFromArray:ado.artistsInList[0]];
//            [localMusics addObject:treeModel];
        }
        

    }
    
  
    
    //事实上，我们对数据进行了两次以上处理了。一次是在初始化数据的时候，一次是排序、一次是完善结构的时候，所以，应该尽量少重复做处理，
    if([kDefaultAPPViewVersion isEqualToString:@"1"]){
        //构建版本1的数据结构 两层级结构的数据 单列表展开，如酷狗
        for(int i = 0; i< localMusics.count; i++){
            //原始的，没有经过排序的数据源
            NSMutableArray *audios = localMusics[i];
            //列表排序
            NSMutableArray *sortAudios = [dataObject sortZBAudioModelWithArray:audios];
            
            //根节点
            TreeNodeModel *rootNode1 = [self node:[NSString stringWithFormat:@"%@ [%ld]",sectionTitles[i],audios.count] level:0 superLevel:-1];
            rootNode1.sectionIndex = -1;//根节点没有sectionIndex
            rootNode1.rowIndex = i;
            
            //次级节点 排序后的数据源
            for(int j = 0; j < [sortAudios count]; j++){
                ZBAudioModel *audio = sortAudios[j];
                TreeNodeModel *childNode = [self node:audio.title level:1 superLevel:0];
                childNode.audio = audio;
                childNode.sectionIndex = i;
                childNode.rowIndex     = j;
                [rootNode1.childNodes addObject:childNode];
            }
            [treeModel.childNodes addObjectsFromArray:@[rootNode1]];
        }
        //播放历史的数据源，此时只有表名，还没有数据
        TreeNodeModel *history   = [self node:@"播放历史" level:0 superLevel:-1];
        history.sectionIndex = -1;//根节点没有sectionIndex
        history.rowIndex     = localMusics.count;
        [treeModel.childNodes addObject:history];
        
    }else{
        //构建版本1的数据结构 两层级结构的数据 左右分屏展示
        for(int i = 0; i< localMusics.count; i++){
            //原始的，没有经过排序的数据源
            NSMutableArray *audios = localMusics[i];
            //列表排序()
            NSMutableArray *sortAudios = [dataObject sortZBAudioModelWithArray:audios];
            NSMutableArray *artistNames = [dataObject sortWithString:artists[i]];
            

            //根节点
            TreeNodeModel *rootNode1 = [self node:[NSString stringWithFormat:@"%@ [%ld]",sectionTitles[i],audios.count] level:0 superLevel:-1];
            rootNode1.sectionIndex = -1;//根节点没有sectionIndex
            rootNode1.rowIndex = i;
            
//            [rootNode1.artists addObjectsFromArray:artistNames];
//            NSLog(@"___%@",artists[i])
            //次级节点 排序后的歌手列表 数据源
            for(int j = 0; j < [artistNames count]; j++){
//                ZBAudioModel *audio = sortAudios[j];
                TreeNodeModel *childNode = [self node:artistNames[j] level:1 superLevel:0];
//                childNode.audio = audio;
                childNode.sectionIndex = i;
                childNode.rowIndex     = j;
                [rootNode1.artists addObject:childNode];
            }
           
            //次级节点 排序后的歌曲列表 数据源
            for(int j = 0; j < [sortAudios count]; j++){
                ZBAudioModel *audio = sortAudios[j];
                TreeNodeModel *childNode = [self node:audio.title level:1 superLevel:0];
                childNode.audio = audio;
                childNode.sectionIndex = i;
                childNode.rowIndex     = j;
                [rootNode1.childNodes addObject:childNode];
            }
           
            [treeModel.childNodes addObjectsFromArray:@[rootNode1]];
        }
 
        
    }
 
//    [self.audioListOutlineView reloadData];

    [ZBAudioObject saveMusicList:treeModel.childNodes];
    return treeModel;

}

#pragma mark - 获取当前文件及其子目录下的所有文件
#pragma mark 方法1：block回调，递归式查询
/**
 通过路径 获取本地音频文件（实现获取子文件中的文件）
 第1步：创建block回调方法
 
 注：这个方法不太好（应该有系统替代的方法，要去了解文件系统管理相关的API）
 
 思路：1. 先找出文件
 
 @param filePath 本地基础路径
 */
-(void)blockSearchInPath:(NSString *)filePath{
    
    //Objective-C get list of files and subfolders in a directory 获取某路径下的所有文件，包括子文件夹中的所有文件https://stackoverflow.com/questions/19925276/objective-c-get-list-of-files-and-subfolders-in-a-directory
    //    NSString *sourcePath = self.localMusicBasePath.length == 0 ? @"/Volumes/mac biao/music/日系/" : [NSString stringWithFormat:@"%@/",self.localMusicBasePath];
    //遍历文件夹，包括子文件夹中的文件。直至遍历完所有文件。此处嵌套了10层，嵌套层级越深，获取的目录层级越深。
//    NSLog(@"第1圈：%@",filePath);
    [self enumerateAudio:filePath folder:@"" block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//        NSLog(@"第2圈：%@/%@",basePath,folder);
        if (isFolder == YES) {
            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                NSLog(@"第3圈：%@/%@",basePath,folder);
                if (isFolder == YES) {
                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                        NSLog(@"第4圈：%@/%@",basePath,folder);
                        if (isFolder == YES) {
                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                                NSLog(@"第5圈：%@/%@",basePath,folder);
                                if (isFolder == YES) {
                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                                        NSLog(@"第6圈：%@/%@",basePath,folder);
                                        if (isFolder == YES) {
                                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                                                NSLog(@"第6圈：%@/%@",basePath,folder);
                                                if (isFolder == YES) {
                                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                                                        NSLog(@"第8圈：%@/%@",basePath,folder);
                                                        if (isFolder == YES) {
                                                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                                                                NSLog(@"第9圈：%@/%@",basePath,folder);
                                                                if (isFolder == YES) {
                                                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                                                                        NSLog(@"第10圈：%@/%@",basePath,folder);
                                                                        if (isFolder == YES) {
                                                                            [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                                                                                NSLog(@"第11圈：%@/%@",basePath,folder);
                                                                                if (isFolder == YES) {
                                                                                    [self enumerateAudio:basePath folder:folder block:^(BOOL isFolder, NSString *basePath, NSString *folder) {
//                                                                                        NSLog(@"第12圈：%@/%@",basePath,folder);
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
 通过路径 获取本地音频文件（实现获取子文件中的文件）
 第2步：根据文件基础路径，遍历该路径下的文件，真正的遍历查询方法
 
 注：（应该有系统替代的方法，要去了解文件系统管理相关的API）
 
 @param basePath 基础路径
 @param folder  子文件夹名字，可以是空字符串：@"",
 @param block  isFolder：是否是文件夹。basePath：当前基础路径。folder：子文件夹名字
 */
-(void)enumerateAudio:(NSString *)basePath folder:(NSString *)folder block:(void (^)(BOOL, NSString * _Nonnull, NSString * _Nonnull))block{
    //Objective-C get list of files and subfolders in a directory 获取某路径下的所有文件，包括子文件夹中的所有文件https://stackoverflow.com/questions/19925276/objective-c-get-list-of-files-and-subfolders-in-a-directory
    
    NSFileManager *fileManager = [NSFileManager defaultManager] ;
    NSString *newPath = [NSString stringWithFormat:@"%@/%@",basePath,folder];
    newPath = [newPath stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
 
    //获取文件夹下的所有文件（包含子文件夹）
    NSError *error1;
    //获取当前文件夹目录下的文件和文件夹，不包含子文件夹目录下的所有文件)，但是用下方的遍历方法不会重复导入。返回的每个文件信息都不包含路径信息。
    NSArray *dirsNoSub = [fileManager contentsOfDirectoryAtPath:newPath error:&error1];
    if(error1){
        NSLog(@"遍历文件 ：error1：%@",error1);
    }
//    for(int i = 0;i<dirsNoSub.count;i++){
//        NSLog(@"遍历dirsNoSub：文件：___%ld___%@",[dirsNoSub count],[dirsNoSub[i] stringByRemovingPercentEncoding]);
//    }
    
//    NSError *error2;
//    //获取当前文件夹目录以及其子文件目录下的所有文件和文件夹（隐藏的也能读取）(可能是由于block递归查询回调的关系，会重复查询，所以此处不用这种方式)
//    NSArray  *newDirs2 = [fileManager subpathsOfDirectoryAtPath:newPath error:&error2];
//    NSLog(@"遍历：error2：%@",error2);
//    for(int i = 0;i<newDirs2.count;i++){
//        NSLog(@"遍历newDirs2：文件：___%ld___%@",[newDirs2 count],[newDirs2[i] stringByRemovingPercentEncoding]);
//    }
//
 
    __weak ZBAudioObject * weakSelf = self;
    //只包含文件，不包含路径信息
    [dirsNoSub enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
//        NSLog(@"遍历1：当前文件及其子文件路径下的所有文件的路径：%@",[filename stringByRemovingPercentEncoding]);
        
        NSString *fileExtension = [filename pathExtension];
        
        //找出音频文件
        if ([weakSelf isAudioFile:filename]  == YES) {
            //路径解码比较耗时间
            NSString *filePath = [newPath stringByAppendingPathComponent:filename];
            if([filePath containsString:@"file://"]){
                //去除file://
                filePath = [filePath substringFromIndex:7];
            }
            //url编码 解码路劲（重要）
            filePath = [filePath stringByRemovingPercentEncoding];
            
//            NSLog(@"正在导入：%@",filename);
            //临时保存所有的数据列表，后续需要用来进一步加工，非正式的数据源
            ZBAudioModel *model = [[ZBAudioModel alloc]init];
            model.title = filename;
            model.path = filePath;
            model.extension = fileExtension;
            //拼接路径
            [weakSelf.audios addObject:model];
        }else {
            //如果是文件夹或者其他类型的文件，那就继续遍历子文件夹中的
            block(YES,newPath,obj);
//            NSLog(@"正在导入其他格式的文件：%@___%@",filename,fileExtension);
        }
    }];
}

#pragma mark 方法2：简易式查询（最推荐使用此方法，文件遍历更加完整，没遗漏）

/**
 
 被选中的文件夹的路径作为基础路径，由此搜索该文件夹及其子目录下的所有符合条件的数据
 
 */
/// @param basePath 被选中的文件夹的路径作为基础路径
-(void)findAudiosInPath:(NSString *)basePath sectionTitle:(NSString *)sectionTitle countIndex:(int)countIndex{


    // 获取当前文件夹路径
//    NSString *currentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    // 创建NSFileManager实例
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 搜索音频文件的扩展名数组
//    NSArray *audioExtensions = kAudioExtensions;

    // 创建NSDirectoryEnumerator实例，此方法如果判断为文件夹路径，会自动进入子目录进行遍历。
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:basePath];

    NSMutableArray *audioFiles = [NSMutableArray array];
    NSMutableArray *sectionList = [NSMutableArray array];//存根节点的列表数据
    NSMutableDictionary *artistMap = [NSMutableDictionary dictionary];
    
    // 遍历文件夹及其子目录下的所有文件
    for (NSString *filePath in enumerator) {
        NSLog(@"遍历：当前文件及其子文件路径下的所有文件的路径：%@",[filePath stringByRemovingPercentEncoding]);

        
        NSString *fileExtension = [filePath pathExtension];

        // 检查文件扩展名是否在音频文件扩展名数组中
        if ([kAudioExtensions containsObject:fileExtension]) {
            NSLog(@"遍历：筛选格式后符合要求的文件路径：%@",[filePath stringByRemovingPercentEncoding]);
            /*
             读取到的文件格式如下：
             1. 直接保存在当前文件夹下的文件：周杰伦 - 屋顶（feat.温岚）.mp3,
             2. 保存在当前文件夹的 子目录文件夹下：吉田潔/吉田潔 - はるかな旅.mp3,
             3. 保存在当前文件夹的 子目录文件夹下的 子目录文件夹下：吉田潔/大鱼海棠OST/吉田潔 -01- 椿的梦 序曲.mp3,
             */
            NSString *dirFilePath = [NSString stringWithFormat:@"%@/%@",basePath,filePath];
//            [audioFiles addObject:dirFilePath];//对应第一种排列方式

            //对应第二种排序方式
            //如果子目录下包含”/“符号，说明是路径，因为windows系统的文件名字规则中不允许使用这个符号。
            NSArray *filePathCuts = [filePath componentsSeparatedByString:@"/"];
            NSString *audionName = filePathCuts.count > 1 ? [filePathCuts lastObject] : filePathCuts[0];

            //提取歌手名字，作为key，相同歌手的作品归为一个数组，通过歌手名字作为key获取对应的数组（搜索查询所有时，会否增加搜索计算复杂？）
            NSString *fileName = [filePath lastPathComponent];//获取文件路径种，最后的地址，最后的一般是文件本身，除非是空文件夹，与 NSArray *fileNameCuts = [filePath componentsSeparatedByString:@"/"]; 是一样的
            
            //从文件名中提取歌手，一般以“-”作为歌手与歌曲信息的分隔符。格式如 “歌手 - 歌名”、 “歌手-歌名”,为了兼顾这两种情况，所以分开剪切。如果歌手名字中包含“-”，如：X-ray dog，这就麻烦了。无法兼顾
            NSArray *fileNameCuts = [fileName componentsSeparatedByString:@"-"];//
            //比如外国歌手的名字：shari kara tiaff - song name。其名字包含字符比较多，可能有较多间隔，所以移除空空格之后，还要将中间的重新拼接
            NSString *artist = [self artistNameInString:fileNameCuts[0] separatedkey:@" "];
            
        
            // 将相同歌手的音频文件归类到一起，保存其文件路径，并添加到对应的键值对中
            NSMutableArray *sameArtistDatas = artistMap[artist];
            if (!sameArtistDatas) {
                sameArtistDatas = [NSMutableArray array];
                artistMap[artist] = sameArtistDatas;
            }
            
            ZBAudioModel *model = [[ZBAudioModel alloc]init];
            model.title = audionName;//音频文件的名字（不包含路径信息）
            model.path = dirFilePath;//音频文件的详细地址
            model.extension = fileExtension;//文件的格式类型
            model.artist = artist;
            
            [sameArtistDatas addObject:model];
            [sectionList addObject:model];

            //拼接路径
            [self.audios addObject:model];
        }
    }

//
//    //将歌手名字设置为独立的数据源（有必要这么设置吗？）
//    // 获取所有文件名中前两个字相同的文件，分类生成数组
    NSMutableArray *keys = [NSMutableArray array];
    for (NSString *key in artistMap) {
        NSLog(@"以 %@ 开头的文件：", key);
        [keys addObject:key];
        for (ZBAudioModel *model in artistMap[key]) {
            NSLog(@"%@", model.path);
        }
    }
    [self.artistsInList addObject:keys];


}

/// 设置TreeNodeModel的节点信息
/// @param text 节点名字
/// @param level 当前节点的层级
/// @param superLevel 父级节点的层级
+(TreeNodeModel *)node:(NSString *)text level:(NSInteger)level superLevel:(NSInteger)superLevel{
    TreeNodeModel *nod = [[TreeNodeModel alloc]init];
    nod.name = text;
    nod.isExpand = NO;
    nod.isSelected = YES;//默认YES，所有列表都可以播放
    nod.nodeLevel = level;
    nod.superLevel = superLevel;
    return nod;
}

#pragma mark - 数据本地化

/**
 获取本地文件夹路径列表 在初始化播放列表之后，保存列表路径到本地，用于初始化程序的时候可以初始化列表
 
 @return 播放列表
 */
+ (NSMutableArray *)getFolderPathList {
    return [FHFileManager unarchiverAtPath:kPATH_DOCUMENT fileName:kAudioFolderBasePathList encodeObjectKey:kAudioFolderBasePathListKEY];
}

/**
 保存被选中的文件夹的路径列表到本地
 */
+ (void)saveFolderPathList:(NSMutableArray *)folderPathList {
    [FHFileManager archiverAtPath:kPATH_DOCUMENT fileName:kAudioFolderBasePathList object:folderPathList encodeObjectKey:kAudioFolderBasePathListKEY];
}


/**
 保存播放列表到本地
 */
+ (void)saveMusicList:(NSMutableArray *)list {
    
    //直接保存模型会报错，所以转换成基本数组模型
    NSMutableArray *mainList = [NSMutableArray array];
    for (int i = 0; i < list.count ; i++) {
        TreeNodeModel *mainNode = list[i];

        
        //歌手列表
        NSMutableArray *artists = [NSMutableArray array];
        for (int j = 0; j < mainNode.artists.count ; j++) {
            TreeNodeModel *childNode = mainNode.artists[j];//歌手名字模型
//            NSDictionary *childAudio = @{@"title":@"",@"path":@"",@"extension":@""};;
//            if (childNode.audio) {
//                childAudio = @{@"title":childNode.audio.title,@"path":childNode.audio.path == nil ? @"" : childNode.audio.path,@"extension":childNode.audio.extension};
//            }
            NSDictionary * childDic = @{@"name":childNode.name,@"isExpand":@(childNode.isExpand),
                                        @"nodeLevel":@(childNode.nodeLevel),@"superLevel":@(childNode.superLevel),
                                        @"sectionIndex":@(childNode.sectionIndex),@"rowIndex":@(childNode.rowIndex),
                                        @"artists":childNode.childNodes};
            [artists addObject:childDic];
            
        }
        
        
        
        //歌曲列表
        NSMutableArray *childs = [NSMutableArray array];
        for (int j = 0; j < mainNode.childNodes.count ; j++) {
            TreeNodeModel *childNode = mainNode.childNodes[j];
            NSDictionary *childAudio = @{@"title":@"",@"path":@"",@"extension":@""};;
            if (childNode.audio) {
                childAudio = @{@"title":childNode.audio.title,@"path":childNode.audio.path == nil ? @"" : childNode.audio.path,@"extension":childNode.audio.extension};
            }
            NSDictionary * childDic = @{@"audio":childAudio,@"name":childNode.name,@"isExpand":@(childNode.isExpand),
                                        @"nodeLevel":@(childNode.nodeLevel), @"superLevel":@(childNode.superLevel),
                                        @"sectionIndex":@(childNode.sectionIndex), @"rowIndex":@(childNode.rowIndex),
                                        @"childNodes":childNode.childNodes};
            [childs addObject:childDic];
            
        }

        NSDictionary *audio = @{@"title":@"",@"path":@"",@"extension":@""};;
        if (mainNode.audio) {
            audio = @{@"title":mainNode.audio.title,@"path":mainNode.audio.path == nil ? @"" : mainNode.audio.path,@"extension":mainNode.audio.extension};
        }
        NSDictionary *dic = @{@"audio":audio,@"name":mainNode.name,
                              @"isSelected":@(mainNode.isSelected),@"isExpand":@(mainNode.isExpand),
                              @"nodeLevel":@(mainNode.nodeLevel), @"superLevel":@(mainNode.superLevel),
                              @"sectionIndex":@(mainNode.sectionIndex), @"rowIndex":@(mainNode.rowIndex),
                              @"childNodes":childs,@"artists":artists};
            
        [mainList addObject:dic];
      

        
    }

    [FHFileManager archiverAtPath:kPATH_DOCUMENT fileName:kAudioFileDataList object:mainList encodeObjectKey:kAudioFileDataListKEY];
}



/**
 读取上一次保存在本地的歌曲列表
 */
+ (NSMutableArray *)getMusicList {
    
    
    NSMutableArray *list = [FHFileManager unarchiverAtPath:kPATH_DOCUMENT fileName:kAudioFileDataList encodeObjectKey:kAudioFileDataListKEY];
    NSMutableArray *mainList = [NSMutableArray array];
    for (int i = 0; i < list.count; i++) {
        NSDictionary *mainDic = list[i];
        TreeNodeModel *mainNode = [[TreeNodeModel alloc]init];
        // 如果选中的列表中包含歌曲，则加入播放列表，没有歌曲，就不加入列表。
//        if([mainDic[@"childNodes"] count] > 0){
        
        
        NSMutableArray *artist = [NSMutableArray array];
        for (int j = 0; j < [mainDic[@"artists"] count]; j++) {
        
            NSDictionary *childDic = mainDic[@"artists"][j];
            TreeNodeModel *childNode = [[TreeNodeModel alloc]init];

//            ZBAudioModel *childAudio = [[ZBAudioModel alloc]init];
//            childAudio.title = childDic[@"audio"][@"title"];
//            childAudio.path = childDic[@"audio"][@"path"];
//            childAudio.extension = childDic[@"audio"][@"extension"];

//            childNode.audio = childAudio;;
            childNode.name = childDic[@"name"];
            childNode.artists = childDic[@"artists"];
//            childNode.childNodes = childDic[@"childNodes"];//
//            childNode.isSelected = [childDic[@"isSelected"] boolValue];
            childNode.isExpand = [childDic[@"isExpand"] boolValue];
            childNode.nodeLevel = [childDic[@"nodeLevel"] integerValue];//当前层级
            childNode.superLevel = [childDic[@"superLevel"] integerValue];//父层级
            childNode.sectionIndex = [childDic[@"sectionIndex"] integerValue];
            childNode.rowIndex = [childDic[@"rowIndex"] integerValue];

            [artist addObject:childNode];
        }
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
//                childNode.artists = childDic[@"artists"];
                childNode.childNodes = childDic[@"childNodes"];//
                childNode.isExpand = [childDic[@"isExpand"] boolValue];
//                childNode.isSelected = [childDic[@"isSelected"] boolValue];
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
            mainNode.artists = artist;
            mainNode.childNodes = childNodes;//
            mainNode.isSelected = [mainDic[@"isSelected"] boolValue];
            mainNode.isExpand = [mainDic[@"isExpand"] boolValue];
            mainNode.nodeLevel = [mainDic[@"nodeLevel"] integerValue];//当前层级
            mainNode.superLevel = [mainDic[@"superLevel"] integerValue];//父层级
            mainNode.sectionIndex = [mainDic[@"sectionIndex"] integerValue];
            mainNode.rowIndex = [mainDic[@"rowIndex"] integerValue];

            [mainList addObject:mainNode];
                 
//        }
    

    }
    
    
    return mainList;
}










@end
