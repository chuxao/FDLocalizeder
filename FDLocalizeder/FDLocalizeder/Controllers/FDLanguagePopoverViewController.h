//
//  FDLanguagePopoverViewController.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/10.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/**
 自定义操作模型
 */
@interface FDLanguagePersonalizeModel : NSObject

// 自定义操作
@property (assign, nonatomic) BOOL addWithRange;
@property (assign, nonatomic) char leftRow;
@property (assign, nonatomic) char rightRow;
@property (assign, nonatomic) NSInteger leftRowIndex;
@property (assign, nonatomic) NSInteger rightRowIndex;

@property (assign, nonatomic) BOOL compare;
@property (assign, nonatomic) BOOL compareToAdd;
@property (nonatomic, assign) BOOL textSorting;
@property (nonatomic, assign) BOOL deleteLocalize;

@property (copy,   nonatomic) NSString *baseLanguage;

@end


@interface FDLanguagePopoverViewController : NSViewController

@property (strong, nonatomic) NSArray *arrLanguage;
@property (copy, nonatomic) void (^disAppearBlock)(NSArray <NSString *>*arrLanguage, FDLanguagePersonalizeModel *personalizeModel);
@property (copy, nonatomic) void (^undoBlock)();
@property (copy, nonatomic) void (^backupBlock)();
@property (copy, nonatomic) void (^documentWrappingBlcok)();
@property (copy, nonatomic) void (^closeBlock)();
@property (copy, nonatomic) void (^compareBlock)(FDLanguagePersonalizeModel *personalizeModel);
@property (nonatomic, copy) void (^exportToExcelBLock)();

@end
