//
//  SCSelectionBorder.h
//  SCToolkit
//
//  Created by Vincent Wang on 12/8/11.
//  Copyright (c) 2011 Vincent S. Wang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const CGFloat SCSelectionBorderHandleWidth;
extern const CGFloat SCSelectionBorderHandleHalfWidth;

typedef NS_ENUM(unsigned int, SCSelectionBorderHandle) {
    kSCSelectionBorderHandleNone        = 0,
    kSCSelectionBorderUpperLeftHandle   = 1,
    kSCSelectionBorderUpperMiddleHandle = 2,
    kSCSelectionBorderUpperRightHandle  = 3,
    kSCSelectionBorderMiddleLeftHandle  = 4,
    kSCSelectionBorderMiddleRightHandle = 5,
    kSCSelectionBorderLowerLeftHandle   = 6,
    kSCSelectionBorderLowerMiddleHandle = 7,
    kSCSelectionBorderLowerRightHandle  = 8,
};

enum
{
    kSCSelectionXResizeable     = 1U << 0,
    kSCSelectionYResizeable     = 1U << 1,
    kSCSelectionWidthResizeable = 1U << 2,
    kSCSelectionHeightResizeable= 1U << 3,
};


typedef NS_ENUM(NSInteger, SCDashStyle) {
    kSCDashStyleSolid = 0,
    kSCDashStyleDashed = 1,
    kSCDashStyleDashedAndDotted = 2,
};

NS_ASSUME_NONNULL_BEGIN;

@interface SCSelectionBorder : NSObject
{
@private
    //NSBezierPath Drawing Guideline - Dash Style Patterns
    //http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CocoaDrawingGuide/Paths/Paths.html
    SCDashStyle _dashStyle;
    //unsigned int _resizingMask;
}

@property (strong) NSColor *borderColor;
@property (nonatomic) CGFloat borderWidth;

@property (strong) NSColor *fillColor;
@property (assign, getter = isDrawingFill) BOOL drawingFill;

@property (nonatomic) NSRect selectedRect;
@property (assign) NSSize minSize;
@property (assign) NSSize aspectRatio;
@property (nonatomic, assign) BOOL isLockingAspectRatio;

@property (assign) unsigned int gridLineNumber;
@property (assign, getter = isDrawingGrids) BOOL drawingGrids;
@property (assign, getter = canDrawOffView) BOOL drawingOffView;
@property (assign) BOOL isDrawingHandles;
@property (assign) SCDashStyle dashStyle;

- (void)setColors:(NSColor *)aColor;

// Drawing
- (void)drawContentInView:(NSView *)aView;


// Handle checking
- (NSInteger)handleAtPoint:(NSPoint)point frameRect:(NSRect)bounds;
- (NSPoint)locationOfHandle:(SCSelectionBorderHandle)handle frameRect:(NSRect)bounds;

/**  track mouse event and decide whether to moving or resizing selection border itself
 @param theEvent a NSEvent
 */
- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent atPoint:(NSPoint)mouseLocation inView:(NSView *)view;

@end
NS_ASSUME_NONNULL_END;
