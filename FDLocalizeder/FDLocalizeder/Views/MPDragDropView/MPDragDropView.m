//
//  MPDragDropView.m
//  MobPods
//
//  Created by chuxiao on 2017/6/20.
//  Copyright © 2017年 mob.com. All rights reserved.
//

#import "MPDragDropView.h"

@implementation MPDragDropView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

//有时候初始化frame不响应，所有在awakeFromNib中设置只添加对文件进行监听
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /***
         第一步：帮助view注册拖动事件的监听器，可以监听多种数据类型，这里只列出比较常用的：
         NSStringPboardType         字符串类型
         NSFilenamesPboardType      文件
         NSURLPboardType            url链接
         NSPDFPboardType            pdf文件
         NSHTMLPboardType           html文件
         ***/
        //这里我们只添加对文件进行监听，如果拖动其他数据类型到view中是不会被接受的
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    
    return self;
}
-(void) awakeFromNib
{
    //这里我们只添加对文件进行监听，如果拖动其他数据类型到view中是不会被接受的
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

//
-(NSDragOperation) draggingEntered:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pb =[sender draggingPasteboard];
    NSArray *array=[pb types];
    if ([array containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

//
-(BOOL) prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pb =[sender draggingPasteboard];
    NSArray *list =[pb propertyListForType:NSFilenamesPboardType];
    
    NSMutableArray *marrList = [NSMutableArray array];
    for (NSString *path in list) {
        if ([[path lastPathComponent] hasSuffix:@".xlsx"] ||
//            [[path lastPathComponent] hasSuffix:@".xls"] ||
            [[path lastPathComponent] hasSuffix:@".xcodeproj"]) {
            [marrList addObject:path];
        }
        
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory: &isDir]
            && isDir) {
            
            if (isDir) {
                [marrList addObject:path];
            }
        }
    }
    
    
    NSLog(@"地址是 %@",marrList);
    if (self.delegate && [self.delegate respondsToSelector:@selector(doGetDragDropArrayFiles:)]) {
        [self.delegate doGetDragDropArrayFiles:marrList];
    }
    return YES;
}

-(BOOL) performDragOperation:(id<NSDraggingInfo>)sender
{
    // 返回YES,拖放文件没有回退动作轨迹，返回NO，则有回退动作轨迹
    return YES;
}

@end
