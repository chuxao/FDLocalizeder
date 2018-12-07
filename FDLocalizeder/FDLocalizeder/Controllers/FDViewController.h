//
//  ViewController.h
//  FDLocalizeder
//
//  Created by chuxiao on 2018/4/25.
//  Copyright © 2018年 chuxiao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FDViewController : NSViewController

@property (weak) IBOutlet NSPopUpButton *localizeNamesPopButton;

@property (weak) IBOutlet NSPopUpButton *languagesPopButton;

@property (unsafe_unretained) IBOutlet NSTextView *tipText;

@property (unsafe_unretained) IBOutlet NSTextView *codeCommentTextView;

@property (weak) IBOutlet NSButton *addLocalizeButton;

@end

