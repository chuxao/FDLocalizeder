//
//  FDWriteFile.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/14.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDWriteFile.h"

@implementation FDWriteFile

-(id)init{
    self=[super init];
    if (!self) {
        return nil;
    }
    outputData=[[NSData alloc]init];
//    aNoteDb=[[NoteDb alloc]init];
    return self;
}
-(void)write{
    //NSLog(@"%@",self.aNoteDb);
    //沙盒路径
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //文件名字是note.txt
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"note.txt"];
    
    parentDirectoryPath = path;
    //数据源
    NSData *tmpdata ;//= [NSKeyedArchiver archivedDataWithRootObject:self.aNoteDb.noteList];
    
    //self.outputData=[[NSData alloc]initWithData:tmpdata];
    self.outputData=tmpdata;
    //位置从哪开始
    outputRange.location=0;
    //创建文件
    [[NSFileManager defaultManager] createFileAtPath:parentDirectoryPath
                                            contents:nil attributes:nil];
    //初始化输出流
    asyncOutputStream = [[NSOutputStream alloc] initToFileAtPath: parentDirectoryPath append: NO];
    //回调方法，
    [asyncOutputStream setDelegate: self];
    //异步处理，
    [asyncOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]  forMode:NSDefaultRunLoopMode];
    //打开异步输出流
    [asyncOutputStream open];
    
    
}
-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent{
    // NSLog(@"as");
    NSOutputStream *outputStream = (NSOutputStream*) theStream;
    BOOL shouldClose = NO;
    switch (streamEvent)
    {
        case NSStreamEventHasSpaceAvailable://读事件
        {
            //缓冲区
            uint8_t outputBuf [1];
            //长度
            outputRange.length = 1;
            //把数据放到缓冲区中
            [outputData getBytes:&outputBuf range:outputRange];
            //把缓冲区中的东西放到输出流
            [outputStream write: outputBuf maxLength: 1];
            //判断data数据是否读完
            if (++outputRange.location == [outputData length])
            {
                shouldClose = YES;
            }
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            //出错的时候
            NSError *error = [theStream streamError];
            if (error != NULL)
            {
//                UIAlertView *errorAlert = [[UIAlertView alloc]
//                                           initWithTitle: [error localizedDescription]
//                                           message: [error localizedFailureReason]
//                                           delegate:nil
//                                           cancelButtonTitle:@"OK"
//                                           otherButtonTitles:nil];
//                [errorAlert show];

            }
            shouldClose = YES;
            break;
        }
        case NSStreamEventEndEncountered:
            shouldClose = YES;
    }
    if (shouldClose)
    {
        //当出错或者写完数据，把线程移除
        [outputStream removeFromRunLoop: [NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        //最后关掉输出流
        [theStream close];
    }
    
}
-(void)dealloc{

}

@end
