//
//  FDFileManager.m
//  TestLocalizeder
//
//  Created by chuxiao on 2018/5/3.
//  Copyright © 2018年 chuxiao. All rights reserved.
//

#import "FDFileManager.h"
#import "MPTask.h"
#import "FDXMLFileManager.h"

char Language_Vertical = 'B';
NSInteger Language_Horizontal = 1;

char Code_Vertical = 'A';
NSInteger Code_Horizontal = 2;


char MaxRight = 'Z';
NSInteger MaxBotton = 1000;


@interface FDFileManager()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *localFile;

@property (nonatomic, assign) id <FDParseFileDelegate> delegate;

@end

@implementation FDFileManager


//+ (void)parsFile:(id)obj path:(NSString *)path
//{
//    [self parsFile:obj path:path rowLength:0];
//
//}


/**
 全文档获取

 @param obj <#obj description#>
 @param path <#path description#>
 */
+ (void)parsFile:(id)obj path:(NSString *)path
{
    FDFileManager *fileManager = [[self alloc] init];
    fileManager.delegate = obj;

    [fileManager storeFileWithPath:path toPath:fileManager.localFile success:^(NSString *doc) {

        FDXMLFileManager *xmlManager = [[FDXMLFileManager alloc] initWithFilePath:doc];

        int row = 1;

        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t disqueue =  dispatch_queue_create("FDLocalizeder", DISPATCH_QUEUE_CONCURRENT);
        
        while(YES) {

            NSInteger count = 0;
            
            for (int i = 65; i <= 90; i ++) {
               
                char flag = i;
                __block NSString *content = [xmlManager parsRow:flag :row];
                

                if (content.length == 0) {
                    
                    NSLog(@" ");
//                    [xmlManager save];
                    break ;
                }else
                {
                    count ++;
//                    dispatch_group_async(group, disqueue, ^{
                    
                        if ([content containsString:@"\n"]) {
                            content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
                            
                            [xmlManager writeRowWithContent:content :flag :row];
                        }
                    
//                    });
                    
                }
            }

            if (count == 0) {
//                dispatch_group_notify(group, dispatch_get_global_queue(0,0), ^{
                    [xmlManager save];
//                });
                
//                NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, NO)objectAtIndex:0];
                NSString *bundel = [[NSBundle mainBundle] resourcePath];
                
                NSString *desktopPath = [[bundel substringToIndex:[bundel rangeOfString:@"Library"].location] stringByAppendingFormat:@"Desktop"];
                
                [fileManager storeFileWithPath:doc toPath:desktopPath success:^(NSString *doc) {
                    NSLog(@"成功！！！");
                    // 循环结束后删除临时文件
                    [fileManager.fileManager removeItemAtPath:fileManager.localFile error:nil];
                } onException:^(NSException *exception) {
                    
                }];
                
                
                break;
            }
            row++;
        }

    } onException:^(NSException *exception) {


        NSLog(@"XXXXXX  %@",exception);
    }];
}


//
//+ (void)parsFile2:(id)obj path:(NSString *)path rowLength:(NSInteger)rowLength
//{
//
//}


/**
 获取一行数据

 @param obj <#obj description#>
 @param path <#path description#>
 @param left <#left description#>
 @param right <#right description#>
 @param isLimit <#isLimit description#>
 */
+ (void)parsLanguages:(id)obj
                 path:(NSString *)path
                 left:(char)left
                right:(char)right
                limit:(BOOL)isLimit
{
    FDFileManager *fileManager = [[self alloc] init];
    fileManager.delegate = obj;
    
    char row_left = isLimit? (Language_Vertical>left? Language_Vertical:left) : Language_Vertical;
    char row_right = isLimit? (right>MaxRight? MaxRight:right) : MaxRight;
    
    [fileManager storeFileWithPath:path toPath:fileManager.localFile success:^(NSString *doc) {
        
        FDXMLFileManager *xmlManager = [[FDXMLFileManager alloc] initWithFilePath:doc];
        NSArray *languages = [xmlManager parsFilehorizontal:Language_Horizontal left:row_left right:row_right limit:isLimit];
        
        if ([fileManager.delegate respondsToSelector:@selector(parseFileWithValues:)]) {

            dispatch_async(dispatch_get_main_queue(), ^{
                [fileManager.delegate parseFileWithValues:languages];
            });
        }
        
        [fileManager.fileManager removeItemAtPath:fileManager.localFile error:nil];
    } onException:^(NSException *exception) {
        
    }];
}


/**
 获取一列数据

 @param obj <#obj description#>
 @param path <#path description#>
 @param horizontal <#horizontal description#>
 @param horizontalIndex <#horizontalIndex description#>
 @param vertical <#vertical description#>
 @param verticalIndex <#verticalIndex description#>
 */
+ (void)parsFile:(id)obj
            path:(NSString *)path
            left:(char)left
             top:(NSInteger)top
           right:(char)right
          bottom:(NSInteger)bottom
           limit:(BOOL)isLimit

