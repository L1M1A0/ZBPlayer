//
//  ZBLyricObject.h
//  ZBPlayer
//
//  Created by Li28 on 2019/5/25.
//  Copyright © 2019 Li28. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBLyricObject : NSObject

/**
 查询歌曲，获取hash
 */
- (void)kugouApiSearchMusic:(NSString *)keyword;
- (void)kugouApiSearchKrc:(NSString *)hash;
/**
 查询歌曲，获取hash
 */
- (void)QQApiSearchMusic:(NSString *)keyword;
@end

NS_ASSUME_NONNULL_END
