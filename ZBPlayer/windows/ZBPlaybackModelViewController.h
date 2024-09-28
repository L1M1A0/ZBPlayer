//
//  ZBPlaybackModelViewController.h
//  OSX
//
//  Created by Li28 on 2019/5/4.
//  Copyright © 2019 李振彪. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef NS_ENUM(NSInteger, ZBPlaybackModel) {
    ZBPlaybackModelRandom        = 0,//随机播放
    ZBPlaybackModelSequential    = 1,//循序播放
    ZBPlaybackModelSingleRepeat  = 2,//单曲循环
    
    ZBPlaybackModelCrossList     = 3,//允许跨列表播放
    ZBPlaybackModelUnCrossList   = 4,//不允许跨列表播放
};

NS_ASSUME_NONNULL_BEGIN

@interface ZBPlaybackModelViewController : NSViewController


/**
 是否跨列表
 */
//@property (nonatomic, assign) BOOL isCrossListModel;





@end

NS_ASSUME_NONNULL_END
