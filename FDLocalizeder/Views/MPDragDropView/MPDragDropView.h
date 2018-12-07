//
//  MPDragDropView.h
//  MobPods
//
//  Created by chuxiao on 2017/6/20.
//  Copyright © 2017年 mob.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol DragDropViewDelegate;

@interface MPDragDropView : NSView

//设置代理
@property(assign) IBOutlet id<DragDropViewDelegate> delegate;

@end

@protocol DragDropViewDelegate <NSObject>
//设置代理方法
-(void) doGetDragDropArrayFiles:(NSArray*) fileLists;

@end
