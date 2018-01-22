//
//  ViewController.m
//  demo
//
//  Created by 周博 on 2018/1/22.
//  Copyright © 2018年 周博. All rights reserved.
//

#import "ViewController.h"
#import "ZBLabel.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet ZBLabel *label;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    宪法修改是国家政治生活中的一件大事，是党中央从新时代坚持和发展中国特色社会主义全局和战略高度作出的重大决策，也是推进全面依法治国、推进国家治理体系和治理能力现代化的重大举措。
    
//    治国凭圭臬，安邦靠准绳。19日发布的党的十九届二中全会公报，在社会各界引起高度关注和强烈反响。
    [self.label setBoldFontToString:@"宪法修改"];
    [self.label setFont:[UIFont systemFontOfSize:30] string:@"特色社会主义"];
    [self.label setFontColor:[UIColor redColor] string:@"重大决策"];
    
    [self.label setFontColor:[UIColor blueColor] string:@"19日发布的党的十九届二中全会公报"];
    [self.label addLinkString:@"19日发布的党的十九届二中全会公报" block:^(ZBLinkLabelModel *linkModel) {
        NSLog(@"点击了文字");
        //做你想做的事
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
