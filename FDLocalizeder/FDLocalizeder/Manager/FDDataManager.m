//
//  FDDataManager.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/4.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDDataManager.h"
#import "FDCompareManager.h"
#import "CXSpecialCharacterConversion.h"
#import "CXRegexHelper.h"
#import "NSString+Tool.h"

@implementation FDDataManager

+ (instancetype)share
{
    static dispatch_once_t onceToken;
    static FDDataManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[FDDataManager alloc] init];
    });
    
    return manager;
}


/**
 写入数据
 这里使用NSFileManager 的方式，NSFileManager本身是线程安全的，普通方式需要手动考虑线程安全问题

 @param filePath <#filePath description#>
 @param content <#content description#>
 @param result <#result description#>
 */
- (void)writeToFile:(NSString *)filePath
       existingCode:(NSDictionary *)existingCode
            content:(NSString *)content
             result:(void(^)(BOOL result))result
{
    // 排他性处理
    if (existingCode && [existingCode allKeys].count) {
        NSDictionary *dicContent = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        
        NSString *contentOri = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];//[NSString stringWithContentsOfFile:filePath encoding:kCFStringEncodingUTF8 error:nil];
        //        contentOri = [CXSpecialCharacterConversion replaceSpecialCharacters:contentOri];
        
        NSArray *existAllKeys = [existingCode allKeys];
        //        NSUInteger locationPadding = 0;
        
        for (NSString *key in existAllKeys) {
            NSString *valueOri = dicContent[key];
            NSString *valueOri_1 = [NSString stringWithFormat:@"\"%@\"", [CXSpecialCharacterConversion replaceSpecialCharacters:valueOri]];
            NSString *valueOri_2 = [NSString stringWithFormat:@"\"%@\"", [CXSpecialCharacterConversion replaceSpecialCharacters2:valueOri]];
            
            NSString *valueNow = existingCode[key];
            valueNow = [NSString stringWithFormat:@"\"%@\"", [CXSpecialCharacterConversion replaceSpecialCharacters:valueNow]];
            
            if ([contentOri rangeOfString:valueOri_1].location !=NSNotFound) {
                valueOri = valueOri_1;
            }else {
                valueOri = valueOri_2;
            }
            
//            NSRange range = [contentOri rangeOfString:valueOri];
            NSDictionary *dicRange = [contentOri getLastRangeStrWithFindText:valueOri];
            NSRange range = NSMakeRange([dicRange[@"location"] integerValue], [dicRange[@"length"] integerValue]);
            
            if (range.length == 0) {
                NSLog(@"0000000000000002  %@ \n ======%@ =====",valueOri, contentOri);
            }
            //            if (range.length)
            contentOri = [contentOri stringByReplacingCharactersInRange:range withString:valueNow];
            
            
            //            long location = [existingCode[key][@"location"] integerValue] + locationPadding;
            //            NSUInteger length = [existingCode[key][@"length"] integerValue];
            //            NSRange range = NSMakeRange(location+1, length-2);
            //            contentOri = [contentOri stringByReplacingCharactersInRange:range withString:
            //                       key];
            
            //            locationPadding = locationPadding + key.length + 2 - length;
        }
        
        NSError *error;
        BOOL re = [contentOri writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!re) {
            NSLog(@"替换行操作错误  %@",error);
        }
    }
    
    if (!content.length) {
        result(YES);
        return;
    }

    // 创建文件首先需要一个文件管理对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 获取某个文件或者某个文件夹的大小
    NSDictionary *dic = [fileManager attributesOfItemAtPath:filePath error:nil];
    NSNumber *number = [dic objectForKey:NSFileSize];
    NSInteger length = number.intValue;
    
    // 创建文件对接对象
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:filePath]; // 文件对接对象此时针对文件既可以读取又可以写入
    // 将偏移量挪到3的位置
    [handle seekToFileOffset:length];
    
    // 写入数据
    [handle writeData:[[NSString stringWithFormat:@"%@", content] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //synchronizeFile将数据同步写入文件中
//    [handle synchronizeFile];
    
    // 执行完操作之后不要忘记关闭文件
    [handle closeFile];
    
    result(YES);
    
    
//    NSError *error=nil;
//
//    // 通过指定的路径读取文本内容
//    NSString *str = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//
//    NSString *string = [NSString stringWithFormat:@"%@\n%@", str, content];
//
//    BOOL re = [string writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
//    if (error || !re) {
//        result(NO);
//    }else if (re) {
//        result(YES);
//    }
}


- (void)deleteText:(NSString *)filePath
          delArray:(NSArray *)delArray
            result:(void(^)(BOOL result))result
{
    __block NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [delArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
//        obj = [CXSpecialCharacterConversion replaceSpecialCharacters:obj];
        content = [content stringByReplacingOccurrencesOfString:obj withString:@""];
        
    }];
    
    NSError *error;
    BOOL re = [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!re) {
        NSLog(@"替换行操作错误  %@",error);
    }
}


- (void)writeToFileQueue:(NSString *)filePath
                 content:(NSString *)content
                  result:(void(^)(BOOL result))result
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 20;
    
    [queue addOperationWithBlock:^{
        [self writeToFile:filePath existingCode:nil content:content result:result];
    }];
}

