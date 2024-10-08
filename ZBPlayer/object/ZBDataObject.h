//
//  ZBDataObject.h
//  OSX
//
//  Created by Li28 on 2019/4/29.
//  Copyright © 2019 Li28. All rights reserved.
//



#import <Foundation/Foundation.h>
@class ZBAudioModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZBDataObject : NSObject


#pragma mark - 排序

/**
 排序
 
 @param array description
 @return 默认的是数字、英文、中文。
 */
- (NSMutableArray *)defaultSort:(NSMutableArray<ZBAudioModel*> *)array;

/**
 排序
 
 @param array description
 @return 指定地区信息的顺序是数字、中文、英文
 */
- (NSMutableArray *)sortZBAudioModelWithArray:(NSMutableArray<ZBAudioModel*> *)array;

/// 根据字符串数组，排序
/// @param array 字符串数据
-(NSMutableArray *)sortWithString:(NSMutableArray *)array;

#pragma mark - 时间计算

/**
 将标准时间如 04:50 转化 为秒 如 4*60+50 = 290秒
 */
-(float)timeToDuration:(NSString *)time;

/**
 将时间(单位：秒)转化为时分秒。如：115 -> 01:55
 */
-(NSString *)durationToTime:(float)duration;

/**
 对小与10的数字补 @"0"，如：3 -> 03
 */
-(NSString *)fill0:(int)number;


@end

NS_ASSUME_NONNULL_END
