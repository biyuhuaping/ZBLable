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

///设置BoldFont
- (void)setBoldFontToRange:(NSRange)range;
- (void)setBoldFontToString:(NSString *)string;

///设置Color
- (void)setFontColor:(UIColor *)color range:(NSRange)range;
- (void)setFontColor:(UIColor *)color string:(NSString *)string;

///设置Font
- (void)setFont:(UIFont *)font range:(NSRange)range;
- (void)setFont:(UIFont *)font string:(NSString *)string;

///添加link
- (void)addLinkString:(NSString *)linkString block:(ZBLinkLabelBlock)linkBlock;

@end




@interface ZBLinkLabelModel : NSObject
@property (copy, nonatomic) ZBLinkLabelBlock linkBlock;
@property (copy, nonatomic) NSString *linkString;
@property (assign, nonatomic) NSRange range;
@property (strong, nonatomic) id parameter;//点击链点的相关参数：id，色值，字体大小等

- (instancetype)initLinkLabelModelWithString:(NSString *)linkString range:(NSRange)range linkParameter:(id)parameter block:(ZBLinkLabelBlock)linkBlock;

@end
