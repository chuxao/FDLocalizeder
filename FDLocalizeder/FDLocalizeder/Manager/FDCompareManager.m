//
//  FDCompareManager.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/12/4.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDCompareManager.h"

@implementation FDCompareManager

//- (NSDictionary *)compareValuesWithFilePath:(NSString *)filePath
//                                      codes:(NSArray *)codes
//                                     values:(NSArray *)values
//{
//    NSArray *localKeys = [self _parseLocalfileToArray:filePath];
//
//    NSMutableArray *inCodes = [NSMutableArray array];
//    NSMutableArray *inValues = [NSMutableArray array];
//    NSMutableArray *sameInCodes = [NSMutableArray array];
//
//    for (NSString *key in localKeys) {
//        if ([codes containsObject:key]) {
//            [sameInCodes addObject:key];
//        }else {
//            [inCodes addObject:key];
//            [inValues addObject:values[[codes indexOfObject:key]]];
//
//        }
//    }
//
//    return @{@"codes"       : inCodes,
//             @"values"      : inValues,
//             @"sameCodes"   : sameInCodes
//             };
//}
//
//- (NSDictionary *)compareValuesWithFilePath_1:(NSString *)filePath_1
//                                   filePath_2:(NSString *)filePath_2
//{
//    NSArray *localKeys_1 = [self _parseLocalfileToArray:filePath_1];
//    NSArray *localKeys_2 = [self _parseLocalfileToArray:filePath_2];
//
//    NSMutableArray *onlyLocal_1 = localKeys_1.mutableCopy;
//    NSMutableArray *onlyLocal_2 = localKeys_2.mutableCopy;
//
//    for (NSString *key in localKeys_1) {
//        if ([localKeys_2 containsObject:key]) {
//            [onlyLocal_1 removeObject:key];
//            [onlyLocal_2 removeObject:key];
//        }
//    }
//
//    return @{@"onlyLocal_1" : onlyLocal_1.copy,
//             @"onlyLocal_2" : onlyLocal_2.copy};
//}

/**
 TODO: 这里没有去兼容没加双引号的本地化文本

 @param filePath <#filePath description#>
 @return <#return value description#>
 */
+ (NSDictionary *)parseLocalfileToDictionary:(NSString *)filePath
{
    NSDictionary *dicContent = [NSDictionary dictionaryWithContentsOfFile:filePath];//[[NSDictionary alloc] initWithContentsOfFile:filePath];//
    
    return dicContent;
    
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    
    NSString *content = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    
//    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:kCFStringEncodingUTF8 error:nil];
//    content = [self replaceUnicode:content];
    NSArray *allKeys = [dicContent allKeys];
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    
    int count = 0;
    for (NSString * key in allKeys) {
        
        NSString *value = [self replaceSpecialCharacters:dicContent[key]];
        value = [NSString stringWithFormat:@"\"%@\"",value];
//        NSString * encodedValue =  [NSString stringWithString:[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
//        NSString * encodedValue = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)value, NULL, NULL,  kCFStringEncodingUTF8));
        
        NSRange range = [content rangeOfString:value];
        
        if (range.length > 0) {
            [mdic setObject:@{@"location" : @(range.location), @"length" : @(range.length)} forKey:key];
        }
        
        //        NSLog(@"%lu",range.location);
        count ++;
        //        NSLog_G(@"%i  %lu  %lu", count, [mdic allKeys].count, range.location);
    }
    
    return mdic.copy;
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


+ (NSString *)replaceSpecialCharacters:(NSString *)string
{
    NSString *s1 = [string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    NSString *s2 = [s1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    return s2;
}

@end
