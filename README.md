#ZBLabel ![图片描述]()

UILabel具有的功能
1. 多种字体
2. 多种颜色
3. 指定部分的文字响应点击事件



## 使用要求

ZBLabel 在iOS 5.0+版本上运行，并与ARC项目兼容。这取决于苹果框架，它应该已经包含在大多数Xcode模板中：

* Foundation.framework
* UIKit.framework

您将需要LLVM 3.0或更高版本才能构建 ZBLabel.


## 用法

```objective-c
#import "ZBLabel.h"
...
UIFont *boldFont = [UIFont fontWithName:@"Helvetica-Bold" size:17];
UIColor *blackColor = [UIColor blackColor];
NSString *loren = @"Lorem";
NSString *ipsum = @"ipsum";
    
[self.labelBlack setBoldFontToString:loren];
    
[self.labelBlue setFontColor:blackColor string:ipsum];
    
[self.labelGreen setFont:boldFont string:ipsum];
[self.labelGreen setFontColor:blackColor string:ipsum];

[self.label setFontColor:[UIColor blueColor] string:@"19日发布的党的十九届二中全会公报"];
[self.label addLinkString:@"19日发布的党的十九届二中全会公报" block:^(ZBLinkLabelModel *linkModel) {
NSLog(@"点击了文字");
//做你想做的事
}];

```

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).

## Change-log
