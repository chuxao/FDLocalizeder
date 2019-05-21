//
//  CXSpecialCharacterConversion.h
//  FDLocalizeder
//
//  Created by chuxiao on 2019/5/10.
//  Copyright © 2019 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CXSpecialCharacterConversion : NSObject

+ (NSString *)replaceSpecialCharacters:(NSString *)string;

+ (NSString *)replaceSpecialCharactersForRegex:(NSString *)string;


@end

NS_ASSUME_NONNULL_END
