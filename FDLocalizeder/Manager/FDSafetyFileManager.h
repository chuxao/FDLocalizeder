//
//  FDSafetyFileManager.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/14.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDSafetyFileManager : NSObject

+ (instancetype)shareInstance;

- (NSData *)readFile:(NSString *)path;
- (void)readFileAsync:(NSString *)path complete:(void (^)(NSData *data))complete;

- (BOOL)writeFile:(NSString *)path data:(NSData *)data;
- (void)writeFileAsync:(NSString *)path data:(NSData *)data complete:(void (^)(BOOL result))complete;

@end
