//
//  ZBMusicStatusControllerObject.m
//  ZBPlayer
//
//  Created by lzb on 2024/9/29.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import "ZBMusicStatusControllerObject.h"

@implementation ZBMusicStatusControllerObject



/** 切歌  isNext：是否是下一首歌
 isStartPlay == YES，执行处理完逻辑之后，返回YES，开始播放
 */
- (BOOL)changeAudio:(BOOL)isNext dataSource:(TreeNodeModel *)treeModel{
    
    if (treeModel != nil && treeModel.childNodes.count > 0) {
        //记录上一次播放的位置
        NSInteger lastS = self.lastSection;
        NSInteger lastR = self.lastRow;
        NSInteger curS  = self.currentSection;
        NSInteger curR  = self.currentRow;
        
        //
        self.lastSection = curS;
        self.lastRow     = curR;
        
        if (self.isPlayModelSingleRepeat == YES) {
            //单曲循环，不切换音频索引
//            [self startPlaying];
            return  YES;
        }else{
            if (self.isPlayModelRandom == YES) {
            
                //随机播放，并判断是否需要切换列表
                if(isNext == YES){
                    //随机播放下一首
                    [self randomNumDataSource:treeModel];
                }else{
                    //返回播放上一首,新旧交换（此处只追溯到上一首歌曲，更早前的没有记录，如有需要，需要保存数据）
                    self.currentSection = lastS;
                    self.currentRow     = lastR;
                    self.lastSection = curS;
                    self.lastRow     = curR;
                }
                
            }else{
                //下一首歌
                if(isNext == YES){
                    if(self.isPlayModelSwitchList == YES){
                        //循序播放，如果播放的歌曲超出本表范围，自动切换到下一张列表
                        if (self.currentRow + 1 >= [[treeModel.childNodes[self.currentSection] childNodes] count]) {
                            if (self.currentSection + 1 >= treeModel.childNodes.count) {
                                self.currentSection = 0;
                            }else{
                                self.currentSection = self.currentSection + 1;
                            }
                            self.currentRow = 0;
                        }else{
                            //没有超越本表，自动播放下一首，不用切换列表
                            self.currentRow = self.currentRow + 1;
                        }
                    }else{
                        //不允许切换列表，self.currentSection 保持不变
                        //循序播放，播放完本表最后一首歌之后，下一首播放回本表第一首歌
                        if (self.currentRow + 1 >= [[treeModel.childNodes[self.currentSection] childNodes] count]) {
                            self.currentRow = 0;
                        }else{
                            self.currentRow = self.currentRow + 1;
                        }
                    }
                }else{
                    //上一首
                    
                    if(self.isPlayModelSwitchList == YES){
                        //如果是本表第一首歌
                        if(self.currentRow - 1 < 0){
                            //如果是第一张表
                            if(self.currentSection - 1 < 0){
                                //当前播放的是第一张列表第一首歌，没法再往前切换列表了。
                                self.currentSection = 0;
                                self.currentRow = 0;
                            }else{
                                //切换到上一张表，播放最后一首歌
                                self.currentSection = self.currentSection - 1;
                                self.currentRow = [[treeModel.childNodes[self.currentSection] childNodes] count] - 1;
                            }
                            
                            
                        }else{
                            //无需切换列表，本表内播放上一首歌
                            self.currentRow = self.currentRow - 1;
                        }
                        
                    }else{
                        //不允许切换列表，self.currentSection 保持不变
                        
                        if(self.currentRow - 1 >= 0){
                            self.currentRow = self.currentRow - 1;
                        }else{
                            self.currentRow = 0;
                        }
                    }
                   
                    
                  
                }
            }
//            [self startPlaying];
            return YES;
        }
    }else{
        //没有歌曲，不播放
        return NO;
    }
}


/** 随机播放 下一首音轨随机计算*/
-(void)randomNumDataSource:(TreeNodeModel *)treeModel{
    //允许自动切换列表的时候才改变currentSection的值
    if(self.isPlayModelSwitchList == YES){
        u_int32_t sectionCount = (u_int32_t)treeModel.childNodes.count - 1;//减去播放历史的表
        u_int32_t section = arc4random_uniform(sectionCount);
        self.currentSection = section;
    }
    u_int32_t childsCount = (u_int32_t)[[treeModel.childNodes[self.currentSection] childNodes] count];
    u_int32_t row = arc4random_uniform(childsCount);
    self.currentRow = row;
}



@end
