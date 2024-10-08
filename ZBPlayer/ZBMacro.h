//
//  ZBMacro.h
//  ZBPlayer
//
//  Created by Li28 on 2019/5/25.
//  Copyright © 2019 Li28. All rights reserved.
//

#ifndef ZBMacro_h
#define ZBMacro_h

#ifdef DEBUG
#define NSLog(format,...) printf("\n[%s] %s [第%d行] %s\n",__TIME__,__FUNCTION__,__LINE__,[[NSString stringWithFormat:format,## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

// -----------------字符串判空-------------
#define EmptyStr(obj)   ((![obj isKindOfClass:[NSString class]]) || (obj == nil) || [obj isEqualToString:@""] || [obj isKindOfClass:[NSNull class]]||[[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) ? @"" : obj

#define isEmptyStr(obj) [EmptyStr(obj) length] == 0 ? YES : NO

// -----------------RGB颜色-------------
#define RGBA(r,g,b,a) [NSColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]
#define RGB(r,g,b)    RGBA(r,g,b,1.0f)


//-------------------菜单----------------

#define kMenuItemAppVersion1    @"版本：1"
#define kMenuItemAppVersion2    @"版本：2"

#define kMenuItemImportFolderList   @"导入歌曲文件夹"
#define kMenuItemSectionInsert      @"新增文件夹列表"
#define kMenuItemSectionUpdate      @"更新本组（无）"
#define kMenuItemSectionRemove      @"移除本组（不会删除本地数据）"
#define kMenuItemSectionSelectAll   @"选中所有列表（所有列表的歌曲都可以播放）"
#define kMenuItemSectionSelectUser  @"自定义（只有被选中列表的歌曲才可以播放）"
#define kMenuItemSectionCollapseAll @"收起所有列表"

#define kMenuItemLocatePlaying      @"滚动到当前播放的歌曲位置"
#define kMenuItemShowInFinder       @"打开这首歌曲所在的文件夹"
#define kMenuItemDeleteFileInFolder @"从本地删除本歌曲（谨慎操作）"
#define kMenuItemPlayHistory        @"查看播放历史"//最多显示10条

#define kMenuItemSearchInCurrenSection  @"从本列表中搜索"
#define kMenuItemSearchInAllSection     @"从所有表中搜索"
#define kMenuItemSearchHistory          @"查看搜索历史"
#define kMenuItemSearchHistoryClear     @"清除搜索历史"

//—————————————————临时存储值————————————
/**
 app的版本，决定数据类型
 1. 版本1，根节点是选中的文件夹的名称，点击列表，展开显示歌曲名字，点击歌曲可以播放等
 2. 版本2，左侧根节点是选中的文件夹的名称，点击列表，展开的是歌手的名字。右侧是歌曲列表，默认展示首个列表的所有歌手。点击左侧歌手，可以滚动到该歌手位置，或者显示该歌手的歌曲列表
 
 */
#define kDefaultAPPViewVersion @"2"
#define kDefaultAppViewVersionKey @"kDefaultAppVersionKey"




#endif /* ZBMacro_h */
