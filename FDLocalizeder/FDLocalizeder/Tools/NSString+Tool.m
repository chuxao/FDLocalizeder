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


#pragma mark - 获取这个字符串中的所有xxx的所在的index
- (NSDictionary *)getLastRangeStrWithFindText:(NSString *)findText
{
    
//    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:3];
    NSRange range;
    
    if (findText == nil && [findText isEqualToString:@""])
    {
        
        return nil;
        
    }
    
    NSRange rang = [self rangeOfString:findText]; //获取第一次出现的range
    
    if (rang.location != NSNotFound && rang.length != 0)
    {
        
//        [arrayRanges addObject:[NSNumber numberWithInteger:rang.location]];//将第一次的加入到数组中
        range = rang;
        
        NSRange rang1 = {0,0};
        
        NSInteger location = 0;
        
        NSInteger length = 0;
        
        for (int i = 0;; i++)
        {
            
            if (0 == i)
            {//去掉这个xxx
                
                location = rang.location + rang.length;
                
                length = self.length - rang.location - rang.length;
                
                rang1 = NSMakeRange(location, length);
                
            }
            else
            {
                
                location = rang1.location + rang1.length;
                
                length = self.length - rang1.location - rang1.length;
                
                rang1 = NSMakeRange(location, length);
                
            }
            
            //在一个range范围内查找另一个字符串的range
            
            rang1 = [self rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];
            
            if (rang1.location == NSNotFound && rang1.length == 0)
            {
                
                break;
                
            }
            else//添加符合条件的location进数组
                
//                [arrayRanges addObject:[NSNumber numberWithInteger:rang1.location]];
                range = rang1;
        }
        
        return @{@"location" : @(range.location),
                 @"length" : @(range.length)
                 };
        
    }
    
    return nil;
}
@end
