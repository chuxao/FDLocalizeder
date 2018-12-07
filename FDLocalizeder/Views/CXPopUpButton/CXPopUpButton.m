//
//  CXPopUpButton.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/10.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "CXPopUpButton.h"

@implementation CXPopUpButton

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
-(BOOL) isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    //[super drawRect:dirtyRect];
    [[NSColor colorWithCalibratedRed: 255/255.0 green:255/255.0 blue:255/255.0 alpha:1] setFill];
    NSRectFill(dirtyRect);
    
    
    NSImage *image =[NSImage imageNamed:@"down"];
    NSRect rect =NSZeroRect;
    rect.size = [image size];
    NSPoint p = dirtyRect.origin;
    p.x +=dirtyRect.size.width-image.size.width;
    p.y +=(dirtyRect.size.height-image.size.height)/2;
    [image drawInRect:NSMakeRect(p.x, p.y, image.size.width, image.size.height) fromRect:rect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    //画横线
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line setLineWidth:1];
    [[NSColor colorWithCalibratedRed: 147/255.0 green:147/255.0 blue:147/255.0 alpha:0.5] setStroke];
    
    NSPoint endPoint = dirtyRect.origin;
    endPoint.x += dirtyRect.size.width;
    [line moveToPoint:dirtyRect.origin];
    [line lineToPoint:endPoint];
    [line stroke];
    
    [line moveToPoint:NSMakePoint(dirtyRect.origin.x, dirtyRect.origin.y+dirtyRect.size.height)];
    [line lineToPoint:NSMakePoint(endPoint.x,dirtyRect.origin.y+dirtyRect.size.height)];
    [line stroke];
    
    //画竖线
    [line moveToPoint:dirtyRect.origin];
    [line lineToPoint:NSMakePoint(dirtyRect.origin.x,dirtyRect.origin.y+dirtyRect.size.height)];
    [line stroke];
    
    [line moveToPoint:endPoint];
    [line lineToPoint:NSMakePoint(endPoint.x,dirtyRect.origin.y+dirtyRect.size.height)];
    [line stroke];
    
    //对选中的item设置勾选
    NSArray *array = [super itemArray];
    for(NSMenuItem *item in array)
    {
        if (item == [self selectedItem])
        {
            [item setState:NSOnState];
        }
        else
        {
            [item setState:NSOffState];
        }
        
    }
    
    NSString *title =[[super selectedItem] title];
    if (title == nil)
    {
        title = @"";
    }
    NSLog(@"title:%@",title);
    
    //获取字符串的宽度和高度
    NSSize titleSize = [title sizeWithAttributes:[NSDictionary dictionaryWithObject:[self font] forKey:NSFontAttributeName]];
    CGFloat titleY = dirtyRect.origin.y + (dirtyRect.size.height - titleSize.height)/2;
    
    NSRect rectTitle = dirtyRect;
    
    rectTitle.origin = NSMakePoint(10, titleY);
    
    rectTitle.size.height = titleSize.height;
    
    [title drawInRect:rectTitle withAttributes:nil];
}

@end
