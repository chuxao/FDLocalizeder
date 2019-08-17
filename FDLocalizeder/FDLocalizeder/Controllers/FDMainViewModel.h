//
//  FDMainViewModel.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/4.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FDViewController;
@class FDMainDataViewModel;
@class FDLanguagePersonalizeModel;
@class FDMainExtendViewModel;

@interface FDMainViewModel : NSObject

@property (nonatomic, weak) FDViewController *mainVC;
@property (strong, nonatomic) FDMainDataViewModel *mainDataVM;
@property (strong, nonatomic) FDMainExtendViewModel *mainExtendVM;

@property (nonatomic, strong) NSString *selectedProjectPath;
@property (nonatomic, strong) NSString *localizeFilePath;

@property (nonatomic, strong) NSMutableArray *marrLanguagePaths;
@property (nonatomic, strong) NSMutableArray *marrLocalizeNames;

@property (nonatomic, strong) NSDictionary *dicLanguagesPlist;
@property (nonatomic, strong) NSDictionary *diclLanguageBindFile;
@property (nonatomic, strong) NSDictionary *otherSetting;


/**
 自定义操作
 */
@property (strong, nonatomic) FDLanguagePersonalizeModel *personalizeModel;

/**
 获取LanguagesPlist
 */
- (NSDictionary *)getLanguagesPlist;

/**
 本地化添加操作
 */
- (void)addLocalize;

/**
 撤销操作
 */
- (void)undo;

/**
 备份
 */
- (void)backup;

/**
 文档换行处理
 
 **** 面向产品 ****
 */
- (void)documentWrapping;

/**
 导出至Excel
 */
- (void)exportToExcel;

/**
 添加部分语言时进行数据排除

 @param values 被排除的values
 */
- (void)transformDicLanguagesWithValueArray:(NSArray *)values;

@end
