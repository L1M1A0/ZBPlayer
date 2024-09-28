//
//  ZBMacOSObject.h
//  OSX
//
//  Created by 李振彪 on 2017/5/25.
//  Copyright © 2017年 李振彪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface ZBMacOSObject : NSObject

#pragma mark - NSView
-(NSView *)view:(NSRect)frame superView:(NSView *)superView;

#pragma mark - NSButton
-(NSButton *)button:(NSRect)frame title:(NSString *)title tag:(NSInteger)tag type:(NSButtonType)type target:(id)target superView:(NSView *)superView;

#pragma mark - NSPopUpButton:BS
-(NSPopUpButton *)popUpButton:(NSRect)frame superView:(NSView *)superView;

#pragma mark - NSSegmentedControl
-(NSSegmentedControl *)segmentedControl:(NSRect)frame labels:(NSArray *)labels target:(id)target superView:(NSView *)superView;

#pragma mark - NSProgressIndicator
- (NSProgressIndicator *)progressIndicator:(NSRect)frame style:(NSProgressIndicatorStyle)style superView:(NSView *)superView;

#pragma mark - NSStepper
-(NSStepper *)stepper:(NSRect)frame superView:(NSView *)superView;

#pragma mark - NSSlider
-(NSSlider *)slider:(NSSliderType)sliderType frame:(CGRect)frame superView:(NSView *)superView target:(id)target action:(SEL)action;
@end
