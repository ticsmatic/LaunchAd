//
//  LaunchAdView.m
//  Tea
//
//  Created by Ticsmatic on 2016/12/25.
//  Copyright © 2016年 Ticsmatic. All rights reserved.
//

#import "LaunchAdView.h"
#import "AppDelegate.h"
#import "GuideView.h"
#import "Advertisement.h"
#import "WebViewController.h"

#define DISPATCH_SOURCE_CANCEL(time) if(time)\
{\
dispatch_source_cancel(time);\
time = nil;\
}

typedef NS_ENUM(NSUInteger, CompareRet){
    CompareRetEqual = 0,
    CompareRetBig,
    CompareRetSmall
};

@interface LaunchAdView ()
@property (weak, nonatomic) IBOutlet UIImageView *adImageView;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIImageView *bottomIcon;
@property (nonatomic, strong) GuideView *guideView;

@property(nonatomic, assign) NSInteger index;

@property(nonatomic, strong) Advertisement *adModel;

@property(nonatomic,copy)dispatch_source_t waitTimer;
@property(nonatomic,copy)dispatch_source_t skipTimer;
@end

@implementation LaunchAdView

- (void)awakeFromNib {
    [super awakeFromNib];
    _bottomIcon.image = [self getTheLaunchImage];
    _skipButton.layer.masksToBounds = YES;
    _skipButton.layer.cornerRadius = 12;
}

- (void)createLaunchAdView {
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self commonInit];
}

/// 判断是否是首次启动，以及相应的动作
- (void)commonInit {
    if ([self isNewVersion]) {
        // 执行新版本引导
        GuideView *guideView = [[[NSBundle mainBundle] loadNibNamed:@"GuideView" owner:nil options:nil] lastObject];
        guideView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self addSubview:guideView];
        [guideView createGuideView];
        
        guideView.guideFinishedBlock = ^(GuideView *guide) {
            [self guideFinish];
        };
    } else {
        // 创建loadingView 进行启动动画
        [self initLoadingView];
    }
}
#pragma mark - 版本引导

- (void)guideFinish {
    // 移除loading
    [self skipButtonClick];
    // 存储版本号
    [self currentVsrsionISLaunched];
    [UIView animateWithDuration:0.6 animations:^{
        self.guideView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.guideView removeFromSuperview];
        
    }];
}

/// 进行启动动画
- (void)initLoadingView {
    [self.skipButton addTarget:self action:@selector(skipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.adImageView.userInteractionEnabled = YES;
    self.adImageView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adImageViewTap:)];
    [self.adImageView addGestureRecognizer:tgr];
    
    // 创建等待的timer，内部默认值为3秒，超过3秒，此view自动从父视图移除，在3秒内加载出来广告的话就显示广告，同时取消等待的timer，开启跳过的倒计时timer，点击跳过或者图片或者倒计时结束，取消“跳过timer”，流程结束
    [self wait];
    
    // 模拟0.5秒网络请求，返回数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"launchAd" ofType:@"json"]];
        NSDictionary *json =  [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
        id obj = json[@"data"];
        
        if (!obj) {
            self.skipButton.hidden = YES;
            return;
        }
        NSArray *ads = [NSArray yy_modelArrayWithClass:[Advertisement class] json:obj];
        if (ads == nil || ads.count == 0) {
            self.skipButton.hidden = YES;
            return;
        }
        self.adModel = ads.firstObject;
        [self.skipButton setTitle:@"跳过" forState:UIControlStateNormal];
        [self.adImageView yy_setImageWithURL:[NSURL URLWithString:self.adModel.thumbnail] placeholder:nil];
        
        [self skip];
    });
}
#pragma mark - 计时
-(void)skip {
    DISPATCH_SOURCE_CANCEL(_waitTimer);
    __block NSInteger duration = 4;//默认
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _skipTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_skipTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_skipTimer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.skipButton setTitle:[NSString stringWithFormat:@"%lds", duration] forState:UIControlStateNormal];
            if(duration==0){
                DISPATCH_SOURCE_CANCEL(_skipTimer);
                [self skipButtonClick];
                return ;
            }
            duration--;
        });
    });
    dispatch_resume(_skipTimer);
}

-(void)wait {
    __block NSInteger duration = 3;
    NSTimeInterval period = 1.0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _waitTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_waitTimer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_waitTimer, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(duration==0) {
                DISPATCH_SOURCE_CANCEL(_waitTimer);
                [self skipButtonClick];
                return ;
            }
            duration--;
        });
    });
    dispatch_resume(_waitTimer);
}

#pragma mark - 事件
- (void)skipButtonClick {
    // 进行完成回调
    DISPATCH_SOURCE_CANCEL(_waitTimer);
    DISPATCH_SOURCE_CANCEL(_skipTimer);
    if (_launchFinishedBlock) _launchFinishedBlock(self);
    
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        // 进行完成回调
        [self removeFromSuperview];
    }];
}

- (void)adImageViewTap:(UIGestureRecognizer *)tgr {
    NSLog(@"%@", @"点击广告");
    if (!self.adModel.url.length) return;
    
    [self skipButtonClick];
    // 弹出广告
    if (self.adModel.url.length > 0) {
        WebViewController *vc = [[WebViewController alloc] init];
        vc.url = self.adModel.url;
        
        UIViewController* root = [[UIApplication sharedApplication].delegate window].rootViewController;
        UINavigationController *nav = ((UITabBarController*)root).selectedViewController;
        vc.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:vc animated:YES];
    }
    DISPATCH_SOURCE_CANCEL(_skipTimer);
}

#pragma mark - Private

- (BOOL)isNewVersion {
    // 获取存储的版本号
    NSString *savedVerison = [[NSUserDefaults standardUserDefaults] objectForKey:@"VersionISLaunched"] ? : @"0";
    CompareRet ret = [self currentCompareWithVersion:savedVerison];
    return ret == CompareRetBig ? YES : NO;
}

- (void)currentVsrsionISLaunched {
    [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"VersionISLaunched"];
}

- (CompareRet)currentCompareWithVersion:(NSString *)version {
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if ([version isEqualToString:currentVersion]) {
        return CompareRetEqual;
    }
    // 当前版本
    NSArray *currentVersionArray = [currentVersion componentsSeparatedByString:@"."];
    // 对比的版本
    NSArray *versionArray = [version componentsSeparatedByString:@"."];
    
    CompareRet ret = CompareRetEqual;
    for (int i = 0; i < MIN(currentVersionArray.count, versionArray.count); i ++) {
        NSInteger current = [currentVersionArray[i] integerValue];
        NSInteger version = [versionArray[i] integerValue];
        if (version > current) {
            ret = CompareRetSmall;
            break;
        } else if (version < current ) {
            ret = CompareRetBig;
            break;
        }
    }
    return ret;
}


// 获取加载的启动图
- (UIImage *)getTheLaunchImage {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    
    NSString *viewOrientation = nil;
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)) {
        viewOrientation = @"Portrait";
    } else {
        viewOrientation = @"Landscape";
    }
    
    NSString *launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    return [UIImage imageNamed:launchImage];
}

@end
