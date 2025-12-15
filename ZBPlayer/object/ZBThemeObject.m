//
//  ZBThemeObject.m
//  ZBPlayer
//
//  Created by lzb on 2024/10/9.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import "ZBThemeObject.h"

@implementation ZBThemeObject




-(void)colorModelWithType:(NSInteger)type{
    
    if(type == 1){
        self.mainWindowAlphaValue = 0.6;
        self.splitViewAlphaValue = 0.3;
        self.scrollViewAlphaValue = 0.3;
        self.outlineViewAlphaValue = 0.3;
        self.outlineSectionAlphaValue = 0.3;//section 不会改变颜色，启动时是什么颜色，后面就是什么颜色,所以设置0.0
        self.outlineRowAlphaValue = 0.3;//section 不会改变颜色，启动时是什么颜色，后面就是什么颜色，所以设置0.0
        self.tableViewAlphaValue = 0.3;
        self.splitRightTopViewAlphaValue = 0.3;

        self.mainWindowColor = [NSColor colorWithCalibratedWhite:0 alpha:0.8];
        self.superWindowColor =  [NSColor colorWithCalibratedWhite:0 alpha:0.3];//
        self.splitViewColor =  [NSColor colorWithCalibratedWhite:0 alpha:0.3];
        self.scrollViewColor =  [NSColor colorWithCalibratedWhite:0 alpha:0.3];
        self.outlineViewColor =  [NSColor colorWithCalibratedWhite:0 alpha:0.3];
        self.outlineSectionColor =  [NSColor colorWithCalibratedWhite:0 alpha:0.3];
        self.outlineRowColor =  [NSColor colorWithCalibratedWhite:0 alpha:0.3];
        self.tableViewColor =  [NSColor colorWithCalibratedWhite:0 alpha:0.3];
        self.splitRightTopViewColor = [NSColor colorWithCalibratedWhite:0 alpha:0.3];
    }else{
        //默认颜色
        self.mainWindowAlphaValue = 0.2;
        self.splitViewAlphaValue = 0;
        self.scrollViewAlphaValue = 0;
        self.outlineViewAlphaValue = 0.1;
        self.outlineSectionAlphaValue = 0.2;//section 不会改变颜色，启动时是什么颜色，后面就是什么颜色,所以设置0.0
        self.outlineRowAlphaValue = 0;//section 不会改变颜色，启动时是什么颜色，后面就是什么颜色,所以设置0.0
        self.tableViewAlphaValue = 0.1;
        self.splitRightTopViewAlphaValue = 0.2;
        self.btnAlphaValue = 0.3;
        
        
        NSColor *clearGray =  [NSColor colorWithCalibratedRed:0x22/255.0 green:0x22/255.0 blue:0x22/255.0 alpha:0xFF/255.0];//在不同屏幕环境下不会变色
        NSColor *clearWhite = [NSColor colorWithCalibratedWhite:0 alpha:0.3];//白色值，0表示无白色，
        NSColor *clear22 = [NSColor purpleColor];//cyanColor\orangeColor\redColor\greenColor\purpleColor
        NSColor *colorTin = [NSColor colorNamed:@"Tin"];
        NSColor *mainColor;

        //读取默认颜色，如果有用户设置的，优先使用默认颜色
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSData *colorData = [userdefault objectForKey:kDefaultMainColorKey];
        NSError *error;
        NSColor *oldColor = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSColor class] fromData:colorData error:&error];
        
        if(!oldColor){
            mainColor = clear22;
//            [userdefault setObject:mainColor forKey:kDefaultMainColorKey];
        }else{
            mainColor = oldColor;
        }
 
        [self changeColor:mainColor];
    }
    
}

-(void)changeColor:(NSColor *)color{
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSData *colordata = [NSKeyedArchiver archivedDataWithRootObject:color];
    [userdefault setObject:colordata forKey:kDefaultMainColorKey];
    [userdefault synchronize];//立即同步数据到磁盘，确保数据持久化。实际上iOS8.0和macos10.10之后，已经无需手动调用此方法，系统自动会同步处理。

    
    //视图层级从底到面
    //主窗口颜色
    self.mainWindowColor = [[NSColor clearColor] colorWithAlphaComponent:self.mainWindowAlphaValue];//[NSColor colorWithCalibratedRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:self.mainWindowAlphaValue];
    //暂时不存在
//        self.superWindowColor =  [NSColor colorWithCalibratedWhite:0 alpha:0.1];
    //分页控件颜色
    self.splitViewColor =  [color colorWithAlphaComponent:self.splitViewAlphaValue];
    //滚动视图颜色
    //禁止绘制scrollView的背景，解决透明问题 [self.scrollView setDrawsBackground:NO]; 以下设置颜色的方法是不会生效的。
    self.scrollViewColor =  [color colorWithAlphaComponent:self.scrollViewAlphaValue];

    //scrollView的子视图
    //大纲目录控件颜色
    self.outlineViewColor = [color colorWithAlphaComponent:self.outlineViewAlphaValue];// mainGray;///[NSColor colorWithRed:100/255.0 green:100/255.0 blue:1/255.0 alpha:0.3/255.0];
    //大纲目录section颜色
    self.outlineSectionColor =  [color  colorWithAlphaComponent:self.outlineSectionAlphaValue];
//        self.outlineSectionImageViewColor =  [NSColor colorWithRed:100 green:100 blue:1 alpha:0.3];
//        self.outlineSectionTextFieldColor =  [NSColor colorWithRed:100 green:100 blue:1 alpha:0.3];
    //大纲目录section下的row的颜色
    self.outlineRowColor =  [color  colorWithAlphaComponent:self.outlineRowAlphaValue];
//        self.outlineRowImageViewColor = [NSColor colorWithCalibratedWhite:0 alpha:0.3];
//        self.outlineRowTextFieldColor = [NSColor colorWithCalibratedWhite:0 alpha:0.3];

    //scrollView的子视图
    //表视图的颜色
    self.tableViewColor =   [color colorWithAlphaComponent:self.tableViewAlphaValue];//mainGray;

    //右侧顶部功能栏的颜色
    self.splitRightTopViewColor = [color colorWithAlphaComponent:self.splitRightTopViewAlphaValue];//[NSColor colorWithCalibratedWhite:0 alpha:self.splitRightTopViewAlphaValue];
    
    self.btnColor = [color colorWithAlphaComponent:self.btnAlphaValue];


}



@end
