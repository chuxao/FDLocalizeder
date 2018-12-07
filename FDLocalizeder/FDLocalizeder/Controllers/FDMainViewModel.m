//
//  FDMainViewModel.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/4.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDMainViewModel.h"
#import "FDViewController.h"
#import "FDFileManager.h"
#import "FDDataManager.h"
#import "FDMainDataViewModel.h"
#import "FDUndoManager.h"
#import "FDLanguagePopoverViewController.h"
#import "FDPredicateManager.h"
#import "FDMainExtendViewModel.h"

@interface FDMainViewModel ()<FDParseFileDelegate>

@property (nonatomic, strong) NSMutableString *tipString;


// 加锁操作
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_semaphore_t semaphore;

// 添加时统计操作
@property (assign, nonatomic) NSInteger addLanguageCount;

// 正在添加中。。。
@property (assign, nonatomic) BOOL isAdding;

@end


@implementation FDMainViewModel

- (instancetype) init
{
    if (self = [super init]) {
        [self _configData];
    }
    
    return self;
}

- (void)_configData
{
    [self setLocalLanguages];
    self.mainDataVM = [[FDMainDataViewModel alloc] init];
    self.mainDataVM.mainVM = self;
    self.mainExtendVM = [FDMainExtendViewModel new];
    self.mainExtendVM.mainVM = self;
    
    
    // 信号量初始化
    self.semaphore = dispatch_semaphore_create(0);
    self.queue = dispatch_queue_create("FDMainVMQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_queue, ^{
        //阻塞线程，直到获取配置信息完成之后
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        
    });
}

- (void)transformDicLanguagesWithValueArray:(NSArray *)values
{
    [self _setLanguagesPlist];
    
    if (!values) {
        return;
    }
    
    NSMutableDictionary *mdic = self.dicLanguagesPlist.mutableCopy;
    
    NSArray *keys = [mdic allKeys];
    
    for (NSString *key in keys) {
        if (![values containsObject:mdic[key]]) {
            [mdic removeObjectForKey:key];
        }
    }
    
    self.dicLanguagesPlist = mdic.copy;
    NSLog(@"____%@",self.dicLanguagesPlist);
}

#pragma mark - FDParseFileDelegate

// 备份操作
- (void)parseFileWithValues:(NSArray *)arrValues
{
    NSMutableArray *languages = arrValues.mutableCopy;
    
    if ([self _needAddBase]) {
        NSString *en = @"en";
        en = [self bindFileWithArray:arrValues key:en];
        
        if ([arrValues containsObject:en]) {
            [languages addObject:@"Base"];
        }
    }
    
    [self dataFactoryWithLanguages:languages.copy language:nil codes:nil values:nil];
}

- (void)parseFileWithLanguage:(NSString *)language
                        codes:(NSArray *)codes
                       values:(NSArray *)values
{
 
    /**
     比较性添加
     */
    if (self.personalizeModel.compareToAdd) {
        for (NSString *localLanguagePath in self.marrLanguagePaths) {
            NSString *lan = [self _getLanguageFromLanguagePath:localLanguagePath];
            if ([lan isEqualToString:self.personalizeModel.baseLanguage]) {
                NSString *currentlocalizeName = self.mainVC.localizeNamesPopButton.titleOfSelectedItem;
                
                NSString *path = [NSString stringWithFormat:@"%@/%@.strings",localLanguagePath, currentlocalizeName];
                
                NSDictionary *dic = [self.mainExtendVM compareValuesWithFilePath:path codes:codes values:values];

                codes = dic[@"codes"];
                values = dic[@"values"];
                
                NSArray *nonCodes = dic[@"nonCodes"];
                NSMutableString *mstrTip = @"The following key is not found:    *********>\n".mutableCopy;
                
                for (NSString *code in nonCodes) {
                    [mstrTip appendString:code];
                    [mstrTip appendString:@"\n"];
                }
                
                [mstrTip appendString:@"********<<\n"];
                
                
                self.mainVC.tipText.string = mstrTip;
                
                break;
            }
        }
    }
    
    
    
    [self dataFactoryWithLanguages:nil language:language codes:codes values:values];
    
    if ([self _needAddBase]) {
        NSString *en = @"en";
        en = [self bindFileForKey:en value:language];
        
        if ([language isEqualToString:en]) {
            [self parseFileWithLanguage:@"Base" codes:codes values:values];
        }
    }
}



