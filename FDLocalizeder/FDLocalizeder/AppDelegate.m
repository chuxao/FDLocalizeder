//
//  AppDelegate.m
//  MacDemo
//
//  Created by chuxiao on 2018/5/2.
//  Copyright © 2018年 chuxiao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;//YES-窗口程序两者都关闭，NO-只关闭窗口；
}

@end

