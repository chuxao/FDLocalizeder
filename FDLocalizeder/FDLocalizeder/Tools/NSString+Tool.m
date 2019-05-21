//
//  NSString+Tool.m
//  TelSalesAssistant
//
//  Created by chuxiao on 2017/12/25.
//  Copyright © 2017年 chuxiao. All rights reserved.
//

#import "NSString+Tool.h"

@implementation NSString (Tool)

+ (NSString *)timeFromTimeStep
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    
    // 毫秒值转化为秒/1000,本身为秒则不除1000
    NSDate * date = [NSDate date];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString *)timeFromTimeStepWithFormat:(NSString *)format
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    
    // 毫秒值转化为秒/1000,本身为秒则不除1000
    NSDate * date = [NSDate date];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString *)currentTimeStep
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%ld", (long)a]; //转为字符型
    
    return timeString;
}



@end
