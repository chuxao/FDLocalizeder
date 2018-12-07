//
//  FDProjectFileManager.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/2.
//  Copyright © 2018年 chuxiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDProjectFileManager : NSObject

+ (instancetype)share;

- (void)getLocalizesWithPath:(NSString *)path result:(void(^)())result;

- (void)readContentOfFile:(NSString *)filePath;

- (void)writeToFile:(NSString *)content;

@end
