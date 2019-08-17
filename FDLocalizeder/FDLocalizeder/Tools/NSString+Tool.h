//
//  NSString+Tool.h
//  TelSalesAssistant
//
//  Created by chuxiao on 2017/12/25.
//  Copyright © 2017年 chuxiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tool)

+ (NSString *)timeFromTimeStep;
+ (NSString *)currentTimeStep;
+ (NSString *)timeFromTimeStepWithFormat:(NSString *)format;

- (NSDictionary *)getLastRangeStrWithFindText:(NSString *)findText;

@end
