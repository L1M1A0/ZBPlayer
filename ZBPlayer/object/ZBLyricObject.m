//
//  ZBLyricObject.m
//  ZBPlayer
//
//  Created by Li28 on 2019/5/25.
//  Copyright © 2019 Li28. All rights reserved.
//

#import "ZBLyricObject.h"
#import "AFNetworking.h"
#import "ZBAudioObject.h"

@implementation ZBLyricObject



#pragma mark - 歌词
/**
 查询歌曲，获取hash
 */
- (void)kugouApiSearchMusic:(NSString *)keyword{
    keyword = [ZBAudioObject musicNameFromFilename:keyword];
    AFHTTPSessionManager *ma = [AFHTTPSessionManager manager];
    ma.requestSerializer = [AFJSONRequestSerializer serializer];
    ma.responseSerializer = [AFJSONResponseSerializer serializer];
    ma.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *url = [NSString stringWithFormat:@"http://mobilecdn.kugou.com/api/v3/search/song?format=json&keyword=%@&page=1&pagesize=20&showtype=1",keyword];

    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    __weak ZBLyricObject * weakSelf = self;
    [ma GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"kugouApiSearchMusicSuccess：%@",responseObject);
        NSArray *ar = responseObject[@"data"][@"info"];
        if (ar.count > 0) {
            [weakSelf kugouApiSearchKrc:ar[0][@"hash"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"kugouApiSearchMusicError：%@",error);
    }];
}

//success:(nullable void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success

- (void)kugouApiSearchKrc:(NSString *)hash{
    AFHTTPSessionManager *ma = [AFHTTPSessionManager manager];
    ma.requestSerializer = [AFJSONRequestSerializer serializer];
    ma.responseSerializer = [AFJSONResponseSerializer serializer];
    ma.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
//    http://www.kugou.com/yy/index.php?r=play/getdata&hash=67f4b520ee80d68959f4bf8a213f6774
    NSString *url = [NSString stringWithFormat:@"http://www.kugou.com/yy/index.php?r=play/getdata&hash=%@",hash];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    __block NSDictionary *dic = @{};
    __block NSString *str1 = @"";
    __weak ZBLyricObject * weakSelf = self;
    [ma GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"kugouApiSearchKrcSuccess：%@",responseObject);
//        if([responseObject[@"data"] count]>0){
//            str1 = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"lyrics"]];
//        }else{
//            NSString *d = [NSString stringWithFormat:@"currentSection：%ld，lastSection：%ld,currentRow：%ld,lastRow：%ld",self.musicStatusCtrl.currentSection,self.musicStatusCtrl.lastSection,self.musicStatusCtrl.currentRow,self.musicStatusCtrl.lastRow];
//            str = [NSString stringWithFormat:@"歌词下载失败：err_code: %ld\n%@",[responseObject[@"err_code"] integerValue],d];
//        }
//        dic = @{
//            @"str": str1,
//            @"responseObject":responseObject,
//            @"error":@{}
//        };
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"kugouApiSearchKrcError：%@",error);
//        dic = @{
//            @"str": @"",
//            @"responseObject":@"",
//            @"error":error
//        };
    }];
}


/**
 查询歌曲，获取hash
 */
