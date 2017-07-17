//
//  Advertisement.m
//  Tea
//
//  Created by Ticsmatic on 2017/3/24.
//  Copyright © 2017年 Ticsmatic. All rights reserved.
//

#import "Advertisement.h"

@implementation Advertisement

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSString *openMode = dic[@"openMode"];
    if ([openMode isEqualToString:@"EXTERNAL"]) _openMode = OpenModeEnumOut;
    else _openMode = OpenModeEnumIn;
    return YES;
}

@end
