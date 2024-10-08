//
//  ZBMusicStatusControllerObject.m
//  ZBPlayer
//
//  Created by lzb on 2024/9/29.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import "ZBMusicStatusControllerObject.h"


@interface ZBMusicStatusControllerObject()

@property (nonatomic,copy) NSString *appVersionType;


@end


@implementation ZBMusicStatusControllerObject


-(NSString *)appVersionType{
    if (!_appVersionType) {
        //获取app的界面版本
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        _appVersionType = [user stringForKey:kDefaultAppViewVersionKey];
    }
    return _appVersionType;
}

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
                    [self getPlayIndexForRandom:treeModel];
                }else{
                    //返回播放上一首,新旧交换（此处只追溯到上一首歌曲，更早前的没有记录，如有需要，需要保存数据）
                    self.currentSection = lastS;
                    self.currentRow     = lastR;
                    self.lastSection = curS;
                    self.lastRow     = curR;
                }
            }else{
                if(isNext == YES){
                    //下一首歌
                    [self nextSongIndex:treeModel];
                    
                }else{
                    //上一首
                    [self lastSongIndex:treeModel];

                }
            }
            
            [self updateArtistIndex:treeModel];
            return YES;
        }
    }else{
        //没有歌曲，不播放
        return NO;
    }
}


/** 随机播放 下一首音轨随机计算*/
-(void)getPlayIndexForRandom:(TreeNodeModel *)treeModel{

    //1:减去播放历史的表，0：不需要减去
    u_int32_t cou = 1;
    if([self.appVersionType isEqualToString:@"2"]){
        cou = 0;//在没有额外添加播放历史的时候，如果-1，那么最后一组就会被忽略掉，所以是0
    }
    //判断当前section下方是否有子项数据列表，如果没有，重新获取section
    [self randomSectionCount:treeModel cou:cou];
}

//判断当前section下方是否有子项数据列表，如果没有，重新获取section
- (void)randomSectionCount:(TreeNodeModel *)treeModel cou:(u_int32_t)cou{
    //允许自动切换列表的时候才改变currentSection的值
    if(self.isPlayModelSwitchList == YES){
        u_int32_t sectionCount = (u_int32_t)treeModel.childNodes.count - cou;
        u_int32_t section = arc4random_uniform(sectionCount);
        self.currentSection = section;
    }
    u_int32_t childsCount = (u_int32_t)[[treeModel.childNodes[self.currentSection] childNodes] count];
    
    if(childsCount == 0){
        NSLog(@"数组越界了重新获取，%d,%ld",childsCount,self.currentSection);
        [self randomSectionCount:treeModel cou:cou];
    }else{
        u_int32_t row = arc4random_uniform(childsCount);
        self.currentRow = row;
    }
}

-(void)nextSongIndex:(TreeNodeModel *)treeModel{
    if(self.isPlayModelSwitchList == YES){
        //循序播放，如果播放的歌曲超出本表范围，自动切换到下一张列表
        if (self.currentRow + 1 >= [[treeModel.childNodes[self.currentSection] childNodes] count]) {
            //当前表是最后一张表
            if (self.currentSection + 1 >= treeModel.childNodes.count) {
                self.currentSection = 0;
                self.currentRow = 0;
            }else{
                
                self.currentSection = self.currentSection + 1;
                //判断下一张表里面是否有数据（可以播放的歌曲）
                if([[treeModel.childNodes[self.currentSection] childNodes] count] > 0){
                    self.currentRow = 0;
                }else{
                    NSLog(@"当前表是空的，切换到下一个表，%ld,%ld",[[treeModel.childNodes[self.currentSection] childNodes] count],self.currentSection);

                    [self nextSongIndex:treeModel];
                }
                
            }
            
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
}

-(void)lastSongIndex:(TreeNodeModel *)treeModel{
    
    if(self.isPlayModelSwitchList == YES){
        //如果是本表第一首歌
        if(self.currentRow - 1 < 0){
            //当前列表中的数据量
            NSInteger childsCount = [[treeModel.childNodes[self.currentSection] childNodes] count];
            //如果是第一张表
            if(self.currentSection - 1 < 0){
                //当前播放的是第一张列表第一首歌，再播放上一首歌，就是最后一张表的最后一首歌。
                self.currentSection = [treeModel.childNodes count] - 1;
                if(childsCount == 0){
                    [self lastSongIndex:treeModel];
                }else{
                    self.currentRow = childsCount - 1;
                }
            }else{
                //切换到上一张表，播放最后一首歌
                self.currentSection = self.currentSection - 1;
                if(childsCount == 0){
                    [self lastSongIndex:treeModel];
                }else{
                    self.currentRow = childsCount - 1;
                }
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

-(void)updateArtistIndex:(TreeNodeModel *)treeModel{
    ///根据row，也就是即将播放的歌曲所在列表的currentRow，找到其对应的歌手所在列表中artistSection 和 aristRow，而不是随机一个新的数据。定向滚动到指定位置。匹配歌手的位置
    if([self.appVersionType isEqualToString:@"2"] == YES){
        
        NSInteger foundIndex = NSNotFound;
        NSMutableArray *artists = [treeModel.childNodes[self.currentSection] artists];
        TreeNodeModel *curentModel = [treeModel.childNodes[self.currentSection] childNodes][self.currentRow];
        for(int i = 0 ; i < artists.count; i++){
            TreeNodeModel *tempModel = artists[i];
            if ([curentModel.name rangeOfString:tempModel.name].location != NSNotFound) {
                   foundIndex = i;
                   break;
               }
        }
        //随机播放或者其他播放模式时，都要自动、主动将当前歌曲所在的section，同步设置给歌手的section，原则上他们是一致的，但也有可能会因为用户随机点击其他列表。
        self.artistSection = self.currentSection;
        self.artistRow = foundIndex;
        
    }
}


@end
