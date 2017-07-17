//
//  GuideView.h
//  Tea
//
//  Created by Ticsmatic on 2016/12/23.
//  Copyright © 2016年 Ticsmatic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuideView : UIView
/// 引导完成的回调
@property (nonatomic, copy) void (^guideFinishedBlock)(GuideView *guideView);

- (void)createGuideView;
@end