- (BOOL)_needAddBase
{
    NSInteger languageIndex = self.mainVC.languagesPopButton.indexOfSelectedItem;
    NSString *currentLanguage = self.dicLanguagesPlist[self.mainVC.languagesPopButton.titleOfSelectedItem];
    
    // 进行base的处理
    BOOL b0 = [[self.dicLanguagesPlist allValues] containsObject:@"Base"];
    BOOL b1 = languageIndex == 0 && b0;
    BOOL b2 = languageIndex != 0  && [currentLanguage isEqualToString:@"Base"] && b0;
    
    return (b1 || b2);
}

/**
 针对备份和添加数据的合并处理

 @param languages <#languages description#>
 @param language <#language description#>
 @param codes <#codes description#>
 @param values <#values description#>
 */
- (void)dataFactoryWithLanguages:(NSArray *)languages   // 代表备份
                        language:(NSString *)language   // 代表数据添加
                           codes:(NSArray *)codes
                          values:(NSArray *)values
{
    NSString *currentlocalizeName = self.mainVC.localizeNamesPopButton.titleOfSelectedItem;
    NSString *currentLanguage = self.dicLanguagesPlist[self.mainVC.languagesPopButton.titleOfSelectedItem];
    // 本地语言和文档进行一致性匹配
    currentLanguage = [self bindFileForKey:currentLanguage value:language];
    
    NSInteger languageIndex = self.mainVC.languagesPopButton.indexOfSelectedItem;
    //    NSMutableArray *residueKey = allKeys.mutableCopy;
    NSArray *languagePlistValues = [self.dicLanguagesPlist allValues];
    
    /**
     count 和 countCompleted 仅用于备份时数量的统计，理论上这种写法是不安全的，但同样理论上这种非安全的情况不太可能发生
     */
    __block int count = 0;
    __block int countCompleted = 0;
    
    __block BOOL canBeAdd = NO;  // 是否可以被添加
    
    for (NSString *localLanguagePath in self.marrLanguagePaths) {
        
        /**
         下面注释的部分用来清空文件内容，慎用
         */
//        NSString *filePath2 = [NSString stringWithFormat:@"%@/%@.strings",localLanguagePath ,currentlocalizeName];
//        [[FDDataManager share] truncateFileWithPath:filePath2];
//        continue;
        
        // 这里其实是本地代码的文件夹名，比如 id-ID
        NSString *lan = [self _getLanguageFromLanguagePath:localLanguagePath];
 
        // 本地如果还没有建立这一个语言，跳过
        if (![languagePlistValues containsObject:lan]) {
            continue;
        }

        // 本地语言和文档进行一致性匹配
        lan = [self bindFileForKey:lan value:language];
        
        if (languageIndex != 0 && ![currentLanguage isEqualToString:lan]) {
            continue;
        }

        
        if (languages) {
            if (![languages containsObject:lan]) {
                continue;
            }
        }
        else {
            if (![[language lowercaseString] isEqualToString:[lan lowercaseString]]) {
                continue;
            }
        }
        
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.strings",localLanguagePath ,currentlocalizeName];
        
        /**
         数据处理
         */
        count ++;
        
        if (languages) {
            
            // 备份操作
            [[FDUndoManager share] saveFileWithFilePath:[NSString stringWithFormat:@"%@/%@.strings", localLanguagePath, currentlocalizeName] result:^(BOOL result) {
                
                countCompleted ++;
//                NSLog(@"__________  %lu  %lu %lu",count, countCompleted, languages.count);
                if (countCompleted >= count) {
                    //                        NSLog(@"__________2  %lu",count);
                    
                    dispatch_semaphore_signal(self.semaphore);
                    
                }
            }];
        }
        else {
            self.addLanguageCount ++;
            canBeAdd = YES;
            
            [[FDDataManager share] writeToFileQueue:filePath
                                              codes:codes
                                             values:values
                                        codeComment:self.mainVC.codeCommentTextView.string
                                             result:^(BOOL result) {
                                                 
                                                 countCompleted ++;
                                                 [self _setTipViewWithLanguage:language result:result];
                                                 
                                                 if (countCompleted >= count) {
                                                     self.isAdding = NO;
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         self.mainVC.addLocalizeButton.enabled = YES;
                                                     });
                                                     
                                                     dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
                                                 }
                                                 
                                             }];
        }
        
        
    }
    
    if (languages && count == 0) {
        // 把内存缓存走掉
        dispatch_semaphore_signal(self.semaphore);
        self.mainVC.tipText.string = @"There is no language to add. -- 0";
    }
    
    if (codes && !canBeAdd) {
        [self _setTipViewWithLanguage:language result:NO];
    }
}

