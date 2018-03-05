//
//  ZBLabel.m
//  test
//
//  Created by 周博 on 2018/1/22.
//  Copyright © 2018年 周博. All rights reserved.
//

#import "ZBLabel.h"
#import <CoreText/CoreText.h>

@implementation ZBLinkLabelModel
- (instancetype)initLinkLabelModelWithString:(NSString *)linkString range:(NSRange)range linkParameter:(id)parameter block:(ZBLinkLabelBlock)linkBlock {
    if ((self = [super init])) {
        _linkBlock = linkBlock;
        _linkString = [linkString copy];
        _range = range;
        _parameter = parameter;
    }
    return self;
}
@end


@interface ZBLabel ()
//@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSMutableAttributedString *attributedString;
@property (strong, nonatomic) NSMutableArray *linkArray;
@end

@implementation ZBLabel

static inline CGFloat ZBFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case NSTextAlignmentCenter:
            return 0.5f;
        case NSTextAlignmentRight:
            return 1.0f;
        case NSTextAlignmentLeft:
        default:
            return 0.0f;
    }
}

#pragma mark - Public methods
- (void)setBoldFontToRange:(NSRange)range
{
    NSString *fontNameBold = [NSString stringWithFormat:@"%@-Bold", [[self.font familyName] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    if (![UIFont fontWithName:fontNameBold size:self.font.pointSize]) {
#ifdef ZBDEBUG
        NSLog(@"%s: Font not found: %@", __PRETTY_FUNCTION__, fontNameBold);
#endif
        return;
    }
    
    UIFont *font = [UIFont fontWithName:fontNameBold size:self.font.pointSize];
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributed addAttribute:NSFontAttributeName value:font range:range];
    
    self.attributedText = attributed;
}

- (void)setBoldFontToString:(NSString *)string
{
    NSRange range = [self.text rangeOfString:string];
    [self setBoldFontToRange:range];
}

- (void)setFontColor:(UIColor *)color range:(NSRange)range
{
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributed addAttribute:NSForegroundColorAttributeName value:color range:range];
    
    self.attributedText = attributed;
}

- (void)setFontColor:(UIColor *)color string:(NSString *)string
{
    NSRange range = [self.text rangeOfString:string];
    [self setFontColor:color range:range];
}

- (void)setFont:(UIFont *)font range:(NSRange)range
{
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attributed addAttribute:NSFontAttributeName value:font range:range];
    
    self.attributedText = attributed;
}

- (void)setFont:(UIFont *)font string:(NSString *)string
{
    NSRange range = [self.text rangeOfString:string];
    [self setFont:font range:range];
}

- (void)addLinkString:(NSString *)linkString block:(ZBLinkLabelBlock)linkBlock{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnLabel:)];
    [self addGestureRecognizer:tap];
    
    NSRange range = [self.text rangeOfString:linkString];
    ZBLinkLabelModel *linkModel = [[ZBLinkLabelModel alloc]initLinkLabelModelWithString:linkString range:range linkParameter:nil block:linkBlock];
    if (linkModel) {
        [self.linkArray addObject:linkModel];
    }
}

#pragma mark - Private methods
- (NSMutableArray *)linkArray {
    if (!_linkArray) {
        _linkArray = [[NSMutableArray alloc]init];
    }
    return _linkArray;
}

- (void)handleTapOnLabel:(UITapGestureRecognizer *)tapGesture{
    CGPoint location = [tapGesture locationInView:self];
//    NSUInteger curIndex = (NSUInteger)[self characterIndexAtPoint1111:location];
    NSUInteger curIndex = (NSUInteger)[self ddddd:tapGesture];
    for (ZBLinkLabelModel *linkModel in _linkArray) {
        NSRange range = [self.text rangeOfString:linkModel.linkString];
        if (NSLocationInRange(curIndex, range)) {
            linkModel.linkBlock(linkModel);
        }
    }
}

