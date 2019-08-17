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
NSInteger MaxBotton = 2000;


@interface FDFileManager()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *localFile;

@property (nonatomic, assign) id <FDParseFileDelegate> delegate;

@end

@implementation FDFileManager

/**
 全文档获取
 Document wrapping

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
                            
                            [xmlManager writeRowWithContent:content :flag :row :nil :^{
                                
                            }];
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


/**
 获取一行数据
 备份

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
 export
 
 */
+ (void)parsCodesWithPath:(NSString *)path
                      top:(NSInteger)top
                   bottom:(NSInteger)bottom
                    limit:(BOOL)isLimit
                  success:(void(^)(NSArray <NSString*>*))success
{
    FDFileManager *fileManager = [[self alloc] init];
    
    NSInteger row_top = isLimit? (Code_Horizontal>top? Code_Horizontal:top) : Code_Horizontal;
    NSInteger row_bottom = isLimit? (bottom>MaxBotton? MaxBotton:bottom) : MaxBotton;
    
    [fileManager storeFileWithPath:path toPath:fileManager.localFile success:^(NSString *doc) {
        
        FDXMLFileManager *xmlManager = [[FDXMLFileManager alloc] initWithFilePath:doc];

        NSArray *codes = [xmlManager parsFileVertical:Code_Vertical top:row_top bottom:row_bottom limit:isLimit];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success) {
                success(codes);
            }
        });
        
        [fileManager.fileManager removeItemAtPath:fileManager.localFile error:nil];
    } onException:^(NSException *exception) {
        
    }];
}

+ (void)parsCodesAndLanguagesWithPath:(NSString *)path
                                 left:(char)left
                                right:(char)right
                                  top:(NSInteger)top
                               bottom:(NSInteger)bottom
                                limit:(BOOL)isLimit
                              success:(void(^)(NSArray <NSString*>*, NSArray <NSString*>*))success
{
    FDFileManager *fileManager = [[self alloc] init];
    
    char row_left = isLimit? (Code_Vertical>left? Code_Vertical:left) : Code_Vertical;
    char row_right = isLimit? (right>MaxRight? MaxRight:right) : MaxRight;
    NSInteger row_top = isLimit? (Code_Horizontal>top? Code_Horizontal:top) : Code_Horizontal;
    NSInteger row_bottom = isLimit? (bottom>MaxBotton? MaxBotton:bottom) : MaxBotton;
    
    [fileManager storeFileWithPath:path toPath:fileManager.localFile success:^(NSString *doc) {
        
        FDXMLFileManager *xmlManager = [[FDXMLFileManager alloc] initWithFilePath:doc];
        
        NSArray *languages = [xmlManager parsFilehorizontal:Language_Horizontal left:row_left right:row_right limit:isLimit];
        NSArray *codes = [xmlManager parsFileVertical:Code_Vertical top:row_top bottom:row_bottom limit:isLimit];
        
        if (success) {
            
            success(codes, languages);
        }
        
        [fileManager.fileManager removeItemAtPath:fileManager.localFile error:nil];
    } onException:^(NSException *exception) {
        
    }];
}

