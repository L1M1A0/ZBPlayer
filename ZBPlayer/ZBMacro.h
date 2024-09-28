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

#endif /* ZBMacro_h */