{
    FDFileManager *fileManager = [[self alloc] init];
    fileManager.delegate = obj;
    
    [fileManager storeFileWithPath:path toPath:fileManager.localFile success:^(NSString *doc) {
        
        FDXMLFileManager *xmlManager = [[FDXMLFileManager alloc] initWithFilePath:doc];
        
        char row_left = left > right? right : left;
        char row_right = left > right?  left : right;
        NSInteger row_top = top > bottom? bottom : top;
        NSInteger row_bottom = top > bottom? top : bottom;
        
        row_left = isLimit? row_left : 'A';
        row_right = isLimit? row_right : MaxRight;
        row_top = isLimit? row_top : 1;
        row_bottom = isLimit? row_bottom : MaxBotton;
        
        
        
        NSInteger horizontalRow = row_top == Language_Horizontal? row_top+1 : row_top;  // 横
        char verticalRow = row_left == Language_Vertical? row_left+1 : row_left;  // 竖

        NSArray *languages = [xmlManager parsFilehorizontal:Language_Horizontal left:Language_Vertical>row_left? Language_Vertical:row_left right:row_right limit:isLimit];
        
        NSArray *codes = [xmlManager parsFileVertical:Code_Vertical top:Code_Horizontal > row_top? Code_Horizontal:row_top bottom:row_bottom limit:isLimit];
        
        
        // 从左往右执行verticalRow
        while(YES) {
            
            if (verticalRow > row_right) {
                
                if ([fileManager.delegate respondsToSelector:@selector(parseFinish)]) {
                    [fileManager.delegate parseFinish];
                }
                break;
            }
            
            
            
            // code
            if (verticalRow != Code_Vertical) {
                // 获取一排内容
                NSArray *arrayContents = [xmlManager parsFileVertical:verticalRow top:horizontalRow bottom:row_bottom limit:isLimit];
                
                if (!arrayContents.count) {
                    if ([fileManager.delegate respondsToSelector:@selector(parseFinish)]) {
                        [fileManager.delegate parseFinish];
                    }
                    break;
                }
                
                NSString *lan = [xmlManager parsRow:verticalRow :Language_Horizontal];
                
                if ([fileManager.delegate respondsToSelector:@selector(parseFileWithLanguage:codes:values:)]) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [fileManager.delegate parseFileWithLanguage:[lan lowercaseString] codes:codes values:arrayContents];
                    });
                    
                }
                
                // 直接抛出结果
            }
            
            verticalRow ++;
        }
        
        // 循环结束后删除临时文件
        [fileManager.fileManager removeItemAtPath:fileManager.localFile error:nil];
        
    } onException:^(NSException *exception) {
        
        
        NSLog(@"XXXXXX  %@",exception);
    }];
}

+ (void)parsFileWithPath:(NSString *)path
                  column:(char)column
                     top:(NSInteger)top
                  bottom:(NSInteger)bottom
                 success:(void(^)(NSArray <NSString*>*))success
{
    FDFileManager *fileManager = [[self alloc] init];

    [fileManager storeFileWithPath:path toPath:fileManager.localFile success:^(NSString *doc) {
        
        FDXMLFileManager *xmlManager = [[FDXMLFileManager alloc] initWithFilePath:doc];
        
        NSArray *codes = [xmlManager parsFileVertical:column top:top bottom:bottom limit:YES];
        success(codes);
        
        [fileManager.fileManager removeItemAtPath:fileManager.localFile error:nil];
        
    } onException:^(NSException *exception) {
        
        
        NSLog(@"XXXXXX  %@",exception);
    }];
}

+ (void)parsFile:(id)obj
            path:(NSString *)path
            left:(NSString *)left
           right:(NSString *)right
{
    
}


- (void)storeFileWithPath:(NSString *)path
                   toPath:(NSString *)toPath
                  success:(void(^)(NSString *doc))success
              onException:(void(^)(NSException *exception))onException
{
    
//    @"file:///Users/chuxiao/Desktop/huadan.xlsx"
    if (path) {
        NSString *fileNameStr = [path lastPathComponent];
        
        NSString *doc = [toPath stringByAppendingPathComponent:fileNameStr];
//        NSData *data = [NSData dataWithContentsOfURL:url];
//
//        BOOL result = [data writeToFile:doc atomically:YES];
        
        NSArray *arguments = @[@"-R",
                               path,
                               doc];
        [MPTask runTaskWithLanunchPath:CMD_CP arguments:arguments currentDirectoryPath:nil onSuccess:^(NSString *captureString) {
            
            success(doc);
        } onException:^(NSException *exception) {
            
            onException(exception);
        }];
        
    }
    
//    return nil;
}


- (NSString *)getLocalFilePath
{
    NSString *localFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/localFile"];
    
    NSLog(@"__________  %@",localFilePath);
    
    if (![self.fileManager fileExistsAtPath:localFilePath isDirectory:nil])
    {
        BOOL result = [self.fileManager createDirectoryAtPath:localFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if (!result)
        {
            NSLog(@"创建地址失败");
            return @"";
        }
        else
        {
            return localFilePath;
        }
    }
    else
    {
        return localFilePath;
    }
}

- (NSFileManager *)fileManager
{
    if (!_fileManager)
    {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (NSString *)localFile
{
    if (!_localFile)
    {
        _localFile = [self getLocalFilePath];
    }
    
    return _localFile;
}

@end

