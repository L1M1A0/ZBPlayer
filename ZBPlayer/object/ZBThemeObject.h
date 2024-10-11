//
//  ZBThemeObject.h
//  ZBPlayer
//
//  Created by lzb on 2024/10/9.
//  Copyright © 2024 LiZB. All rights reserved.
//

/**
 主题设置
 如颜色管理之类的
 
 */

#import <Foundation/Foundation.h>
#import <AppKit/NSColor.h>
//@class ZBColorModel;

NS_ASSUME_NONNULL_BEGIN
//@interface ZBColorModel : NSObject
//
//
//
//
//@end
//
//@implementation ZBColorModel
//
//
//
//@end

@interface ZBThemeObject : NSObject


@property (nonatomic, copy)   NSColor *mainWindowColor;
@property (nonatomic, assign) CGFloat  mainWindowAlphaValue;
@property (nonatomic, copy) NSColor *superWindowColor;//

@property (nonatomic, copy)   NSColor *splitViewColor;
@property (nonatomic, assign) CGFloat  splitViewAlphaValue;

@property (nonatomic, copy)   NSColor *scrollViewColor;
@property (nonatomic, assign) CGFloat  scrollViewAlphaValue;

@property (nonatomic, copy)   NSColor *outlineViewColor;
@property (nonatomic, assign) CGFloat  outlineViewAlphaValue;
@property (nonatomic, copy)   NSColor *outlineSectionColor;
@property (nonatomic, copy)   NSColor *outlineSectionImageViewColor;
@property (nonatomic, copy)   NSColor *outlineSectionTextFieldColor;

@property (nonatomic, assign) CGFloat  outlineSectionAlphaValue;
@property (nonatomic, copy)   NSColor *outlineRowColor;
@property (nonatomic, assign) CGFloat  outlineRowAlphaValue;
@property (nonatomic, copy)   NSColor *outlineRowImageViewColor;
@property (nonatomic, copy)   NSColor *outlineRowTextFieldColor;

@property (nonatomic, copy)   NSColor *tableViewColor;
@property (nonatomic, assign) CGFloat  tableViewAlphaValue;

@property (nonatomic, copy)   NSColor *splitRightTopViewColor;
@property (nonatomic, assign) CGFloat  splitRightTopViewAlphaValue;

@property (nonatomic, copy)   NSColor *btnColor;
@property (nonatomic, assign) CGFloat  btnAlphaValue;



//@property (nonatomic, strong) ZBColorModel *colorModel;


-(void)colorModelWithType:(NSInteger)type;
-(void)changeColor:(NSColor *)color;

@end

NS_ASSUME_NONNULL_END
