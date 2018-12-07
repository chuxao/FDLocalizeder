//
//  FDDataManager.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/4.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDDataManager : NSObject

+ (instancetype)share;

- (void)writeToFile:(NSString *)filePath
       existingCode:(NSDictionary *)existingCode
            content:(NSString *)content
             result:(void(^)(BOOL result))result;

- (void)writeToFileQueue:(NSString *)filePath
                 content:(NSString *)content
                  result:(void(^)(BOOL result))result;

- (void)writeToFileQueue:(NSString *)filePath
                     key:(NSString *)key
                   value:(NSString *)value
                  result:(void(^)(BOOL result))result;

- (void)writeToFileQueue:(NSString *)filePath
                     key:(NSString *)key
                   value:(NSString *)value
             codeComment:(NSString *)codeComment
                  result:(void(^)(BOOL result))result;

- (void)writeToFileQueue:(NSString *)filePath
                   codes:(NSArray *)codes
                  values:(NSArray *)values
             codeComment:(NSString *)codeComment
                  result:(void(^)(BOOL result))result;

- (void)truncateFileWithPath:(NSString *)path;

@end
