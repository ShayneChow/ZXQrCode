//
//  ZXResultViewController.m
//  ZXQrCode
//
//  Created by Xiang on 16/4/20.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ZXResultViewController.h"

#define ZXScreenW [UIScreen mainScreen].bounds.size.width
#define ZXScreenH [UIScreen mainScreen].bounds.size.height

@interface ZXResultViewController ()

@end

@implementation ZXResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描结果";
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, ZXScreenW - 40, 30)];
    [self.view addSubview:label];
    label.text = _result;
}

@end
