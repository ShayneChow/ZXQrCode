//
//  ZXNavigationController.m
//  ZXQrCode
//
//  Created by Xiang on 16/4/20.
//  Copyright © 2016年 周想. All rights reserved.
//

#import "ZXNavigationController.h"

@interface ZXNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation ZXNavigationController

+ (void)initialize {
    // 设置导航栏背景
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_bg"] forBarMetrics:UIBarMetricsDefault];
    // 设置导航栏中间的标题属性
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:20];
    [bar setTitleTextAttributes:attrs];
    [bar setTintColor:[UIColor blackColor]];
}

- (void)viewWillAppear:(BOOL)animated{
    
    // Called when the view is about to made visible. Default does nothing
    [super viewWillAppear:animated];
    
    //去除导航栏下方的横线
    
    //[self.navigationBar setShadowImage:[UIImage new]];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.interactivePopGestureRecognizer.delegate = self;
    //self.view.backgroundColor = [UIColor yellowColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  拦截导航控制器push进来的所有子控制器
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // viewController不是导航控制器的第1个子控制器
    if (self.childViewControllers.count > 0) {
        
        //        viewController.hidesBottomBarWhenPushed = YES;
        
        // 设置viewController左上角的按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateHighlighted];
        //        [button setTitle:@"返回" forState:UIControlStateNormal];
        //        [button setTitleColor:ZXColor(251, 131, 0) forState:UIControlStateNormal];
        //        [button setTitleColor:ZXColor(251, 32, 0) forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit]; // 导航左键固定大小
        // 相当于让按钮的内容往左边偏移20
        button.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    
    // super的push方法最好放在最后面调用
    // 一旦调用pushViewController:animated:方法,就会开始创建viewController的view,也就是调用viewController的viewDidLoad方法
    [super pushViewController:viewController animated:animated];
}

- (void)back {
    [self popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    
    if (self.childViewControllers.count == 1) {
        return false;
    }
    return true;
}

@end
