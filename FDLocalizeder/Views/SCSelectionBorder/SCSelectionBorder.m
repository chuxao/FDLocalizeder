//
//  SCSelectionBorder.m
//  SCToolkit
//
//  Created by Vincent Wang on 12/8/11.
//  Copyright (c) 2011 Vincent S. Wang. All rights reserved.
//

#import "SCSelectionBorder.h"

// The handles that graphics draw on themselves are 10 point by 10 point rectangles.
const CGFloat SCSelectionBorderHandleWidth = 10.0f;
const CGFloat SCSelectionBorderHandleHalfWidth = 10.0f / 2.0f;

@interface SCSelectionBorder (SCSelectionBorderPrivate)
@property (readonly, copy) NSBezierPath *bezierPathForDrawing;
- (NSRect)frameRectForGraphicBounds:(NSRect)rect isLockedAspect:(BOOL)yesOrNo;
- (NSRect)frameRectForGraphicBounds:(NSRect)rect isLockedAspect:(BOOL)yesOrNo usingHandle:(SCSelectionBorderHandle)handle inView:(NSView *)view;
@end

@interface SCSelectionBorder ()

@property (readwrite, assign, getter = isDrawingHandles) BOOL drawingHandles;

- (void)_init;

//drawing
- (void)drawHandlesInView:(NSView *)aView;
- (void)drawHandleInView:(NSView *)aView atPoint:(NSPoint)aPoint;
//http://en.wikipedia.org/wiki/Schlemiel_the_Painter%27s_algorithm
//http://stackoverflow.com/questions/2717372/making-a-grid-in-an-nsview
- (void)drawGridsInRect:(NSRect)aRect lineNumber:(unsigned int)num;

/** Mostly a simple question of if frame contains point, but also return yes if the point is in one of our selection handles */

- (BOOL)mouse:(NSPoint)mousePoint
    isInFrame:(NSRect)frameRect
       inView:(NSView *)view
       handle:(SCSelectionBorderHandle *)outHandle;

//layout
- (BOOL)isPoint:(NSPoint)point withinHandle:(SCSelectionBorderHandle)handle frameRect:(NSRect)bounds;
- (BOOL)isPoint:(NSPoint)point withinHandleAtPoint:(NSPoint)handlePoint;

//layout
- (void)translateByX:(CGFloat)deltaX y:(CGFloat)deltaY inView:(NSView *)view;
- (void)moveWithEvent:(NSEvent *)theEvent atPoint:(NSPoint)where inView:(NSView *)view;
- (void)resizeWithEvent:(NSEvent *)theEvent byHandle:(SCSelectionBorderHandle)handle atPoint:(NSPoint)where inView:(NSView *)view;
- (NSInteger)resizeByMovingHandle:(SCSelectionBorderHandle)handle toPoint:(NSPoint)where inView:(NSView *)view;

@end

@implementation SCSelectionBorder

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    [self _init];
    return self;
}

- (void)_init
{
    _selectedRect = NSZeroRect;
    _minSize = NSMakeSize(100, 100);
    _aspectRatio = NSMakeSize(1, 1);
    _borderWidth = 1.0;
    _gridLineNumber = 2;
    _drawingGrids = YES;
    _drawingFill = YES;
    _isDrawingHandles = YES;
    _drawingOffView = NO;
    _isLockingAspectRatio = NO;
    _dashStyle = kSCDashStyleDashed;
    [self setColors:[NSColor highlightColor]];
}

- (void)setColors:(NSColor *)aColor
{
    self.borderColor = aColor;
    self.fillColor = [self.borderColor colorWithAlphaComponent:0.2]; // Make it have an elegant transparent effect
}

