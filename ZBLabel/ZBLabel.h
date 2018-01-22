//
//  ZBLabel.h
//  test
//
//  Created by 周博 on 2018/1/22.
//  Copyright © 2018年 周博. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZBLinkLabelModel;
typedef void (^ZBLinkLabelBlock)(ZBLinkLabelModel *linkModel);



@interface ZBLabel : UILabel

- (void)setBoldFontToRange:(NSRange)range;
- (void)setBoldFontToString:(NSString *)string;

- (void)setFontColor:(UIColor *)color range:(NSRange)range;
- (void)setFontColor:(UIColor *)color string:(NSString *)string;

- (void)setFont:(UIFont *)font range:(NSRange)range;
- (void)setFont:(UIFont *)font string:(NSString *)string;
- (void)addLinkString:(NSString *)linkString block:(ZBLinkLabelBlock)linkBlock;

@end
