//
//  CXConsoleViewModel.m
//  FDLocalizeder
//
//  Created by chuxiao on 2019/5/14.
//  Copyright © 2019 mob.com. All rights reserved.
//

#import "CXConsoleViewModel.h"
#import "FDMainViewModel.h"
#import "FDViewController.h"

@interface CXConsoleViewModel ()
{
    NSString *_strConsole;
}

@property (nonatomic, strong) NSTextView *tipText;


@end

static dispatch_queue_t _concurrentQueue;

@implementation CXConsoleViewModel

- (instancetype) init
{
    if (self = [super init]) {
        self.tipText = self.mainVM.mainVC.tipText;
        _concurrentQueue = dispatch_queue_create("com.FDLocalizederConsole.syncQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSString *)strConsole
{
    __block NSString *tempStrConsole;
    dispatch_sync(_concurrentQueue, ^{
        tempStrConsole = self.strConsole;
    });
    return tempStrConsole;
}

- (void)setStrConsole:(NSString *)strConsole
{
    dispatch_barrier_async(_concurrentQueue, ^{
        self.mstrConsole = [strConsole copy];
//        [self.mainVM.mainVC.tipText performSelectorOnMainThread:@selector(setString:) withObject:strConsole waitUntilDone:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainVM.mainVC.tipText.string = strConsole;
        });
    });
}



@end