- (void)writeToFileQueue:(NSString *)filePath
                     key:(NSString *)key
                   value:(NSString *)value
                  result:(void(^)(BOOL result))result
{
    [self writeToFileQueue:filePath key:key value:value result:result];
}

- (void)writeToFileQueue:(NSString *)filePath
                     key:(NSString *)key
                   value:(NSString *)value
             codeComment:(NSString *)codeComment
                  result:(void(^)(BOOL result))result
{
#pragma mark - 解析xlsx,NSOperationQueue控制最大并发数,性能良好
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 20;
    
    [queue addOperationWithBlock:^{
        
        NSString *currentKey = [CXSpecialCharacterConversion replaceSpecialCharacters:key];
        NSString *currentValue = [CXSpecialCharacterConversion replaceSpecialCharacters:value];
        
        NSString *content = [NSString stringWithFormat:@"\"%@\" = \"%@\";",currentKey, currentValue];
        if (codeComment) {
            content = [NSString stringWithFormat:@"%@\n%@",codeComment, content];
        }
        
        [self writeToFile:filePath existingCode:nil content:content result:result];
    }];
}

- (void)writeToFileQueue:(NSString *)filePath
                   codes:(NSArray *)codes
                  values:(NSArray *)values
             codeComment:(NSString *)codeComment
                  result:(void(^)(BOOL result))result
{
#pragma mark - 解析xlsx,NSOperationQueue控制最大并发数,性能良好
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 15;
    
    [queue addOperationWithBlock:^{
        NSDictionary *existingCode = [FDCompareManager parseLocalfileToDictionary:filePath];
        
        // 如果不需要进行修改性添加，打开如下注释
//        existingCode = nil;
        
        NSString *content = [self _stringFromCodes:codes values:values existingCode:&existingCode codeComment:codeComment];
    
        [self writeToFile:filePath existingCode:existingCode content:content result:result];
    }];
}

- (void)deleteTextQueue:(NSString *)filePath
                  codes:(NSArray *)codes
            codeComment:(NSString *)codeComment
                 result:(void(^)(BOOL result))result
{
#pragma mark - 解析xlsx,NSOperationQueue控制最大并发数,性能良好
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 15;
    
    [queue addOperationWithBlock:^{
        NSDictionary *dicContent = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (!content) {
            return ;
        }
        
        __block NSMutableArray *delArray = [NSMutableArray array];
        if (codeComment && codeComment.length) {
            [delArray addObject:codeComment];
        }
        
        [codes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *value = dicContent[obj];
            obj = [CXSpecialCharacterConversion replaceSpecialCharactersForRegex:obj];
            if (!obj || [obj length] == 0) {
                return ;
            }
            value = [CXSpecialCharacterConversion replaceSpecialCharactersForRegex:value];
            if (!value) {
                return ;
            }
            
            NSString *patt = [NSString stringWithFormat:@"\"%@\"\\s*=\\s*\"%@\"\\s*;\n?", obj, value];
            NSString *delString = [CXRegexHelper getStringWithRegex:patt oriString:content];
            
            if (delString && delString.length) {
                [delArray addObject:delString];
            }
            
        }];
        
        [self deleteText:filePath delArray:delArray result:^(BOOL result) {
            
        }];
    }];
}

- (void)truncateFileWithPath:(NSString *)path
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 20;
    
    [queue addOperationWithBlock:^{
        // 创建文件对接对象
        NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:path]; // 文件对接对象此时针对文件既可以读取又可以写入
        //清空数据
        [handle truncateFileAtOffset:0];
    }];
}

/**
 <#Description#>

 @param codes <#codes description#>
 @param values <#values description#>
 @param existingCode 本地已经存在的code 位置“键值对”
 @param codeComment <#codeComment description#>
 @return <#return value description#>
 */
- (NSString *)_stringFromCodes:(NSArray *)codes
                        values:(NSArray *)values
                  existingCode:(NSDictionary **)existingCode
                   codeComment:(NSString *)codeComment
{
    NSDictionary *dicExitCode = *existingCode ?: @{};
    NSMutableDictionary *mdicExitCode = @{}.mutableCopy;
    
    NSMutableString *msting = [NSMutableString string];
    
    if (codeComment.length && codes.count && values.count) {
        [msting appendFormat:@"%@\n",codeComment];
    }
    
    for (int i = 0; i < codes.count; i++) {
        NSString *code = codes[i];
        code = [CXSpecialCharacterConversion replaceSpecialCharacters:code];
        
        NSString *value = i < values.count? values[i] : @"";
        value = [CXSpecialCharacterConversion replaceSpecialCharacters:value];
        
        if (dicExitCode[code]) {

            // 封装数据：value为新值       【“range”为value，新值为key （该方案弃用）】
            [mdicExitCode setObject:values[i] forKey:codes[i]];
        }
        else if (code.length && value.length) {
            NSString *content = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n",code, value];
            [msting appendString:content];
        }
    }
    
    *existingCode = mdicExitCode.copy;
    
    return msting.copy;
}

- (NSArray *)_stringCollectionFromFilePath:(NSString *)filePath
                                     codes:(NSArray *)codes
                               codeComment:(NSString *)codeComment
{
    return nil;
}

@end
