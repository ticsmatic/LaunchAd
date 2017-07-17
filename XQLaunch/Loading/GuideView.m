//
//  GuideView.m
//  Tea
//
//  Created by Ticsmatic on 2016/12/23.
//  Copyright © 2016年 Ticsmatic. All rights reserved.
//

#import "GuideView.h"

@interface GuideView () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView; ///<scrollView的容器

@property (nonatomic ,assign) NSUInteger currentIndex;
@property (nonatomic ,strong) NSArray *imageArray;
@end

@implementation GuideView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    self.scrollView.delegate = self;
    
    [self addObserver:self forKeyPath:@"currentIndex" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)createGuideView {
    self.contentWidthConstraint.constant = [UIScreen mainScreen].bounds.size.width * self.imageArray.count;
    // 添加tap手势移动的下一页
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToNext:)];
    [self.contentView addGestureRecognizer:singleTap];
    UIView *preView = nil;
    // 图片的imageView
    for (int i = 0; i < self.imageArray.count; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%@", self.imageArray[i]];
        NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        
        if (preView) {
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(preView.mas_right);
                make.top.equalTo(self.contentView);
                make.width.equalTo(self);
                make.height.equalTo(self);
            }];
        } else {
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView);
                make.top.equalTo(self.contentView);
                make.width.equalTo(self);
                make.height.equalTo(self);
            }];
        }
        preView = imageView;
    }
}

#pragma mark - Action

- (void)tapToNext:(UITapGestureRecognizer *)tap {
    _scrollView.userInteractionEnabled = NO;
    tap.enabled = NO;
    if (_currentIndex == self.imageArray.count-1) {
        [self guideFinish];
        
    } else {
        [UIView animateWithDuration:0.4 animations:^{
            [_scrollView setContentOffset:CGPointMake(self.frame.size.width * (_currentIndex + 1), 0) animated:YES];
        } completion:^(BOOL finished) {
            _scrollView.userInteractionEnabled = YES;
            tap.enabled = YES;
        }];
    }
}

/// 引导完成，执行回调方法
- (void)guideFinish {
    if (_guideFinishedBlock) _guideFinishedBlock(self);
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentIndex"]) {
        NSInteger new = [change[@"new"] integerValue];
        NSInteger old = [change[@"old"] integerValue];
        
        if (new == old) return;
        if (new == 0) {
            
        }
        
        if (new == self.imageArray.count - 1) {
            
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentIndex = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    //self.pageControl.currentPage = self.currentIndex;
}

#pragma mark - Getter
- (NSArray *)imageArray {
    if (_imageArray == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"GuideImagelist" ofType:@"plist"];
        _imageArray = [NSArray arrayWithContentsOfFile:path];
    }
    return _imageArray;
}

#pragma mark -
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"currentIndex"];
}
@end
