//
//  MPTask.h
//  MobPods
//
//  Created by chuxiao on 16/11/8.
//  Copyright © 2016年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CMD_ECHO @"/bin/echo"
#define CMD_PYTHON @"/usr/bin/python"
#define CMD_LAUCH @"/usr/bin/open"
#define CMD_WHOAMI @"/usr/bin/whoami"
#define CMD_GIT @"/usr/bin/git"
#define CMD_SH @"/bin/sh"
#define CMD_CP @"/bin/cp"
#define CMD_MV @"/bin/mv"
#define CMD_CURL @"/usr/bin/curl"
#define CMD_RUBY @"/usr/bin/ruby"
#define CMD_MDFIND @"/usr/bin/mdfind"


//typedef enum : NSUInteger {
//    MPGitClone = 0,
//    MPGitPull,
//    MPGitLog,
//} MPGit;

@interface MPTask : NSObject{
    
    
}

/**
 *  获取对象实例
 *
 *  @return 对象
 */
//+ (MPTask *)task;

//@property (nonatomic, assign) MPGit commandType;

/**
 启动 NSTask，执行命令行指令

 @param lanunchPath   启动路径
 @param arguments     指令执行参数
 @param directoryPath 指令执行目录
 @param success       成功回调信息
 @param exception     参数错误异常
 */
+ (void)runTaskWithLanunchPath:(NSString *)lanunchPath
                     arguments:(NSArray <NSString *>*)arguments
          currentDirectoryPath:(NSString *)directoryPath
                     onSuccess:(void(^)(NSString *))success
                   onException:(void(^)(NSException *))exception;



@end
