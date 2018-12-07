//
//  FDImageView.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/15.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDImageView.h"
#import "SCSelectionBorder.h"

@interface FDImageView ()
@property (strong, readwrite) SCSelectionBorder *cropMarker;
@end

@implementation FDImageView

- (BOOL)isFlipped{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.cropMarker = [[SCSelectionBorder alloc] init];
        self.cropMarker.selectedRect = NSMakeRect(0, 0, 100, 100);
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.cropMarker = [[SCSelectionBorder alloc] init];
        self.cropMarker.selectedRect = NSMakeRect(0, 0, 100, 100);
    }
    return self;
}

- (void)awakeFromNib
{
//    self.image = [NSImage imageNamed:@"trails.jpg"];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [self.cropMarker drawContentInView:self];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint lastLocation = [self convertPoint:theEvent.locationInWindow fromView:nil];
    [self.cropMarker selectAndTrackMouseWithEvent:theEvent atPoint:lastLocation inView:self];

//    if ([self.delegate respondsToSelector:@selector(selectRect:)]) {
        [self.delegate selectRect:self.cropMarker.selectedRect];
//    }
}


@end