// 添加结束
- (void)parseFinish
{
    // 如果没有添加则释放掉
    if (self.addLanguageCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainVC.tipText.string = @"There is no language to add.  -- 1";
            self.mainVC.addLocalizeButton.enabled = YES;
        });
        
        
        self.isAdding = NO;
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    }
    
    self.addLanguageCount = 0;
}

- (void)parseException:(NSException *)exception
{
    NSLog(@"parseException = %@",exception);
}

- (NSDictionary *)_addBaseValues:(NSDictionary *)dicValues
{
    NSMutableDictionary *mdic = dicValues.mutableCopy;
    if (dicValues[@"en"]) {
        [mdic setObject:dicValues[@"en"] forKey:@"Base"];
    }
    
    return mdic.copy;
}

- (void)_setTipViewWithLanguage:(NSString *)language result:(BOOL)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.mainVC.tipText.string containsString:@"Importing"]) {
            self.mainVC.tipText.string = @"";
        }
        
        if (result) {
            self.mainVC.tipText.string = [NSString stringWithFormat:@"%@\n【%@】Add Success",self.mainVC.tipText.string, language];
        }
        else {
            self.mainVC.tipText.string = [NSString stringWithFormat:@"%@\n- ---- ---- ---- ---- 【%@】Unadded",self.mainVC.tipText.string, language];
        }
    });
}



/**
 本地语言一致性匹配

 @param key key
 @return 结果
 */
- (NSString *)bindFileForKey:(NSString *)key value:(NSString *)value
{
    if (self.diclLanguageBindFile[key]) {
        NSString *result = [FDPredicateManager filterStringWithArray:self.diclLanguageBindFile[key] string:value];
        if (result) return result;
    }
    
    return key;
}


- (NSString *)bindFileWithArray:(NSArray *)array key:(NSString *)key
{
    if (self.diclLanguageBindFile[key]) {
        NSString *result = [FDPredicateManager filterStringWithArray1:self.diclLanguageBindFile[key] array2:array];
        if (result) return result;
    }
    
    return key;
}



#pragma mark - action
- (void)addLocalize
{
    // 本地化语言比较
    if (self.personalizeModel.compare) {
        
        [self compareLocalization];
        return;
    }
    
    if (self.isAdding) {
        return;
    }
    
    self.isAdding = YES;
    self.mainVC.addLocalizeButton.enabled = NO;
    self.addLanguageCount = 0;
    
    self.tipString = @"".mutableCopy;

//    [FDFileManager parsLanguages:self
//                            path:self.localizeFilePath
//                            left:self.personalizeModel.leftRow
//                           right:self.personalizeModel.rightRow
//                           limit:self.personalizeModel? self.personalizeModel.addWithRange : NO];
//
//    dispatch_async(self.queue, ^{
////        NSLog(@"__________3  ");
//        dispatch_async(dispatch_get_main_queue(), ^{

            NSLog(@"开始添加！！！！！！");
            
            [FDFileManager parsFile:self
                               path:self.localizeFilePath
                               left:self.personalizeModel.leftRow
                                top:self.personalizeModel.leftRowIndex
                              right:self.personalizeModel.rightRow
                             bottom:self.personalizeModel.rightRowIndex
                              limit:self.personalizeModel? self.personalizeModel.addWithRange : NO];
//
//            dispatch_semaphore_signal(self.semaphore);
//        });
//    });

}