- (void)QQApiSearchMusic:(NSString *)keyword{
    
    NSArray *singers = [ZBAudioObject singersFromFileName:keyword];
    keyword = [ZBAudioObject musicNameFromFilename:keyword];
    
    AFHTTPSessionManager *ma = [AFHTTPSessionManager manager];
    ma.requestSerializer = [AFJSONRequestSerializer serializer];
    ma.responseSerializer = [AFJSONResponseSerializer serializer];
    ma.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString *url = [NSString stringWithFormat:@"https://api.bzqll.com/music/tencent/search?key=579621905&s=%@&limit=100&offset=0&type=lrc",keyword];
    
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    __block NSString *str1 = @"";
    __weak ZBLyricObject * weakSelf = self;
    [ma GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"QQApiSearchMusic：%@",responseObject);
//        NSArray *ar = responseObject[@"data"];
//
//        //对比失误率较高，应该允许选择
//        NSString *songName = [keyword componentsSeparatedByString:@"- "][1];
//        NSMutableArray *arr = [NSMutableArray array];
//        for (int i = 0; i < ar.count; i++){
//            NSDictionary *dic = ar[i];
//            NSArray *dicSingers = dic[@"singer"];
//            BOOL isSameSinger   = NO;
//            for (int j = 0; j < dicSingers.count; j++) {
//                NSDictionary *dicj = dicSingers[j];
//                NSString *js = [NSString stringWithFormat:@"%@",dicj[@"name"]];
//                for (int k = 0; k < singers.count; k++) {
//                    NSString *ks = [NSString stringWithFormat:@"%@",singers[k]];
//                    if ([ks isEqualToString:js]) {
//                        isSameSinger = YES;
//                    }
//                }
//            }
//
//            NSString *dicSong = dic[@"songname"];
//            BOOL isSameSong   = NO;
//            songName = [songName localizedLowercaseString];
//            dicSong = [dicSong localizedLowercaseString];
//            songName = [songName stringByReplacingOccurrencesOfString:@" " withString:@""];
//            dicSong = [dicSong stringByReplacingOccurrencesOfString:@" " withString:@""];
//            if([songName isEqualToString:dicSong]){
//                isSameSong = YES;
//            }else if (songName.length == dicSong.length){
//                isSameSong = YES;
//            }
//            //
//            if(isSameSong == YES && isSameSinger == YES){
//                [arr addObject:dic];
//            }
//
////            float pe = [self likePercent:songName OrString:dicSong];
////            NSLog(@"当前：%@，\n字段：%@",songName,dicSong);
//        }
//
//        if (arr.count > 0) {
//            NSString *str = [NSString stringWithFormat:@"%@",arr[0][@"content"]];
//            str = [str stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
//            str = [str stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
//            str = [str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
//            str = [str stringByReplacingOccurrencesOfString:@"\n " withString:@"\n"];
//            str1 = [NSString stringWithFormat:@"%@",str];
//        }else{
//            str1 = keyword;
//        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"QQApiSearchMusicError：%@",error);
//        NSString *d = [NSString stringWithFormat:@"currentSection：%ld，lastSection：%ld,currentRow：%ld,lastRow：%ld",self.musicStatusCtrl.currentSection,self.musicStatusCtrl.lastSection,self.musicStatusCtrl.currentRow,self.musicStatusCtrl.lastRow];
//        str1 = [NSString stringWithFormat:@"歌词下载失败：err_code: %ld\n%@",error.code,d];
    }];
}

//- (float)likePercent:(NSString *)target OrString:(NSString *)orString{
//
//    int n = (int)orString.length;
//    int m = (int)target.length;
//    if (m == 0) return n;
//    if (n == 0) return m;
//    //Construct a matrix, need C99 support
//
//    int matrix[n + 1][m + 1];
//    memset(&matrix[0], 0, m+1);
//    for(int i=1; i<=n; i++) {
//        memset(&matrix[i], 0, m+1);
//        matrix[i][0]=i;
//    }
//    for(int i=1; i<=m; i++) {
//        matrix[0][i]=i;
//    }
//    for(int i=1;i<=n;i++) {
//        unichar si = [orString characterAtIndex:i-1];
//        for(int j=1;j<=m;j++){
//
//            unichar dj = [target characterAtIndex:j-1];
//            int cost;
//            if(si==dj){
//                cost=0;
//            }
//            else{
//                cost=1;
//            }
//            const int above=matrix[i-1][j]+1;
//            const int left=matrix[i][j-1]+1;
//            const int diag=matrix[i-1][j-1]+cost;
//            matrix[i][j]=min(above,min(left,diag));
//        }
//    }
//    return 100.0 - 100.0*matrix[n][m]/target.length;
//
//}

@end
