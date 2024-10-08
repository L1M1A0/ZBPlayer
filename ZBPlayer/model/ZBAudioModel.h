//
//  ZBAudioModel.h
//  OSX
//
//  Created by Li28 on 2019/4/10.
//  Copyright © 2019 Li28. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBAudioModel : NSObject
/**
 音频文件名字
 */
@property (nonatomic, copy) NSString *title;

/**
 音频文件存储本地路径
 */
@property (nonatomic, copy) NSString *path;

/**
 音频文件扩展名（文件格式）
 */
@property (nonatomic, copy) NSString *extension;
/**
 音频文件 的艺术家（歌手、作者等创作者）
 */
@property (nonatomic, copy) NSString *artist;

@end

NS_ASSUME_NONNULL_END