- (void)compareLocalization
{
    NSString *currentLanguage = self.dicLanguagesPlist[self.mainVC.languagesPopButton.titleOfSelectedItem];
    NSString *currentlocalizeName = self.mainVC.localizeNamesPopButton.titleOfSelectedItem;
    
    NSString *baseLanguage = self.personalizeModel.baseLanguage;
    NSString *selectLanguage;
    NSString *basePath;
    NSString *selectPath;
    
    NSMutableString *tipString = [NSMutableString string];
    
    basePath = self.marrLanguagePaths.firstObject;
    basePath = [basePath stringByDeletingLastPathComponent];
    basePath = [NSString stringWithFormat:@"%@/%@.lproj/%@.strings",basePath, baseLanguage, currentlocalizeName];
    
    for (NSString *localLanguagePath in self.marrLanguagePaths) {
        NSString *lan = [self _getLanguageFromLanguagePath:localLanguagePath];
        
        if (self.mainVC.languagesPopButton.indexOfSelectedItem == 0) {
            if (![lan isEqualToString:self.personalizeModel.baseLanguage]) {
                selectPath = [NSString stringWithFormat:@"%@/%@.strings",localLanguagePath, currentlocalizeName];
                selectLanguage = lan;
            }
        }
        else if ([lan isEqualToString:currentLanguage]) {
            selectPath = [NSString stringWithFormat:@"%@/%@.strings",localLanguagePath, currentlocalizeName];
            selectLanguage = lan;
        }
        
        if (basePath && selectPath) {
            
            /***********  控制台赋值v  *************/
            NSDictionary *dic = [self.mainExtendVM compareValuesWithFilePath_1:basePath filePath_2:selectPath];
            
            NSArray *onlyLocal_1 = dic[@"onlyLocal_1"];
            NSArray *onlyLocal_2 = dic[@"onlyLocal_2"];
            
            [tipString appendFormat:@"\n┏       ┓\n     %@  \n┗       ┛\n———————————————————————————————————\n",selectLanguage];
            
            [tipString appendFormat:@"▧Follow key is only in %@ :▽\n-----------------------\n",baseLanguage];
            for (NSString *key in onlyLocal_1) {
                [tipString appendFormat:@"%@\n",key];
            }
            
            [tipString appendFormat:@"\n\n▩Follow key is only in %@ :▽\n-----------------------\n",selectLanguage];
            for (NSString *key in onlyLocal_2) {
                [tipString appendFormat:@"%@\n",key];
            }
            /***********  控制台赋值^  *************/
            
            if (self.mainVC.languagesPopButton.indexOfSelectedItem != 0) {
                break;
            }
        }
    }
    

    self.mainVC.tipText.string = tipString.copy;
}

- (void)backup
{
    [FDFileManager parsLanguages:self
                            path:self.localizeFilePath
                            left:self.personalizeModel.leftRow
                           right:self.personalizeModel.rightRow
                           limit:self.personalizeModel? self.personalizeModel.addWithRange : NO];
}

- (void)undo
{
    [[FDUndoManager share] undoFileWithFilePathArray:self.marrLanguagePaths.copy];
}

- (void)documentWrapping
{
    [FDFileManager parsFile:self path:self.localizeFilePath];
}

#pragma mark - data processing
- (NSString *)_getLanguageFromLanguagePath:(NSString *)path
{
    NSString *lastComponent = [path componentsSeparatedByString:@"/"].lastObject;
    NSString *language = [lastComponent componentsSeparatedByString:@"."].firstObject;

    return language;
}

- (NSDictionary *)appendCodeComment:(NSDictionary *)dictionary
{
    if (!self.mainVC.codeCommentTextView.string) {
        return dictionary;
    }
    
    NSMutableDictionary *mdic = dictionary.mutableCopy;
    NSArray *keys = [dictionary allKeys];
    
    for (NSString *key in keys) {
        mdic[key] = [NSString stringWithFormat:@"%@\n%@",self.mainVC.codeCommentTextView.string, mdic[key]];
    }
    
    return mdic.copy;
}

#pragma mark - lazy load

- (void)setLocalLanguages
{
    [self _setLanguagesPlist];
    [self _setLanguageBindFilePlist];
}

- (void)_setLanguagesPlist
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Languages.plist"];
    NSDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    self.dicLanguagesPlist = dic;
}

- (NSDictionary *)getLanguagesPlist
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Languages.plist"];
    NSDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    return dic;
}

- (void)_setLanguageBindFilePlist
{
    NSString *path2 = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LanguageBindFile.plist"];
    NSDictionary *dic2 = [[NSMutableDictionary alloc] initWithContentsOfFile:path2];
    self.diclLanguageBindFile = dic2;
}

- (NSMutableArray *)marrLanguagePaths
{
    if (!_marrLanguagePaths) {
        _marrLanguagePaths = [[NSMutableArray alloc] init];;
    }
    return _marrLanguagePaths;
}

- (NSMutableArray *)marrLocalizeNames
{
    if (!_marrLocalizeNames) {
        _marrLocalizeNames = [[NSMutableArray alloc] init];;
    }
    return _marrLocalizeNames;
}

- (NSMutableString *)tipString
{
    if (!_tipString) {
        _tipString = [NSMutableString string];
    }
    
    return _tipString;
}


@end