- (void)drawContentInView:(NSView *)aView
{
    NSBezierPath *path = [self bezierPathForDrawing];
    if (path) {


        if (self.isDrawingFill) {
            // Finder Style - Fill Inside
            //            [self.fillColor set];
            //            [path fill];

            // iPhoto Style - Fill Outside
            NSRect selected = self.selectedRect;
            if (!NSIsEmptyRect(selected)) {
                //NSRect inset = NSInsetRect(selected, -1.0, -1.0); // do not fill on border
                NSRect inset = selected;

                NSBezierPath *cutout = [NSBezierPath bezierPathWithRect:NSInsetRect(aView.bounds, 1.0, 1.0)];
                [cutout appendBezierPathWithRect:inset];
                cutout.windingRule = NSEvenOddWindingRule;
                [self.fillColor set];
                [cutout fill];
                NSFrameRect(self.selectedRect);
            }
        }

        [self.borderColor set];
        [path stroke];

        //Stop drawing grids before I solve the coord issue.
        //        if (self.isDrawingGrids) {
        ////            //[NSBezierPath sc_drawGridsInRect:rect lineNumber:self.gridLineNumber];
        //            [self drawGridsInRect:self.selectedRect lineNumber:2];
        //        }

        if (self.isDrawingHandles) {
            [self drawHandlesInView:aView];
        }
    }
}

- (void)drawHandlesInView:(NSView *)aView
{
    // Draw handles at the corners and on the sides.
    NSRect b = self.selectedRect;
    if (self.isLockingAspectRatio) {
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMinX(b), NSMinY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMaxX(b), NSMinY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMinX(b), NSMaxY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMaxX(b), NSMaxY(b))];
    }
    else {
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMinX(b), NSMinY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMidX(b), NSMinY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMaxX(b), NSMinY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMinX(b), NSMidY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMaxX(b), NSMidY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMinX(b), NSMaxY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMidX(b), NSMaxY(b))];
        [self drawHandleInView:aView atPoint:NSMakePoint(NSMaxX(b), NSMaxY(b))];
    }
}

- (void)drawHandleInView:(NSView *)aView atPoint:(NSPoint)aPoint
{
    // Figure out a rectangle that's centered on the point but lined up with device pixels.
    NSRect handleBounds;
    handleBounds.origin.x = aPoint.x - SCSelectionBorderHandleHalfWidth;
    handleBounds.origin.y = aPoint.y - SCSelectionBorderHandleHalfWidth;
    handleBounds.size.width = SCSelectionBorderHandleWidth;
    handleBounds.size.height = SCSelectionBorderHandleWidth;
    handleBounds = [aView centerScanRect:handleBounds];

    // Draw the shadow of the handle.
    NSRect handleShadowBounds = NSOffsetRect(handleBounds, 1.0f, 1.0f);
    [[NSColor controlDarkShadowColor] set];
    NSRectFill(handleShadowBounds);

    // Draw the handle itself.
    [[NSColor knobColor] set];
    NSRectFill(handleBounds);

}

- (void)drawGridsInRect:(NSRect)aRect lineNumber:(unsigned int)num
{
    [[NSColor gridColor] set];

    float w = aRect.size.width;
    float h = aRect.size.height;
    float deltaX = NSMinX(aRect);
    float deltaY = NSMinY(aRect);

    for (unsigned int i = 1; i <= num; i++) {
        float x = w / (num + 1) * i; // why plus 1 with num?
        float y = h / (num + 1) * i; // example: when you see two vertical lines drawed on the view, literally, the view is divided into 3 pieces.
        [NSBezierPath strokeLineFromPoint:NSMakePoint(deltaX, y)
                                  toPoint:NSMakePoint(w - 1, y)];
        [NSBezierPath strokeLineFromPoint:NSMakePoint(x, deltaY)
                                  toPoint:NSMakePoint(x, h - 1)];
    }
}

// frameRect is the rect of the selection border
- (BOOL)mouse:(NSPoint)mousePoint isInFrame:(NSRect)frameRect inView:(NSView *)view handle:(SCSelectionBorderHandle *)outHandle
{
    BOOL result;
    result = [view mouse:mousePoint inRect:self.selectedRect];
    //    result = NSPointInRect(mousePoint, frameRect);
    //    result = NSPointInRect(mousePoint, self.selectedRect);

    // Search through the handles
    SCSelectionBorderHandle handle = (SCSelectionBorderHandle)[self handleAtPoint:mousePoint frameRect:self.selectedRect];

    if (outHandle) *outHandle = handle;

    return result;
}


#pragma mark -
#pragma mark Handle

