//
//  ViewController.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/4/25.
//  Copyright © 2018年 chuxiao. All rights reserved.
//

#import "FDViewController.h"
#import "FDMainViewModel.h"
#import "FDMainExtendViewModel.h"
#import "FDProjectFileManager.h"
#import "FDLanguagePopoverViewController.h"
#import "CXSelectLanguagePathView.h"
#import "MyCustomAnimator.h"

@interface FDViewController ()
{
    
}

@property (nonatomic, strong) FDMainViewModel *mainVM;


@property (weak) IBOutlet NSButton *addFilePath;

@property (weak) IBOutlet NSImageView *icon_1;

@property (weak) IBOutlet NSImageView *icon_2;

@property (weak) IBOutlet NSView *popButtonBackView;

@property (weak) IBOutlet NSButton *popoverButton;

@property (strong, nonatomic) NSPopover *languagePopover;
@property (strong, nonatomic) FDLanguagePopoverViewController *LanguagePopoverVC;
@property (strong, nonatomic) FDLanguagePopoverViewController *extendVC;

@property (nonatomic, strong) CXSelectLanguagePathView *selectLanguagePathView;
@end


@implementation FDViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self _configUI];
    [self _setupData];
}

- (void)_configUI
{
    self.mainVM = [FDMainViewModel new];
    self.mainVM.mainVC = self;
//    self.codeCommentTextView.textColor = [NSColor colorWithRed:58/255.0 green:150/255.0 blue:35/255.0 alpha:1];
    
    self.codeCommentTextView.textColor = [NSColor colorWithWhite:0.5 alpha:1];
//    self.codeCommentTextView.font = [NSFont systemFontOfSize:12];
}

- (void)_setupData
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectLanguagePathNotification:)
                                                 name:@"SelectLanguagePathNotification"
                                               object:nil];
}


#pragma mark DragDropViewDelegate
-(void) doGetDragDropArrayFiles:(NSArray*) fileLists
{
    for (NSString *path in fileLists) {
        
        [self _setUIWithFilePath:path];
    }
}



#pragma mark - action

- (IBAction)_addLocalizeAction:(id)sender {
    
    if (!self.mainVM.marrLanguagePaths.count) {
        self.tipText.string = @"Please add Project Files.";
        
        return;
    }
    
    else if (!self.mainVM.marrLocalizeNames.count) {
        self.tipText.string = @"There is no directory to add.";
        
        return;
    }
    
    if (!self.mainVM.localizeFilePath.length){
        self.tipText.string = @"Please add a localization file.";
        
        return;
    }
    
    if (self.mainVM.personalizeModel.compareToAdd
        && self.languagesPopButton.indexOfSelectedItem == 0) {
        self.tipText.string = @"Please select only one language.";
        return;
    }
    
    [self.mainVM addLocalize];
}

- (IBAction)addFilePathAction:(id)sender {
    
    NSOpenPanel *filePanel = [NSOpenPanel openPanel];
    //    filePanel.canChooseFiles = YES;
    filePanel.canChooseDirectories = YES;
    filePanel.allowsMultipleSelection = YES;
    filePanel.allowedFileTypes = @[@"xcodeproj",@"xlsx"];
    //    filePanel.allowsOtherFileTypes = NO;
    
    NSWindow *window = [NSApplication sharedApplication].keyWindow;
    [filePanel beginSheetModalForWindow:window completionHandler:^(NSInteger result)
     {
         if (result == NSFileHandlingPanelOKButton)
         {
             
             NSError *error = nil;
             NSString *string = [NSString stringWithContentsOfURL:[filePanel URL] encoding:NSUTF8StringEncoding error:&error];
             
             NSString *filePath;
             
             if (!error)
             {

                 filePath = string;
             }
             else
             {
                 filePath = [error.userInfo objectForKey:@"NSFilePath"];
             }
             
             if (filePath) {
                 [self _setUIWithFilePath:filePath];
             }
             
         }
     }];
}

