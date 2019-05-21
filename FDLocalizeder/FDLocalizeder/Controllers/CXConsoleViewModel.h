//
//  CXConsoleViewModel.h
//  FDLocalizeder
//
//  Created by chuxiao on 2019/5/14.
//  Copyright © 2019 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FDMainViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface CXConsoleViewModel : NSObject

@property (nonatomic, weak) FDMainViewModel *mainVM;

@property (nonatomic, copy) NSString *strConsole;

@property (nonatomic, strong) NSMutableString *mstrConsole;

@end

NS_ASSUME_NONNULL_END
