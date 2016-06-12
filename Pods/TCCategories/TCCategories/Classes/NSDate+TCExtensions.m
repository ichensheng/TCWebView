//
//  NSDate+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "NSDate+TCExtensions.h"

@implementation NSDate (TCExtensions)

/**
 *  获取时间戳
 *
 *  @return 时间戳
 */
- (long long)tc_timestamp {
    return [[NSNumber numberWithDouble:[self timeIntervalSince1970] * 1000] longLongValue];
}

@end
