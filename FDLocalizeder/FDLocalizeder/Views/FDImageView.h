//
//  FDImageView.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/15.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SCSelectionBorder;

@protocol FDImageSelectRectDelegate

@optional
- (void)selectRect:(NSRect)rect;

@end

@interface FDImageView : NSImageView
@property (strong, readonly) SCSelectionBorder *cropMarker;
@property (assign, nonatomic) id<FDImageSelectRectDelegate> delegate;

@end