- (IBAction)popoverAction:(NSButton *)sender {
    
    [self _setButtonEnable:NO];
    
    id animator = [[MyCustomAnimator alloc] init];
    [self presentViewController:self.extendVC animator:animator];
    
//    if (self.languagePopover.isShown) {
//        [self.languagePopover close];
//        return;
//    }
    
    
//    NSButton *button = sender;
    
//    [self.languagePopover showRelativeToRect:button.bounds ofView:button preferredEdge:NSRectEdgeMaxY];
    
    __weak typeof(self) weakSelf = self;
    self.extendVC.disAppearBlock = ^(NSArray <NSString *>*arrLanguage,
                                              FDLanguagePersonalizeModel *personalizeModel){
        
        // UI关闭操作
//        if (weakSelf.languagePopover.isShown) {
//            [weakSelf.languagePopover close];
//        }
        [weakSelf _setButtonEnable:YES];
        
        // 缓存语言变换处理
        if (arrLanguage) {
            [weakSelf.languagesPopButton selectItemAtIndex:0];
        }
        
        [weakSelf.mainVM transformDicLanguagesWithValueArray:arrLanguage];
        
        // 自定义化操作
        weakSelf.mainVM.personalizeModel = personalizeModel;
        
        if (personalizeModel.compare) {
            weakSelf.tipText.selectable = YES;
        }
        else {
            weakSelf.tipText.selectable = NO;
        }
        
        if (personalizeModel.compare) {
            weakSelf.addLocalizeButton.title = @"Compare localization";
        }
        
        else if (personalizeModel.compareToAdd) {
            weakSelf.addLocalizeButton.title = @"Compare to add";
        }
        
        else if (personalizeModel.textSorting) {
            weakSelf.addLocalizeButton.title = @"Text Sorting";
        }
        
        else if (personalizeModel.deleteLocalize) {
            weakSelf.addLocalizeButton.title = @"Delete Localize";
        }
        
        else {
            weakSelf.addLocalizeButton.title = @"Click on add";
        }
    };
    
    self.extendVC.undoBlock = ^ {
//        if (weakSelf.languagePopover.isShown) {
//            [weakSelf.languagePopover close];
//        }
        [weakSelf _setButtonEnable:YES];
        
        [weakSelf.mainVM undo];
    };
    
    self.extendVC.backupBlock = ^ {
//        if (weakSelf.languagePopover.isShown) {
//            [weakSelf.languagePopover close];
//        }
        [weakSelf _setButtonEnable:YES];
        
        [weakSelf.mainVM backup];
    };
    
    self.extendVC.documentWrappingBlcok = ^ {
//        if (weakSelf.languagePopover.isShown) {
//            [weakSelf.languagePopover close];
//        }
        [weakSelf _setButtonEnable:YES];
        
        [weakSelf.mainVM documentWrapping];
    };
    
    self.extendVC.closeBlock = ^ {
        [weakSelf _setButtonEnable:YES];
    };
    
    self.extendVC.compareBlock = ^(FDLanguagePersonalizeModel *personalizeModel) {
        [weakSelf _setButtonEnable:YES];
        
        [weakSelf.mainVM.mainExtendVM compareStrings];
    };
    
    self.extendVC.exportToExcelBLock = ^() {
        [weakSelf _setButtonEnable:YES];
        weakSelf.tipText.string = @"Exporting...\n\n";
        [weakSelf.mainVM exportToExcel];
    };
}

- (void)_setButtonEnable:(BOOL)enable
{
    self.localizeNamesPopButton.enabled = enable;
    self.languagesPopButton.enabled = enable;
    self.addFilePath.enabled = enable;
    self.addLocalizeButton.enabled = enable;
}

- (void)_setUIWithFilePath:(NSString *)filePath
{
    if (!filePath) {
        return;
    }
    
    if ([filePath hasSuffix:@".xcodeproj"]) {
        self.popButtonBackView.hidden = NO;
        
        self.icon_1.image = [NSImage imageNamed:@"xcode-project_Icon"];
        
        self.mainVM.selectedProjectPath = filePath;
        
        [self _setPopButton];
        
        self.tipText.string = [NSString stringWithFormat:@"║xcodeproj║: %@\n\n%@", filePath, self.tipText.string];
    } else {
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory: &isDir]
            && isDir) {
            
            if (isDir) {
                self.popButtonBackView.hidden = NO;
                
                self.icon_1.image = [NSImage imageNamed:@"Finder1"];
                
                self.mainVM.selectedProjectPath = filePath;
                
                [self _setPopButton];
                
                self.tipText.string = [NSString stringWithFormat:@"║xcodeproj║: %@\n\n%@", filePath, self.tipText.string];
            }
        }
    }
    
    if ([filePath hasSuffix:@".xlsx"]) {
        self.icon_2.hidden = NO;
        self.icon_2.image = [NSImage imageNamed:@"dashboard_excel"];
        self.mainVM.localizeFilePath = filePath;
        
        self.tipText.string = [NSString stringWithFormat:@"║xlsx║: %@\n\n%@",filePath, self.tipText.string];
    }
    
    self.addLocalizeButton.hidden = !(!self.popButtonBackView.hidden && self.mainVM.localizeFilePath.length);
    
}

