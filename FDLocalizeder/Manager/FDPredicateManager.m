//
//  FDPredicateManager.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/6/4.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDPredicateManager.h"

@implementation FDPredicateManager

+ (NSString *)filterStringWithArray:(NSArray *)array string:(NSString *)string
{
    // 谓词搜索
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == [cd] %@",string];
    NSArray *arrays =  [[NSArray alloc] initWithArray:[array filteredArrayUsingPredicate:predicate]];
    
    return arrays.firstObject;
}

/**
 获取两个数组相同的部分，这里区分大小写
 
 @param array1 <#array1 description#>
 @param array2 <#array2 description#>
 @return return value description
 */
+ (NSString *)filterStringWithArray1:(NSArray *)array1 array2:(NSArray *)array2
{
    // 谓词搜索
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self in [cd] %@",array2];
    NSArray *arrays =  [[NSArray alloc] initWithArray:[array1 filteredArrayUsingPredicate:predicate]];
    
    return arrays.firstObject;
}

@end
