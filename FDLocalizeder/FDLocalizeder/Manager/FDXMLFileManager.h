//
//  FDXMLFileManager.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/14.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDXMLFileManager : NSObject

- (instancetype)initWithFilePath:(NSString *)filePath;

+ (void)parsFile:(id)obj
            path:(NSString *)path
            left:(char)left
       leftIndex:(NSInteger)leftIndex
           right:(char)right
      rightIndex:(NSInteger)rightIndex;

+ (void)parsFile:(id)obj
            path:(NSString *)path
            left:(NSString *)left
           right:(NSString *)right;

- (NSArray *)parsFileVertical:(char)verticalRow
                          top:(NSInteger)top
                       bottom:(NSInteger)bottom
                        limit:(BOOL)isLimit;

- (NSArray *)parsFilehorizontal:(NSInteger)horizontalRow
                           left:(char)left
                          right:(char)right
                          limit:(BOOL)isLimit;

- (NSString *)parsRow:(char)charIndex
                     :(NSInteger)intIndex;

- (void)writeRowWithContent:(NSString *)content
                           :(char)charIndex
                           :(NSInteger)intIndex;

- (void)save;
@end
