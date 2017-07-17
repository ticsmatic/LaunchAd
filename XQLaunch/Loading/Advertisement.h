//
//  Advertisement.h
//  Tea
//
//  Created by Ticsmatic on 2017/3/24.
//  Copyright © 2017年 Ticsmatic. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OpenModeEnum){
    OpenModeEnumIn = 0,
    OpenModeEnumOut,
};

@interface Advertisement : NSObject
@property (nonatomic, copy) NSString *longTitle;
@property (nonatomic, copy) NSString *shortTitle;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) OpenModeEnum openModeEnum;

@property (nonatomic, assign) NSInteger openMode;
@end
