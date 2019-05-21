//
//  CXRegexHelper.h
//  FDLocalizeder
//
//  Created by chuxiao on 2019/5/11.
//  Copyright © 2019 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CXRegexHelper : NSObject

+ (NSString *)getStringWithRegex:(NSString *)reg oriString:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
