//
//  ZBSliderViewController.h
//  OSX
//
//  Created by Li28 on 2019/4/21.
//  Copyright © 2019 Li28. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBSliderViewController : NSViewController

@property (nonatomic, assign) float defaltVolume;

@property (nonatomic, strong) NSSlider *slider;
//-(void)slider:(void(^)(NSString * value))block;
@end

NS_ASSUME_NONNULL_END