- (NSInteger)handleAtPoint:(NSPoint)point frameRect:(NSRect)bounds
{
    // Check handles at the corners and on the sides.
    NSInteger result = kSCSelectionBorderHandleNone;
    if ([self isPoint:point withinHandle:kSCSelectionBorderUpperLeftHandle frameRect:bounds]) {
        result = kSCSelectionBorderUpperLeftHandle;
    }
    else if ([self isPoint:point withinHandle:kSCSelectionBorderUpperMiddleHandle frameRect:bounds]) {
        result = kSCSelectionBorderUpperMiddleHandle;
    }
    else if ([self isPoint:point withinHandle:kSCSelectionBorderUpperRightHandle frameRect:bounds]) {
        result = kSCSelectionBorderUpperRightHandle;
    }
    else if ([self isPoint:point withinHandle:kSCSelectionBorderMiddleLeftHandle frameRect:bounds]) {
        result = kSCSelectionBorderMiddleLeftHandle;
    }
    else if ([self isPoint:point withinHandle:kSCSelectionBorderMiddleRightHandle frameRect:bounds]) {
        result = kSCSelectionBorderMiddleRightHandle;
    }
    else if ([self isPoint:point withinHandle:kSCSelectionBorderLowerLeftHandle frameRect:bounds]) {
        result = kSCSelectionBorderLowerLeftHandle;
    }
    else if ([self isPoint:point withinHandle:kSCSelectionBorderLowerMiddleHandle frameRect:bounds]) {
        result = kSCSelectionBorderLowerMiddleHandle;
    }
    else if ([self isPoint:point withinHandle:kSCSelectionBorderLowerRightHandle frameRect:bounds]) {
        result = kSCSelectionBorderLowerRightHandle;
    }

    return result;
}

- (BOOL)isPoint:(NSPoint)point withinHandle:(SCSelectionBorderHandle)handle frameRect:(NSRect)bounds;
{
    NSPoint handlePoint = [self locationOfHandle:handle frameRect:bounds];
    BOOL result = [self isPoint:point withinHandleAtPoint:handlePoint];
    return result;
}

- (NSPoint)locationOfHandle:(SCSelectionBorderHandle)handle frameRect:(NSRect)bounds
{
    NSPoint result = NSZeroPoint;

    switch (handle)
    {
        case kSCSelectionBorderUpperLeftHandle:
            result = NSMakePoint(NSMinX(bounds), NSMinY(bounds));
            break;

        case kSCSelectionBorderUpperMiddleHandle:
            result = NSMakePoint(NSMidX(bounds), NSMinY(bounds));
            break;

        case kSCSelectionBorderUpperRightHandle:
            result = NSMakePoint(NSMaxX(bounds), NSMinY(bounds));
            break;

        case kSCSelectionBorderMiddleLeftHandle:
            result = NSMakePoint(NSMinX(bounds), NSMidY(bounds));
            break;

        case kSCSelectionBorderMiddleRightHandle:
            result = NSMakePoint(NSMaxX(bounds), NSMidY(bounds));
            break;

        case kSCSelectionBorderLowerLeftHandle:
            result = NSMakePoint(NSMinX(bounds), NSMaxY(bounds));
            break;

        case kSCSelectionBorderLowerMiddleHandle:
            result = NSMakePoint(NSMidX(bounds), NSMaxY(bounds));
            break;

        case kSCSelectionBorderLowerRightHandle:
            result = NSMakePoint(NSMaxX(bounds), NSMaxY(bounds));
            break;
        default:
            NSLog(@"Unknown handle");
            break;
    }

    return result;
}

- (BOOL)isPoint:(NSPoint)point withinHandleAtPoint:(NSPoint)handlePoint;
{
    // Check a handle-sized rectangle that's centered on the handle point.
    NSRect handleBounds;
    handleBounds.origin.x = handlePoint.x - SCSelectionBorderHandleHalfWidth;
    handleBounds.origin.y = handlePoint.y - SCSelectionBorderHandleHalfWidth;
    handleBounds.size.width = SCSelectionBorderHandleWidth;
    handleBounds.size.height = SCSelectionBorderHandleWidth;
    return NSPointInRect(point, handleBounds);
}