- (CFIndex)characterIndexAtPoint1111:(CGPoint)p {
    CGRect textRect = self.bounds;
    //textRect的height值存在误差，值需设大一点，不然不会包含最后一行lines
    CGRect pathRect = CGRectMake(textRect.origin.x, textRect.origin.y, textRect.size.width, textRect.size.height+ 100000);
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    p = CGPointMake(p.x - textRect.origin.x, p.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    // p.x-5 是因为测试发现x轴坐标有偏移误差
    p = CGPointMake(p.x-5, pathRect.size.height - p.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, pathRect);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, (CFIndex)[self.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CGPathRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(frame);
        CGPathRelease(path);
        return NSNotFound;
    }
    
    CFIndex idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = (CGFloat)floor(lineOrigin.y - descent);
        CGFloat yMax = (CGFloat)ceil(lineOrigin.y + ascent);
        
        // Apply penOffset using flushFactor for horizontal alignment to set lineOrigin since this is the horizontal offset from drawFramesetter
        CGFloat flushFactor = ZBFlushFactorForTextAlignment(self.textAlignment);
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, textRect.size.width);
        lineOrigin.x = penOffset;
        
        // Check if we've already passed the line
        if (p.y > yMax) {
            break;
        }
        // Check if the point is within this line vertically
        if (p.y >= yMin) {
            // Check if the point is within this line horizontally
            if (p.x >= lineOrigin.x && p.x <= lineOrigin.x + width) {
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }
    
    CFRelease(frame);
    CGPathRelease(path);
//#ifdef ZBDEBUG
    NSLog(@"%s: 点击第%ld个字符", __PRETTY_FUNCTION__, idx);
//#endif
    return idx;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)p {
    if (!CGRectContainsPoint(self.bounds, p)) {
        return NSNotFound;
    }
    
    CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    if (!CGRectContainsPoint(textRect, p)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    p = CGPointMake(p.x - textRect.origin.x, p.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    p = CGPointMake(p.x, textRect.size.height - p.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
//    CTFrameRef frame = CTFramesetterCreateFrame([self framesetter], CFRangeMake(0, (CFIndex)[self.attributedText length]), path, NULL);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, (CFIndex)[self.attributedText length]), path, NULL);

    if (frame == NULL) {
        CGPathRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    if (numberOfLines == 0) {
        CFRelease(frame);
        CGPathRelease(path);
        return NSNotFound;
    }
    
    CFIndex idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = (CGFloat)floor(lineOrigin.y - descent);
        CGFloat yMax = (CGFloat)ceil(lineOrigin.y + ascent);
        
        // Apply penOffset using flushFactor for horizontal alignment to set lineOrigin since this is the horizontal offset from drawFramesetter
        CGFloat flushFactor = ZBFlushFactorForTextAlignment(self.textAlignment);
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, textRect.size.width);
        lineOrigin.x = penOffset;
        
        // Check if we've already passed the line
        if (p.y > yMax) {
            break;
        }
        // Check if the point is within this line vertically
        if (p.y >= yMin) {
            // Check if the point is within this line horizontally
            if (p.x >= lineOrigin.x && p.x <= lineOrigin.x + width) {
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(p.x - lineOrigin.x, p.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }
    
    CFRelease(frame);
    CGPathRelease(path);
    NSLog(@"%s: 点击第%ld个字符", __PRETTY_FUNCTION__, idx);
    return idx;
}

- (NSUInteger)ddddd:(UITapGestureRecognizer *)recognizer{
    CGPoint tapLocation = [recognizer locationInView:self];
    NSLog(@"x:%f  y:%f", tapLocation.x,tapLocation.y);
    
    // init text storage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    // init text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    textContainer.lineFragmentPadding  = 0;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    textContainer.lineBreakMode        = self.lineBreakMode;

    [layoutManager addTextContainer:textContainer];
    NSLog(@"%@", layoutManager);

    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:tapLocation inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    NSLog(@"%s: 点击第%ld个字符", __PRETTY_FUNCTION__, characterIndex);
    return characterIndex;
}

@end









