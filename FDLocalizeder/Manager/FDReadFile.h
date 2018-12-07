//
//  FDReadFile.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/14.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDReadFile : NSObject<NSStreamDelegate>{
    //路径
    NSString *parentDirectoryPath;
    //异步输出流
    NSInputStream *asyncInputStream;
    //读出来的数据
    NSMutableData *resultData;
    //返回去的数据
//    NoteDb *aNoteDb;
}
//@property(nonatomic,retain)NoteDb *aNoteDb;
@property (nonatomic, retain) NSMutableData *resultData;
//开始读数据
-(void)read;
//读出来的数据追加到resultData上
- (void)appendData:(NSData*)_data;
//
- (void)dataAtNoteDB;
//返回去的数据
//- (NoteDb*)getNoteDb;

@end
