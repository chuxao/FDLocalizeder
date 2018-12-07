//
//  FDReadFile.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/14.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDReadFile.h"

@implementation FDReadFile

-(id)init{
    self=[super init];
    //aNoteDb=[[NoteDb alloc]init];
    resultData=[[NSMutableData alloc]init];
    return self;
}
-(void)read{
    //沙盒路径
    NSArray *paths= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //文件名
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"note.txt"];
    /*
     if(![[NSFileManager defaultManager]fileExistsAtPath:path]){
     //如果不存在，就新建
     WriteFile *file=[[WriteFile alloc]init];
     [file write];
     [file release];
     }else{
     NSLog(@"有note.txt文件");
     }
     */
    parentDirectoryPath = path;
    //异步输入流初始化，并把赋于地址
    asyncInputStream =
    [[NSInputStream alloc] initWithFileAtPath: parentDirectoryPath];
    //设置代理（回调方法、委托）
    [asyncInputStream setDelegate: self];
    //设置线程，添加线程，创建线程：Runloop顾名思义就是一个不停的循环，不断的去check输入
    [asyncInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSDefaultRunLoopMode];
    //打开线程
    [asyncInputStream open];
    
}
//追加数据
- (void)appendData:(NSData*)_data{
    [resultData appendData:_data];
}
//回调方法，不停的执行
-(void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent{
    BOOL shouldClose = NO;
    NSInputStream *inputStream = (NSInputStream*) theStream;
    //NSLog(@"as");
    switch (streamEvent)
    {
        case NSStreamEventHasBytesAvailable:
        {
            //读数据
            //读取的字节长度
            NSInteger maxLength = 128;
            //缓冲区
            uint8_t readBuffer [maxLength];
            //从输出流中读取数据，读到缓冲区中
            NSInteger bytesRead = [inputStream read: readBuffer
                                          maxLength:maxLength];
            //如果长度大于0就追加数据
            if (bytesRead > 0)
            {
                //把缓冲区中的数据读成data数据
                NSData *bufferData = [[NSData alloc]
                                      initWithBytesNoCopy:readBuffer
                                      length:bytesRead
                                      freeWhenDone:NO];
                //追加数据
                [self appendData:bufferData];
                //release掉data
            }
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            //读的时候出错了
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
        {
            shouldClose = YES;
            //数据读完就返回数据
            [self dataAtNoteDB];
            [theStream close];
        }break;
    }
    if (shouldClose)
    {
        //当文件读完或者是读到出错时，把线程移除
        [inputStream removeFromRunLoop: [NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
        //并关闭流
        [theStream close];
    }
}
-(void) dataAtNoteDB{
//    aNoteDb=nil;
//    aNoteDb=[[NoteDb alloc]init];
//    aNoteDb.noteList = [NSKeyedUnarchiver unarchiveObjectWithData:resultData];
    //NSLog(@"%@",aNoteDb);
    /*
     for (id tmp in  aNoteDb.noteList.noteArray)
     {
     NSLog(@"tmp = %@",tmp);
     }
     */
}
//- (NoteDb*)getNoteDb{
//    return self.aNoteDb;
//}
//-(void)dealloc{
//    [aNoteDb release];
//    [resultData release];
//    [super dealloc];
//}

@end
