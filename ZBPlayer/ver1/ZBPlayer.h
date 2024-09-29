//
//  ZBPlayer.h
//  OSX
//
//  Created by Li28 on 2019/4/7.
//  Copyright © 2019 Li28. All rights reserved.
//
//*******播放器 版本1*********
/**
 * **********播放器版本说明***********
 *
 *1. 使用代码创建，VLCKit和系统API播放音频文件
 *2. 左侧，播放器列表结构与windows平台，老版酷狗播放器的列表一样，可以折叠的树形列表形态，可以展开和收起列表
 *3. 右侧，本来是计划展示歌词的，但是由于相关api不容易获取
 
 
 

 */




#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBPlayer : NSWindow


-(void)initWindow;
-(void)viewInWindow;

@end

NS_ASSUME_NONNULL_END
