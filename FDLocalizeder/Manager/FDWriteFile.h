//
//  FDWriteFile.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/14.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDWriteFile : NSObject<NSStreamDelegate>{
    //文件地址
    NSString *parentDirectoryPath;
    //输出流，写数据
    NSOutputStream *asyncOutputStream;
    //写数据的内容
    NSData *outputData;
    //位置及长度
    NSRange outputRange;
    //数据的来源
//    NoteDb *aNoteDb;
}

@property (nonatomic,retain) NSData *outputData;
//@property (nonatomic,retain) NoteDb *aNoteDb;
//写数据
-(void)write;

@end
