//
//  FDFileManager.h
//  TestLocalizeder
//
//  Created by chuxiao on 2018/5/3.
//  Copyright © 2018年 chuxiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FDParseFileDelegate <NSObject>

@optional
- (void)parseFileWithCode:(NSString *)code
                   values:(NSDictionary *)dicValues;

- (void)parseFileWithValues:(NSArray *)arrValues;

- (void)parseFileWithCode:(NSString *)code
                   values:(NSDictionary *)dicValues
                    index:(int)index;

- (void)parseFileWithLanguage:(NSString *)language
                        codes:(NSArray *)codes
                       values:(NSArray *)values;

- (void)parseException:(NSException *)exception;

- (void)parseFinish;

@end

@interface FDFileManager : NSObject

+ (void)parsFile:(id)obj
            path:(NSString *)path;

+ (void)parsFile:(id)obj
            path:(NSString *)path
       rowLength:(NSInteger)rowLength;

+ (void)parsFile:(id)obj
            path:(NSString *)path
            left:(char)left
             top:(NSInteger)top
           right:(char)right
          bottom:(NSInteger)bottom
           limit:(BOOL)isLimit;

+ (void)parsFileWithPath:(NSString *)path
                  column:(char)column
                     top:(NSInteger)top
                  bottom:(NSInteger)bottom
                 success:(void(^)(NSArray <NSString*>*))success;

+ (void)parsLanguages:(id)obj
                 path:(NSString *)path
                 left:(char)left
                right:(char)right
                limit:(BOOL)isLimit;
@end
