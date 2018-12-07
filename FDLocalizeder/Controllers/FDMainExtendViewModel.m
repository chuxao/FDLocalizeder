//
//  FDMainExtendViewModel.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/7/13.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDMainExtendViewModel.h"
#import "FDFileManager.h"
#import "FDMainViewModel.h"
#import "FDLanguagePopoverViewController.h"

@implementation FDMainExtendViewModel

- (void)compareStrings
{
    [FDFileManager parsFileWithPath:self.mainVM.localizeFilePath
                             column:self.mainVM.personalizeModel.leftRow
                                top:self.mainVM.personalizeModel.leftRowIndex
                             bottom:self.mainVM.personalizeModel.rightRowIndex
                            success:^(NSArray<NSString *> *codes) {
        
                                
                                
    }];
}


- (NSDictionary *)compareValuesWithFilePath:(NSString *)filePath
                            codes:(NSArray *)codes
                           values:(NSArray *)values
{
    NSArray *localKeys = [self _parseLocalfileToArray:filePath];
    
    NSMutableArray *inCodes = [NSMutableArray array];
    NSMutableArray *inValues = [NSMutableArray array];
    NSMutableArray *nonInCodes = [NSMutableArray array];
    
    for (NSString *key in localKeys) {
        if ([codes containsObject:key]) {
            [inCodes addObject:key];
            [inValues addObject:values[[codes indexOfObject:key]]];
        }else {
            [nonInCodes addObject:key];
        }
    }
    
    return @{@"codes"       : inCodes,
             @"values"      : inValues,
             @"nonCodes"    : nonInCodes
             };
}

- (NSDictionary *)compareValuesWithFilePath_1:(NSString *)filePath_1
                                   filePath_2:(NSString *)filePath_2
{
    NSArray *localKeys_1 = [self _parseLocalfileToArray:filePath_1];
    NSArray *localKeys_2 = [self _parseLocalfileToArray:filePath_2];
    
    NSMutableArray *onlyLocal_1 = localKeys_1.mutableCopy;
    NSMutableArray *onlyLocal_2 = localKeys_2.mutableCopy;
    
    for (NSString *key in localKeys_1) {
        if ([localKeys_2 containsObject:key]) {
            [onlyLocal_1 removeObject:key];
            [onlyLocal_2 removeObject:key];
        }
    }
    
    return @{@"onlyLocal_1" : onlyLocal_1.copy,
             @"onlyLocal_2" : onlyLocal_2.copy};
}

- (NSArray *)_parseLocalfileToArray:(NSString *)filePath
{
    NSDictionary *dicContent = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:kCFStringEncodingUTF8 error:nil];
    NSArray *allKeys = [dicContent allKeys];
    
    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
    
    int count = 0;
    for (NSString * key in allKeys) {
        
        NSString *key_2 = [NSString stringWithFormat:@"\"%@\"",key];
        NSRange range = [content rangeOfString:key_2];
        
        [mdic setObject:key forKey:@(range.location)];
//        NSLog(@"%lu",range.location);
        count ++;
//        NSLog_G(@"%i  %lu  %lu", count, [mdic allKeys].count, range.location);
    }
    
    NSArray *arrLocations = [mdic allKeys];
    arrLocations = [arrLocations sortedArrayUsingSelector:@selector(compare:)];
    
    
    NSMutableArray *marrResult = [NSMutableArray array];
    NSMutableArray *allKeys_2 = allKeys.mutableCopy;
    for (NSNumber *key in arrLocations) {
        [marrResult addObject:mdic[key]];
        [allKeys_2 removeObject:key];
    }
    
    [marrResult addObjectsFromArray:allKeys_2.copy];
    
    return marrResult;
}



@end