#pragma mark -
#pragma mark Tracking

- (void)selectAndTrackMouseWithEvent:(NSEvent *)theEvent atPoint:(NSPoint)mouseLocation inView:(NSView *)view
{
    // Check if the mouse location is inside the effective rect or on one of our handls
    SCSelectionBorderHandle handle;
    BOOL result = [self mouse:mouseLocation isInFrame:self.selectedRect inView:view handle:&handle];

    if (result && handle == kSCSelectionBorderHandleNone) {
        // select + moving
        [self moveWithEvent:theEvent atPoint:mouseLocation inView:view];
    }
    else if (result && handle != kSCSelectionBorderHandleNone) {
        // select + resizing
        [self resizeWithEvent:theEvent byHandle:handle atPoint:mouseLocation inView:view];
    }
    else {
        // instead of do nothing, we let the user resize the border...this can increase the senstivity...
        [self resizeWithEvent:theEvent byHandle:handle atPoint:mouseLocation inView:view];
    }
}

- (void)moveWithEvent:(NSEvent *)theEvent atPoint:(NSPoint)where inView:(NSView *)view
{
    self.drawingHandles = NO;

    // Keep tracking next mouse event till mouse up
    while (theEvent.type != NSLeftMouseUp) {
        theEvent = [view.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        NSPoint currentPoint = [view convertPoint:theEvent.locationInWindow fromView:nil];

        if (!NSEqualPoints(where, currentPoint)) {
            [self translateByX:(currentPoint.x - where.x) y:(currentPoint.y - where.y) inView:view];
            where = currentPoint;
            [view setNeedsDisplay:YES]; // redraw the view with the changes
        }
    }

    self.drawingHandles = YES;
}

- (void)translateByX:(CGFloat)deltaX y:(CGFloat)deltaY inView:(NSView *)view
{
    NSRect rect = NSOffsetRect(self.selectedRect, deltaX, deltaY);

    if (!self.canDrawOffView) {
        // we don't want the border going off the bounds of view
        NSRect bounds = view.bounds;
        if (rect.origin.x < 0) rect.origin.x = 0; // left edge
        if (rect.origin.y < 0) rect.origin.y = 0; // bottom edge
        CGFloat w = (rect.origin.x + rect.size.width);
        if (w > bounds.size.width) rect.origin.x = rect.origin.x - (w - bounds.size.width); // right edge
        CGFloat h = (rect.origin.y + rect.size.height);
        if (h > bounds.size.height) rect.origin.y = rect.origin.y - (h - bounds.size.height); // top edge
    }

    self.selectedRect = rect;
}

- (NSInteger)resizeByMovingHandle:(SCSelectionBorderHandle)handle toPoint:(NSPoint)where inView:(NSView *)view
{
    NSInteger newHandle = (NSInteger)handle;
    NSRect rect = self.selectedRect;
    NSRect bounds = view.bounds;

    if (!self.canDrawOffView) {
        // Don't go off the bounds of view
        if (where.x < 0) where.x = 0; // left edge
        // Don't go off the bounds of view
        if (where.x > NSMaxX(bounds)) where.x = NSMaxX(bounds); // right edge
        // Don't go off the view bounds
        if (where.y < 0) where.y = 0; // bottom edge
        // Don't go off the host view's bounds
        if (where.y > NSMaxY(bounds)) where.y = NSMaxY(bounds); // top edge
    }

    // Is the user changing the width of the graphic?
    if (handle == kSCSelectionBorderUpperLeftHandle || handle == kSCSelectionBorderMiddleLeftHandle || handle == kSCSelectionBorderLowerLeftHandle) {

        // Change the left edge of the graphic.
        rect.size.width = NSMaxX(rect) - where.x;
        rect.origin.x = where.x;
    }
    else if (handle == kSCSelectionBorderUpperRightHandle || handle == kSCSelectionBorderMiddleRightHandle || handle == kSCSelectionBorderLowerRightHandle) {

        // Change the right edge of the graphic.
        rect.size.width = where.x - rect.origin.x;
    }

    // Did the user actually flip the selection border over?
    if (rect.size.width < 0.0f) {
        // The handle is now playing a different role relative to the graphic.
        static NSInteger flippings[9];
        static BOOL flippingsInitialized = NO;
        if (!flippingsInitialized) {
            flippings[kSCSelectionBorderUpperLeftHandle] = kSCSelectionBorderUpperRightHandle;
            flippings[kSCSelectionBorderUpperMiddleHandle] = kSCSelectionBorderUpperMiddleHandle;
            flippings[kSCSelectionBorderUpperRightHandle] = kSCSelectionBorderUpperLeftHandle;
            flippings[kSCSelectionBorderMiddleLeftHandle] = kSCSelectionBorderMiddleRightHandle;
            flippings[kSCSelectionBorderMiddleRightHandle] = kSCSelectionBorderMiddleLeftHandle;
            flippings[kSCSelectionBorderLowerLeftHandle] = kSCSelectionBorderLowerRightHandle;
            flippings[kSCSelectionBorderLowerMiddleHandle] = kSCSelectionBorderLowerMiddleHandle;
            flippings[kSCSelectionBorderLowerRightHandle] = kSCSelectionBorderLowerLeftHandle;
            flippingsInitialized = YES;
        }

        newHandle = flippings[handle];

        // Make the selection border's width positive again.
        rect.size.width = 0.0f - rect.size.width;
        rect.origin.x -= rect.size.width;

        // flip horizontally
    }

    // Is the user changing the height of the graphic?
    if (handle == kSCSelectionBorderUpperLeftHandle || handle == kSCSelectionBorderUpperMiddleHandle || handle == kSCSelectionBorderUpperRightHandle) {

        // Change the top edge of the graphic.
        rect.size.height = NSMaxY(rect) - where.y;
        rect.origin.y = where.y;
    }
    else if (handle == kSCSelectionBorderLowerLeftHandle || handle == kSCSelectionBorderLowerMiddleHandle || handle == kSCSelectionBorderLowerRightHandle) {

        // Change the bottom edge of the graphic.
        rect.size.height = where.y - rect.origin.y;
    }


    // Did the user actually flip the selection border upside down?
    if (rect.size.height < 0.0f) {

        // The handle is now playing a different role relative to the graphic.
        static NSInteger flippings[9];
        static BOOL flippingsInitialized = NO;
        if (!flippingsInitialized) {
            flippings[kSCSelectionBorderUpperLeftHandle] = kSCSelectionBorderLowerLeftHandle;
            flippings[kSCSelectionBorderUpperMiddleHandle] = kSCSelectionBorderLowerMiddleHandle;
            flippings[kSCSelectionBorderUpperRightHandle] = kSCSelectionBorderLowerRightHandle;
            flippings[kSCSelectionBorderMiddleLeftHandle] = kSCSelectionBorderMiddleLeftHandle;
            flippings[kSCSelectionBorderMiddleRightHandle] = kSCSelectionBorderMiddleRightHandle;
            flippings[kSCSelectionBorderLowerLeftHandle] = kSCSelectionBorderUpperLeftHandle;
            flippings[kSCSelectionBorderLowerMiddleHandle] = kSCSelectionBorderUpperMiddleHandle;
            flippings[kSCSelectionBorderLowerRightHandle] = kSCSelectionBorderUpperRightHandle;
            flippingsInitialized = YES;
        }

        newHandle = flippings[handle];

        // Make the graphic's height positive again.
        rect.size.height = 0.0f - rect.size.height;
        rect.origin.y -= rect.size.height;

        // flip vertically
    }

    // Done
    self.selectedRect = [self frameRectForGraphicBounds:rect isLockedAspect:self.isLockingAspectRatio usingHandle:(SCSelectionBorderHandle)newHandle inView:view];

    // Done
    //self.selectedRect = rect;
    [view setNeedsDisplay:YES]; // redrawing the changes

    return newHandle;

}

- (void)resizeWithEvent:(NSEvent *)theEvent byHandle:(SCSelectionBorderHandle)handle atPoint:(NSPoint)where inView:(NSView *)view
{
    // continuously tracking mouse event and resizing while left mouse button is not up
    while (theEvent.type != NSLeftMouseUp) {
        theEvent = [view.window nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        NSPoint currentPoint = [view convertPoint:theEvent.locationInWindow fromView:nil];

        // Start resizing and tracking if the selection border is flipping vertically or horizontally
        handle = (SCSelectionBorderHandle)[self resizeByMovingHandle:handle toPoint:currentPoint inView:view];
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setIsLockingAspectRatio:(BOOL)isLockingAspectRatio
{
    [self willChangeValueForKey:@"isLockingAspectRatio"];
    _isLockingAspectRatio = isLockingAspectRatio;
    if (_isLockingAspectRatio) {
        // TODO: prevent the size change causing selection border been drawing off view
        self.selectedRect = [self frameRectForGraphicBounds:self.selectedRect isLockedAspect:YES];
    }
    [self didChangeValueForKey:@"isLockingAspectRatio"];
}

@end

@implementation SCSelectionBorder (SCSelectionBorderPrivate)

- (NSBezierPath *)bezierPathForDrawing
{
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:self.selectedRect];

    NSInteger dashCount = 0;
    CGFloat dashArray[3];
    switch (self.dashStyle) {
        case kSCDashStyleSolid:
            dashCount = 0;
            break;
        case kSCDashStyleDashed:
        {
            dashCount = 2;
            dashArray[0] = 5;
            dashArray[1] = 5;
        }
            break;
        case kSCDashStyleDashedAndDotted:
        {
            dashCount = 3;
            dashArray[0] = 8;
            dashArray[1] = 3;
            dashArray[2] = 8;
        }
    }

    if (dashCount != 0) [path setLineDash:dashArray count:dashCount phase:0.0];

    path.lineWidth = self.borderWidth;
    return path;
}

- (NSRect)frameRectForGraphicBounds:(NSRect)rect isLockedAspect:(BOOL)yesOrNo
{
    if (!yesOrNo) return rect;

    CGFloat ratio = self.aspectRatio.width / self.aspectRatio.height;
    rect.size.width = rect.size.height * ratio;

    return rect;
}

- (NSRect)frameRectForGraphicBounds:(NSRect)rect isLockedAspect:(BOOL)yesOrNo usingHandle:(SCSelectionBorderHandle)handle inView:(NSView *)view
{
    if (!yesOrNo) return rect;

    CGFloat ratio = self.aspectRatio.width / self.aspectRatio.height;

    if (handle == kSCSelectionBorderLowerLeftHandle) {
        rect.size.height = rect.size.width / ratio;
    }
    else if (handle == kSCSelectionBorderUpperLeftHandle) {
        rect.size.height = rect.size.width / ratio;
        rect.origin.y = NSMaxY(self.selectedRect) - rect.size.height;
    }
    else if (handle == kSCSelectionBorderUpperRightHandle || handle == kSCSelectionBorderLowerRightHandle) {
        rect.size.width = rect.size.height * ratio;
    }
    else {
        rect.size.width = rect.size.height * ratio;

    }

    if (!self.canDrawOffView) {
        //kSCSelectionBorderLowerLeftHandle
        if (NSMaxY(rect) > NSHeight(view.bounds)) {
            rect.size.height = rect.size.height - (NSMaxY(rect) - NSHeight(view.bounds));
            rect.size.width = rect.size.height * ratio;
        }

        //kSCSelectionBorderUpperLeftHandle
        if (rect.origin.y < 0) {
            rect.origin.y = 0;
        }

        //kSCSelectionBorderUpperRightHandle || kSCSelectionBorderLowerRightHandle
        if (NSMaxX(rect) > NSWidth(view.bounds)) {
            rect.size.width = rect.size.width - (NSMaxX(rect) - NSWidth(view.bounds));
            rect.size.height = rect.size.width / ratio;
        }
    }

    //    NSLog(@"X: %f", rect.origin.x);
    //    NSLog(@"Y: %f", rect.origin.y);
    //    NSLog(@"max x: %f", NSMaxX(rect));
    //    NSLog(@"max y: %f", NSMaxY(rect));
    //    NSLog(@"width: %f", rect.size.width);
    //    NSLog(@"height: %f", rect.size.height);
    //    NSLog(@"ratio: %f", rect.size.width / rect.size.height);

    return rect;
}

@end
