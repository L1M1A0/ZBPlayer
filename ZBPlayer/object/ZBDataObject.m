//
//  ZBDataObject.m
//  OSX
//
//  Created by Li28 on 2019/4/29.
//  Copyright © 2019 Li28. All rights reserved.
//

#import "ZBDataObject.h"
#import "ZBAudioModel.h"

@implementation ZBDataObject





#pragma mark - 排序

/**
 排序
 
 @param array description
 @return 默认的是数字、英文、中文。
 */
- (NSMutableArray *)defaultSort:(NSMutableArray<ZBAudioModel*> *)array
{
    
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        ZBAudioModel *mod1 = (ZBAudioModel *)obj1;
        ZBAudioModel *mod2 = (ZBAudioModel *)obj2;
        return [mod1.title compare:mod2.title options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch|NSWidthInsensitiveSearch|NSForcedOrderingSearch];
    }];
    NSLog(@"after %@ , result is %@",NSStringFromSelector(_cmd),sortedArray);
    return [sortedArray mutableCopy];
}

/**
 排序
 
 @param array description
 @return 指定地区信息的顺序是数字、中文、英文
 */
- (NSMutableArray *)localSort:(NSMutableArray<ZBAudioModel*> *)array
{
    
    //        NSCaseInsensitiveSearch = 1,    //不区分大小写比较
    //        NSLiteralSearch = 2,    //逐字节比较 区分大小写
    //        NSBackwardsSearch = 4,    //从字符串末尾开始搜索
    //        NSAnchoredSearch = 8,    //搜索限制范围的字符串
    //        NSNumericSearch = 64,    //按照字符串里的数字为依据，算出顺序。例如 Foo2.txt < Foo7.txt < Foo25.txt
    //        NSDiacriticInsensitiveSearch NS_ENUM_AVAILABLE(10_5, 2_0) = 128,//忽略 "-" 符号的比较
    //        NSWidthInsensitiveSearch NS_ENUM_AVAILABLE(10_5, 2_0) = 256,//忽略字符串的长度，比较出结果
    //        NSForcedOrderingSearch NS_ENUM_AVAILABLE(10_5, 2_0) = 512,//忽略不区分大小写比较的选项，并强制返回 NSOrderedAscending 或者 NSOrderedDescending
    //        NSRegularExpressionSearch NS_ENUM_AVAILABLE(10_7, 3_2) = 1024   //只能应用于 rangeOfString:..., stringByReplacingOccurrencesOfString:...和 replaceOccurrencesOfString:... 方法。使用通用兼容的比较方法，如果设置此项，可以去掉 NSCaseInsensitiveSearch 和 NSAnchoredSearch
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSArray *sortedArray = [array sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
        ZBAudioModel *mod1 = (ZBAudioModel *)obj1;
        ZBAudioModel *mod2 = (ZBAudioModel *)obj2;
        NSRange string1Range = NSMakeRange(0, [mod1.title length]);
        return [mod1.title compare:mod2.title options:NSForcedOrderingSearch range:string1Range locale:locale];
    }];
    //    NSLog(@"after %@ , result is %@",NSStringFromSelector(_cmd),sortedArray);
    return [sortedArray mutableCopy];
}



#pragma mark - 时间计算



/**
 将标准时间如 04:50 转化 为秒 如 4*60+50 = 290秒

 @param time <#time description#>
 @return <#return value description#>
 */
-(float)timeToDuration:(NSString *)time{
    NSArray *arr = [time componentsSeparatedByString:@":"];
    double  duration  = 0;
    if (arr.count == 2) {
        duration = [arr[0] doubleValue] * 60 + [arr[1] doubleValue];
    }else if (arr.count == 3){
        duration = [arr[0] doubleValue] * 60 * 60 + [arr[1] doubleValue] * 60 + [arr[2] doubleValue];
    }else{
        //正常情况下不会出现这样的情况
        duration = [arr[0] doubleValue];
    }
    return duration;
}

/**
 将时间(单位：秒)转化为时分秒。如：115 -> 01:55
 */
-(NSString *)durationToTime:(float)duration{
    int h = duration/60/60;//时
    int m = (int)(duration/60)%60;//分,可能有问题 (duration/60)%60
    int s = (int)duration % 60;//n秒
    NSString *time = [NSString stringWithFormat:@"%@ : %@",[self fill0:m],[self fill0:s]];
    if (h > 0) {
        time = [NSString stringWithFormat:@"%@ : %@",[self fill0:h],time];
    }
    return time;
}

/**
 对小与10的数字补 @"0"，如：3 -> 03
 */
-(NSString *)fill0:(int)number{
    if (number < 10) {
        return [NSString stringWithFormat:@"0%d",number];
    }else{
        return [NSString stringWithFormat:@"%d",number];
    }
}


@end
