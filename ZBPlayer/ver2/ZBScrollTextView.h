//
//  ZBScrollTextView.h
//  ZBPlayer
//
//  Created by lzb on 2024/10/2.
//  Copyright © 2024 LiZB. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBScrollTextView : NSScrollView

@property(nonatomic,strong) NSTextView *textView;


-(instancetype)initWithScrollTextView;
@end







NS_ASSUME_NONNULL_END