- (void)selectLanguagePathNotification:(NSNotification *)notification
{
    NSString *path = notification.userInfo[@"path"];
    NSMutableArray *marrPaths = [NSMutableArray array];
    [self.mainVM.marrLanguagePaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj containsString:path]) {
            [marrPaths addObject:obj];
        }
    }];
    
    self.mainVM.marrLanguagePaths = marrPaths.mutableCopy;
    
    [self _setLocalizeNamesPopButton];
    [self _setLanguagesPathsPopButton];
    
    [self.selectLanguagePathView removeFromSuperview];
}

#pragma mark - setPopButton

- (void)_setPopButton
{
    if (self.mainVM.selectedProjectPath) {
        [[FDProjectFileManager share] getLocalizesWithPath:self.mainVM.selectedProjectPath result:^(NSSet *localizeNames, NSArray *languagesPathsArray){
            NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
            NSArray *sortSetArray = [localizeNames sortedArrayUsingDescriptors:sortDesc];
            self.mainVM.marrLocalizeNames = sortSetArray.mutableCopy;
            self.mainVM.marrLanguagePaths = languagesPathsArray.mutableCopy;
                        
            [self _openSelectLanguagePathView:languagesPathsArray];
        }];
    }
}

- (void)_setLocalizeNamesPopButton
{
    [self.localizeNamesPopButton removeAllItems];
    
    for (NSString *localizeName in self.mainVM.marrLocalizeNames) {
        
        if (localizeName) {
            [self.localizeNamesPopButton addItemWithTitle:localizeName];
            
        }
    }
    
    [self.localizeNamesPopButton selectItemAtIndex:0];
}

- (void)_setLanguagesPathsPopButton
{
    [self.languagesPopButton removeAllItems];
    
    [self.languagesPopButton addItemWithTitle:@"All Language"];
    
    NSArray *allLanguages = [self.mainVM.dicLanguagesPlist allKeys];
    
    [self.languagesPopButton addItemsWithTitles:allLanguages];
    
    [self.languagesPopButton selectItemAtIndex:0];
}

- (void)_openSelectLanguagePathView:(NSArray *)languagesPathsArray
{
    NSArray *arrayPaths = [self _getLanguagesPathsArray:languagesPathsArray];
    if (arrayPaths.count == 0) {
        return;
    } else if (arrayPaths.count == 1) {
        [self _setLocalizeNamesPopButton];
        [self _setLanguagesPathsPopButton];
        
        return;
    }
    
    [CXSelectLanguageManager manager].languagesPaths = arrayPaths;
    
    /**
     NSView 添加方式
     */
    CXSelectLanguagePathView *view = nil;
    NSNib *xib = [[NSNib alloc] initWithNibNamed:@"CXSelectLanguagePathView" bundle:nil];
    NSArray *viewsArray = [[NSArray alloc] init];
    [xib instantiateWithOwner:nil topLevelObjects:&viewsArray];
    for (int i = 0; i < viewsArray.count; i++) {
        if ([viewsArray[i] isKindOfClass:[NSView class]]) {
            view = (CXSelectLanguagePathView *)viewsArray[i];
            break;
        }
    }
    
    [self.view addSubview:view];
    self.selectLanguagePathView = view;
}

- (NSArray *)_getLanguagesPathsArray:(NSArray *)languagesPathsArray
{
    NSMutableSet *mset = [NSMutableSet set];
    [languagesPathsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = [obj stringByReplacingOccurrencesOfString:self.mainVM.selectedProjectPath withString:@""];
        path = [path stringByDeletingLastPathComponent];
        [mset addObject:path];
    }];
    
    return [mset allObjects];
}

#pragma mark - lazy load
- (NSPopover *)languagePopover
{
    if (!_languagePopover) {
        _languagePopover = [NSPopover new];
        _languagePopover.contentViewController = self.LanguagePopoverVC;
        _languagePopover.behavior = NSPopoverBehaviorApplicationDefined;
    }
    
    return _languagePopover;
}

- (FDLanguagePopoverViewController *)LanguagePopoverVC
{
    if(!_LanguagePopoverVC){
        _LanguagePopoverVC = [[FDLanguagePopoverViewController alloc] initWithNibName:@"FDLanguagePopoverViewController" bundle:nil];
    }
    return _LanguagePopoverVC;
}

- (FDLanguagePopoverViewController *)extendVC
{
    if (!_extendVC) {
        _extendVC = [[FDLanguagePopoverViewController alloc] initWithNibName:nil bundle:nil];
        _extendVC.arrLanguage = [[self.mainVM getLanguagesPlist] allValues];
    }
    
    return _extendVC;
}

@end
