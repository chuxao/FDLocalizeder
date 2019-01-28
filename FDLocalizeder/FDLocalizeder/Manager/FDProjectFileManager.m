//
//  FDProjectFileManager.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/2.
//  Copyright © 2018年 chuxiao. All rights reserved.
//

#import "FDProjectFileManager.h"

@interface FDProjectFileManager ()

@property (nonatomic, strong) NSFileManager *fileManger;

@property (nonatomic, strong) NSMutableSet *localizeNames;

@property (nonatomic, strong) NSMutableArray *languagesPathsArray;

@end

@implementation FDProjectFileManager

+ (instancetype)share
{
    static dispatch_once_t onceToken;
    static FDProjectFileManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[FDProjectFileManager alloc] init];
    });
    
    return manager;
}

- (void)getLocalizesWithPath:(NSString *)path result:(void(^)())result
{
    BOOL isDir = NO;
    
    NSString *basePath = path;
    
    if ([path hasSuffix:@".xcodeproj"]) {
        basePath = [path stringByDeletingLastPathComponent];
    }
    else if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: &isDir]
        && isDir) {

        if (!isDir) {
            basePath = [path stringByDeletingLastPathComponent];
        }
    }
    else {
        basePath = [path stringByDeletingLastPathComponent];
    }
    
//    NSLog(@"basePath = %@",basePath);
    [self.languagesPathsArray removeAllObjects];
    [self getFiles:basePath];
    
    result(self.localizeNames.copy, self.languagesPathsArray.copy);
//    NSLog(@"languagesSet = %@",self.localizeNames);
//    NSLog(@"languagesPathsArray = %@",self.languagesPathsArray);
}

- (void)getFiles:(NSString *)path{
    
    // 1.判断文件还是目录
    BOOL isDir = NO;
    BOOL isExist = [self.fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        // 2. 判断是不是目录
        if (isDir) {
            NSError *error;
            
//            BOOL result = [self.fileManger judg];
                        
            NSArray * dirArray = [self.fileManger contentsOfDirectoryAtPath:path error:&error];
            NSString * subPath = nil;
            
            
            if ([[path lastPathComponent] hasSuffix:@".lproj"]) {
                
                BOOL hasStringFile = NO;
                for (NSString * str in dirArray) {
                    
                    if ([str hasSuffix:@".strings"]) {
                        [self.localizeNames addObject:[str componentsSeparatedByString:@"."][0]];
                        hasStringFile = YES;
                    }
                }
                
                if (hasStringFile) {
                    [self.languagesPathsArray addObject:path];
                }
            }
            else
            {
                for (NSString * str in dirArray) {
                    
                    subPath  = [path stringByAppendingPathComponent:str];
                    BOOL issubDir = NO;
                    [self.fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                    [self getFiles:subPath];
                }
                
            }
        }
    }else{
        NSLog(@"no file");
    }
}

- (void)readContentOfFile:(NSString *)filePath
{
    
}



#pragma mark - lazy load
- (NSFileManager *)fileManger
{
    if (!_fileManger) {
        _fileManger = [NSFileManager defaultManager];
    }
    return _fileManger;
}

- (NSMutableSet *)localizeNames
{
    if (!_localizeNames) {
        _localizeNames = [[NSMutableSet alloc] init];;
    }
    return _localizeNames;
}

- (NSMutableArray *)languagesPathsArray
{
    if (!_languagesPathsArray) {
        _languagesPathsArray = [[NSMutableArray alloc] init];;
    }
    return _languagesPathsArray;
}
@end
