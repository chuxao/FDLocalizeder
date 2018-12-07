//
//  FDUndoManager.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/11.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDUndoManager : NSObject

+ (instancetype)share;

- (void)saveFileWithFilePath:(NSString *)filePath
                      result:(void(^)(BOOL result))result;

- (void)undoFileWithFilePathArray:(NSArray *)arrPaths;

@end
