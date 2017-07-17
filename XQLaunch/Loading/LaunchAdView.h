//
//  LaunchAdView.h
//  Tea
//
//  Created by Ticsmatic on 2016/12/25.
//  Copyright © 2016年 Ticsmatic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LaunchAdView : UIView

/// loading完成回调
@property (nonatomic, copy) void (^launchFinishedBlock)(LaunchAdView *loading);

- (void)createLaunchAdView;
@end
