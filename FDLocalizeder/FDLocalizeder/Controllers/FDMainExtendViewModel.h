//
//  FDMainExtendViewModel.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/7/13.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FDMainViewModel;

@interface FDMainExtendViewModel : NSObject

@property (nonatomic, weak) FDMainViewModel *mainVM;


- (void)compareStrings;

- (NSDictionary *)compareValuesWithFilePath:(NSString *)filePath
                            codes:(NSArray *)codes
                           values:(NSArray *)values;

- (NSDictionary *)compareValuesWithFilePath_1:(NSString *)filePath_1
                                   filePath_2:(NSString *)filePath_2;

@end
