//
//  FDUndoManager.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/11.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDUndoManager.h"

NSString const * undoFileName = @".FDLocalizederUndo";

@interface FDUndoManager ()

@property (strong, nonatomic) NSFileManager *fileManger;
@property (copy, nonatomic) NSString *undoFilePath;

@end

@implementation FDUndoManager

+ (instancetype)share
{
    static dispatch_once_t onceToken;
    static FDUndoManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[FDUndoManager alloc] init];
    });
    
    return manager;
}

- (instancetype) init
{
    if (self = [super init]) {
        [self setUndoFilePath];
        [self _createUndoFile];
    }
    
    return self;
}

- (void)_createUndoFile
{
    if (![self.fileManger fileExistsAtPath:_undoFilePath]) {
        [_fileManger createDirectoryAtPath:_undoFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [self.fileManger removeItemAtPath:_undoFilePath error:nil];
}


- (NSFileManager *)fileManger
{
    if (!_fileManger) {
        _fileManger = [NSFileManager defaultManager];
    }
    return _fileManger;
}

- (void)setUndoFilePath
{
    _undoFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@".undoFileName"];
}

#pragma mark - -----------------------------

- (void)saveFileWithFilePath:(NSString *)filePath
                      result:(void(^)(BOOL result))result
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 20;
    
    [queue addOperationWithBlock:^{
        
        NSArray *pathComponent = [filePath componentsSeparatedByString:@"/"];
        NSString *parentPath = [self->_undoFilePath stringByAppendingPathComponent:pathComponent[pathComponent.count - 2]];
        
        if (pathComponent.count >= 2)
            [self->_fileManger createDirectoryAtPath:parentPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        NSString *toPath = [parentPath stringByAppendingPathComponent:pathComponent.lastObject];
        
        [self.fileManger removeItemAtPath:toPath error:nil];
        
        /**
         toPath: 这个参数必须传入的是文件路径，而不是文件夹路径
         */
        BOOL re = [self.fileManger copyItemAtPath:filePath toPath:toPath error:nil];
        
        result(re);
    }];
    
}

- (void)undoFileWithFilePathArray:(NSArray *)arrPaths
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 20;
    
    
    // 暂存的 path array
    NSArray *dirArray = [self.fileManger contentsOfDirectoryAtPath:_undoFilePath error:nil];
    
    /**
     获取 文件名称
     
     理论上各个文件夹内的文件名相同，这里取第一个文价夹内的第一个文件
     */
    NSString *fileNamePath = [_undoFilePath stringByAppendingPathComponent:dirArray.firstObject];
    NSArray *fileNames = [self.fileManger contentsOfDirectoryAtPath:fileNamePath error:nil];
    NSString *fileName = fileNames.firstObject;
    
    for (NSString *filePath in arrPaths) {
        
        
        [queue addOperationWithBlock:^{
            
            if ([dirArray containsObject:filePath.lastPathComponent]) {
                // 获取被复制的path
                NSString *atPath = [NSString stringWithFormat:@"%@/%@/%@",self->_undoFilePath, filePath.lastPathComponent, fileName];
                
                NSString *toPath = [filePath stringByAppendingPathComponent:fileName];
                
                [self.fileManger removeItemAtPath:toPath error:nil];
                
                /**
                 toPath: 这个参数必须传入的是文件路径，而不是文件夹路径
                 */
                [self.fileManger copyItemAtPath:atPath toPath:toPath error:nil];
            }
            
        }];
    }
    
}


@end
