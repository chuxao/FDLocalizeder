//
//  CXSpecialCharacterConversion.m
//  FDLocalizeder
//
//  Created by chuxiao on 2019/5/10.
//  Copyright © 2019 mob.com. All rights reserved.
//

#import "CXSpecialCharacterConversion.h"

@implementation CXSpecialCharacterConversion

+ (NSString *)replaceSpecialCharacters:(NSString *)string
{
    NSString *s1 = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    NSString *s2 = [s1 stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    NSString *s3 = [s2 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *s4 = [s3 stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    NSString *s5 = [s4 stringByReplacingOccurrencesOfString:@"%" withString:@"\%"];
    return s5;
}

//+ (NSString *)replaceSpecialCharacters:(NSString *)string
//{
//    NSString *s1 = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
//    NSString *s2 = [s1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
//
//    return s2;
//}

// for 正则
+ (NSString *)replaceSpecialCharactersForRegex:(NSString *)string
{
    NSString *s1 = [string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\\\\\"];
    NSString *s2 = [s1 stringByReplacingOccurrencesOfString:@"\n" withString:@"\\\\n"];
    NSString *s3 = [s2 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\\\""];
    NSString *s4 = [s3 stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\\\'"];
    NSString *s5 = [s4 stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
    NSString *s6 = [s5 stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
    
    return s6;
}

+ (NSString *)replaceUnicode:(NSString *)unicodeStr
{
    
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    NSLog(@"%@",returnStr);
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

@end
