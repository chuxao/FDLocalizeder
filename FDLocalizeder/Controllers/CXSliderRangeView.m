//
//  CXSliderRangeView.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/15.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "CXSliderRangeView.h"

@implementation CXSliderRangeView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

+(CXSliderRangeView *)acquireCustomView
{
    CXSliderRangeView *view = [[NSNib alloc] initWithNibNamed:@"CXSliderRangeView" bundle:nil];
    
    return view;
}
@end
