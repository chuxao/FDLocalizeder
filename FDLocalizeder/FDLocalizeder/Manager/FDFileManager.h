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
// ①
- (void)parseFileWithCode:(NSString *)code
                   values:(NSDictionary *)dicValues;

// ②
- (void)parseFileWithCodes:(NSArray *)arrCodes;

// ③
- (void)parseFileWithValues:(NSArray *)arrValues;

// ④
- (void)parseFileWithCode:(NSString *)code
                   values:(NSDictionary *)dicValues
                    index:(int)index;

// ⑤
- (void)parseFileWithLanguage:(NSString *)language
                        codes:(NSArray *)codes
                       values:(NSArray *)values;

// ⑥
- (void)parseException:(NSException *)exception;

// ⑦
- (void)outputCount:(NSInteger)count
           allcount:(NSInteger)allcount
               type:(NSInteger)type
               flag:(NSInteger)flag
           userInfo:(NSDictionary *)userInfo;

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

+ (void)parsCodesAndLanguagesWithPath:(NSString *)path
                                 left:(char)left
                                right:(char)right
                                  top:(NSInteger)top
                               bottom:(NSInteger)bottom
                                limit:(BOOL)isLimit
                              success:(void(^)(NSArray <NSString*>*, NSArray <NSString*>*))success;

+ (void)parsLanguages:(id)obj
                 path:(NSString *)path
                 left:(char)left
                right:(char)right
                limit:(BOOL)isLimit;

+ (void)parsCodesWithPath:(NSString *)path
                      top:(NSInteger)top
                   bottom:(NSInteger)bottom
                    limit:(BOOL)isLimit
                  success:(void(^)(NSArray <NSString*>*))success;

// ⑦
+ (void)exportDataToExcel:(id)obj
        localizeExcelPath:(NSString *)localizeExcelPath
     localizeContentPaths:(NSArray *)localizeContentPaths
                languages:(NSArray *)languages
                    codes:(NSArray <NSString *>*_Nullable)codes;

@end
