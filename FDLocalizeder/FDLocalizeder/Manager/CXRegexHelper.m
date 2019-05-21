//
//  CXRegexHelper.m
//  FDLocalizeder
//
//  Created by chuxiao on 2019/5/11.
//  Copyright © 2019 mob.com. All rights reserved.
//

#import "CXRegexHelper.h"

@implementation CXRegexHelper

+ (NSString *)getStringWithRegex:(NSString *)reg oriString:(NSString *)str
{
    NSString *url = str;//@"1229436624@qq.com";
    NSError *error;
    // 创建NSRegularExpression对象并指定正则表达式  @"[^@]*\\."
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:reg
                                  options:0
                                  error:&error];
    if (!error) { // 如果没有错误
        // 获取特特定字符串的范围
        NSTextCheckingResult *match = [regex firstMatchInString:url
                                                        options:0
                                                          range:NSMakeRange(0, [url length])];
        if (match) {
            // 截获特定的字符串
            NSString *result = [url substringWithRange:match.range];
            // NSLog(@"%@",result);
            
            return result;
        }
    } else { // 如果有错误，则把错误打印出来
        NSLog(@"error - %@", error);
    }
    
    return nil;
}

@end
