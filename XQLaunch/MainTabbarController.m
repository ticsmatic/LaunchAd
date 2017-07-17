//
//  MainTabbarController.m
//  XQLaunch
//
//  Created by Ticsmatic on 2017/7/17.
//  Copyright © 2017年 Ticsmatic. All rights reserved.
//

#import "MainTabbarController.h"
#import "LaunchAdView.h"

@interface MainTabbarController ()

@end

@implementation MainTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    LaunchAdView *launchView = [[[NSBundle mainBundle] loadNibNamed:@"LaunchAdView" owner:nil options:nil] lastObject];
    launchView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.view addSubview:launchView];
    [launchView createLaunchAdView];
    
    launchView.launchFinishedBlock = ^(LaunchAdView *LaunchAdView) {
        NSLog(@"%s", __func__);
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