/**
 获取多列数据

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
                NSLog(@"=================   %i",arrayContents.count);
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
        
        NSLog(@"已删除");
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
        if (success) {
            success(codes);
        }
        
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

+ (void)exportDataToExcel:(id)obj
        localizeExcelPath:(NSString *)localizeExcelPath
     localizeContentPaths:(NSArray *)localizeContentPaths
                languages:(NSArray *)languages
                    codes:(NSArray <NSString *>*_Nullable)codes
{
    if (!codes || !codes.count) {
        NSDictionary *dicContent = [NSDictionary dictionaryWithContentsOfFile:localizeContentPaths.firstObject];
        codes = [dicContent allKeys];
    }
    
    FDFileManager *fileManager = [[self alloc] init];
    fileManager.delegate = obj;
    
    [fileManager storeFileWithPath:localizeExcelPath toPath:fileManager.localFile success:^(NSString *doc) {
    
        FDXMLFileManager *xmlManager = [[FDXMLFileManager alloc] initWithFilePath:doc];
        NSString *sheetName = @"FDLocalizederExportSheet";
//        [xmlManager createSecondWorksheetName:sheetName];
        sheetName = nil;
//        localizeContentPaths
        
//        NSDictionary *dicContent = [NSDictionary dictionaryWithContentsOfFile:localizeContentPath];
        
        __block NSInteger count = 0;
        NSInteger allcount = codes.count + languages.count + codes.count * languages.count;
        
        [codes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            [xmlManager writeRowWithContent:obj :'A' :idx+2 :sheetName :^{
                
            }];
            
            {
                count ++;
                if ([fileManager.delegate respondsToSelector:@selector(outputCount:allcount:type:flag:userInfo:)]) {
                    [fileManager.delegate outputCount:count allcount:allcount type:0 flag:0 userInfo:nil];
                }
            }
            
        }];
        
        dispatch_queue_t concurrentQueue = dispatch_queue_create("com.FDLocalizederExport.syncQueue", DISPATCH_QUEUE_CONCURRENT);
        
//        dispatch_barrier_async(concurrentQueue, ^{
            [localizeContentPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                char flag = 66 + idx;
                [xmlManager writeRowWithContent:languages[idx] :flag :1 :sheetName :^{
                    
                }];
                {
                    count ++;
                    if ([fileManager.delegate respondsToSelector:@selector(outputCount:allcount:type:flag:userInfo:)]) {
                        [fileManager.delegate outputCount:count allcount:allcount type:0 flag:0 userInfo:nil];
                    }
                }
                
                
                NSDictionary *dicContent = [NSDictionary dictionaryWithContentsOfFile:obj];
                
                [codes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj2, NSUInteger idx2, BOOL * _Nonnull stop2) {
                    NSString *value = dicContent[obj2];
                    [xmlManager writeRowWithContent:value :flag :idx2+2 :sheetName :nil];
                    {
                        count ++;
                        if ([fileManager.delegate respondsToSelector:@selector(outputCount:allcount:type:flag:userInfo:)]) {
                            [fileManager.delegate outputCount:count allcount:allcount type:0 flag:0 userInfo:nil];
                        }
                    }
                    
                }];

            }];
//        });
        
//        dispatch_async(concurrentQueue, ^{
        
            //                });
            
            //                NSString *desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, NO)objectAtIndex:0];
//            NSString *bundel = [[NSBundle mainBundle] resourcePath];
//
//            NSString *desktopPath = [[bundel substringToIndex:[bundel rangeOfString:@"Library"].location] stringByAppendingFormat:@"Desktop"];
        
//            [fileManager storeFileWithPath:doc toPath:desktopPath success:^(NSString *doc2) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([fileManager.delegate respondsToSelector:@selector(outputCount:allcount:type:flag:userInfo:)]) {
                [fileManager.delegate outputCount:0 allcount:0 type:0 flag:1 userInfo:@{@"filePath" : doc ,@"folderPath" : fileManager.localFile}];
            }
        });
        
                [xmlManager save];
                // 循环结束后删除临时文件
//                [fileManager.fileManager removeItemAtPath:fileManager.localFile error:nil];
//            } onException:^(NSException *exception) {
//
//            }];
//        });

    } onException:^(NSException *exception) {


        NSLog(@"XXXXXX  %@",exception);
    }];
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
        NSLog(@"0000  %@",arguments);
        [MPTask runTaskWithLanunchPath:CMD_CP arguments:arguments currentDirectoryPath:nil onSuccess:^(NSString *captureString) {
            NSLog(@"1111");
            success(doc);
        } onException:^(NSException *exception) {
            NSLog(@"2222");
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

