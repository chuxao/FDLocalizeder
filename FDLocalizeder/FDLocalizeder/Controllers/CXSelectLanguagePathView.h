//
//  CXSelectLanguagePathView.h
//  FDLocalizeder
//
//  Created by chuxiao on 2019/5/22.
//  Copyright © 2019 mob.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

/**
 没有办法，先弄个单例
 */
@interface CXSelectLanguageManager : NSObject

+ (instancetype)manager;

@property (nonatomic, copy) NSArray *languagesPaths;

@end


@interface CXSelectLanguagePathView : NSView

@property (nonatomic, copy) NSArray *languagesPaths;

- (void)settingLanguagesPaths:(NSArray *)languagesPaths;

- (instancetype)initWithLanguagesPaths:(NSArray *)languagesPaths;

@end

NS_ASSUME_NONNULL_END
