//
//  FDLanguagePopoverViewController.m
//  FDLocalizeder
//
//  Created by chuxiao on 2018/5/10.
//  Copyright © 2018年 mob.com. All rights reserved.
//

#import "FDLanguagePopoverViewController.h"
#import "CustomSlider.h"
#import "CXSliderRangeView.h"
#import "FDImageView.h"
#import "SCSelectionBorder.h"

@implementation FDLanguagePersonalizeModel

@end


@interface FDLanguagePopoverViewController ()<FDImageSelectRectDelegate>

@property (weak) IBOutlet NSButton *chooseSomeLanButton;

@property (weak) IBOutlet NSButton *notChooseSomeLanButton;

@property (weak) IBOutlet NSView *languageRadioView;

@property (strong, nonatomic) NSArray *arrCheckBoxs;

@property (weak) IBOutlet NSTextField *tipTextField;

@property (weak) IBOutlet NSButton *comparativeAdditionButton;

@property (weak) IBOutlet NSButton *compareButton;


#pragma mark - excel select range

@property (weak) IBOutlet FDImageView *selectRectImageView;
@property (weak) IBOutlet NSTextField *leftRowTextField;
@property (weak) IBOutlet NSTextField *rightRowTextField;
@property (weak) IBOutlet NSButton *addWithRangeButton;
@property (weak) IBOutlet NSTextField *baseLanTextField;
@property (weak) IBOutlet NSTextField *compareTipLabel;


#pragma mark - checkBoxButton

@property (weak) IBOutlet NSButton *checkBox_1;
@property (weak) IBOutlet NSButton *checkBox_2;
@property (weak) IBOutlet NSButton *checkBox_3;
@property (weak) IBOutlet NSButton *checkBox_4;
@property (weak) IBOutlet NSButton *checkBox_5;
@property (weak) IBOutlet NSButton *checkBox_6;
@property (weak) IBOutlet NSButton *checkBox_7;
@property (weak) IBOutlet NSButton *checkBox_8;
@property (weak) IBOutlet NSButton *checkBox_9;
@property (weak) IBOutlet NSButton *checkBox_10;
@property (weak) IBOutlet NSButton *checkBox_11;
@property (weak) IBOutlet NSButton *checkBox_12;
@property (weak) IBOutlet NSButton *checkBox_13;
@property (weak) IBOutlet NSButton *checkBox_14;
@property (weak) IBOutlet NSButton *checkBox_15;
@property (weak) IBOutlet NSButton *checkBox_16;
@property (weak) IBOutlet NSButton *checkBox_17;
@property (weak) IBOutlet NSButton *checkBox_18;
@property (weak) IBOutlet NSButton *checkBox_19;
@property (weak) IBOutlet NSButton *checkBox_20;
@property (weak) IBOutlet NSButton *checkBox_21;
@property (weak) IBOutlet NSButton *checkBox_22;
@property (weak) IBOutlet NSButton *checkBox_23;
@property (weak) IBOutlet NSButton *checkBox_24;


@end

@implementation FDLanguagePopoverViewController

- (BOOL)isFlipped{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _configData];
    [self _configUI];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    
}

- (void)_configData
{
    self.arrCheckBoxs = @[_checkBox_1,
                          _checkBox_2,
                          _checkBox_3,
                          _checkBox_4,
                          _checkBox_5,
                          _checkBox_6,
                          _checkBox_7,
                          _checkBox_8,
                          _checkBox_9,
                          _checkBox_10,
                          _checkBox_11,
                          _checkBox_12,
                          _checkBox_13,
                          _checkBox_14,
                          _checkBox_15,
                          _checkBox_16,
                          _checkBox_17,
                          _checkBox_18,
                          _checkBox_19,
                          _checkBox_20,
                          _checkBox_21,
                          _checkBox_22,
                          _checkBox_23,
                          _checkBox_24];
}

- (void)_configUI
{
//    [self.notChooseSomeLanButton setState:NSOnState];
    for (int i = 0; i < self.arrLanguage.count; i ++) {
        if (i >= _arrCheckBoxs.count) {
            return;
        }
        
        NSButton *button = _arrCheckBoxs[i];
        [button setTitle:_arrLanguage[i]];
        button.hidden = NO;
    }
    
    self.selectRectImageView.delegate = self;
    self.tipTextField.hidden = !self.languageRadioView.hidden;
}

- (void)_callBack
{
    NSArray *arrLanguages;
    FDLanguagePersonalizeModel *personalModel = [FDLanguagePersonalizeModel new];
    
    if (self.chooseSomeLanButton.state == NSOnState) {
        NSMutableArray *marr = [NSMutableArray array];
        for (NSButton *button in _arrCheckBoxs) {
            if (button.state == NSOnState) {
                [marr addObject:button.title];
            }
        }
        
        arrLanguages = marr.copy;
    }
    
    if (self.addWithRangeButton.state == NSOnState) {
        
        char leftRow = [self.leftRowTextField.stringValue characterAtIndex:0];
        char rightRow = [self.rightRowTextField.stringValue characterAtIndex:0];
        NSInteger leftRowIndex = [[self.leftRowTextField.stringValue substringFromIndex:1] integerValue];
        NSInteger rightRowIndex = [[self.rightRowTextField.stringValue substringFromIndex:1] integerValue];
        

        personalModel.leftRow = leftRow;
        personalModel.rightRow = rightRow;
        personalModel.leftRowIndex = leftRowIndex;
        personalModel.rightRowIndex = rightRowIndex;
        personalModel.addWithRange = YES;
    }
    
    if (self.comparativeAdditionButton.state == NSOnState) {
        personalModel.compareToAdd = YES;
        personalModel.baseLanguage = self.baseLanTextField.stringValue;
    }
    
    if (self.compareButton.state == NSOnState) {
        personalModel.compare = YES;
        personalModel.baseLanguage = self.baseLanTextField.stringValue;
    }
    
    if (self.disAppearBlock) {
        self.disAppearBlock(arrLanguages, personalModel);
    }
    
}

- (void)_callBackForCompare
{
    FDLanguagePersonalizeModel *personalModel = [FDLanguagePersonalizeModel new];
    
    char leftRow = [self.leftRowTextField.stringValue characterAtIndex:0];
    NSInteger leftRowIndex = [[self.leftRowTextField.stringValue substringFromIndex:1] integerValue];
    NSInteger rightRowIndex = [[self.rightRowTextField.stringValue substringFromIndex:1] integerValue];
    
    
    personalModel.leftRow = leftRow;
    personalModel.leftRowIndex = leftRowIndex;
    personalModel.rightRowIndex = rightRowIndex;
    
    if (self.compareBlock) {
        self.compareBlock(personalModel);
    }
}


#pragma mark - FDImageSelectRectDelegate
- (void)selectRect:(NSRect)rect
{
    char rowL = rect.origin.x/10 + 65;
    NSInteger rowT = rect.origin.y/3 + 1;
    char rowR = (rect.size.width + rect.origin.x)/10 + 65;
    NSInteger rowB = (rect.size.height + rect.origin.y)/3 + 1;
    
    self.leftRowTextField.stringValue = [NSString stringWithFormat:@"%c%lu",rowL, rowT];
    self.rightRowTextField.stringValue = [NSString stringWithFormat:@"%c%lu",rowR, rowB];
//    NSLog(@"_____%f___%f___%f___%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
}

- (IBAction)chooseSomeLanguagesAction:(id)sender {
    if (self.chooseSomeLanButton.state == NSOnState) {
        self.languageRadioView.hidden = NO;
    }else {
        self.languageRadioView.hidden = YES;
    }
    
    self.tipTextField.hidden = !self.languageRadioView.hidden;
}

- (IBAction)chooseAllLanguageAction:(id)sender {

}

- (IBAction)confirmAction:(id)sender {
    if (self.comparativeAdditionButton.state == NSOnState ||
        self.compareButton.state == NSOnState) {
        if (!self.baseLanTextField.stringValue.length) {
            self.compareTipLabel.stringValue = @"Please enter the basic language";
            return;
        }
        
        BOOL isRealLanguage = NO;
        
        for (NSButton *button in _arrCheckBoxs) {
            if ([button.title isEqualToString:self.baseLanTextField.stringValue]) {
                
                isRealLanguage = YES;
                break;
            }
        }
        
        if (!isRealLanguage) {
            self.compareTipLabel.stringValue = @"Language doesn't exist";
            return;
        }else {
            self.compareTipLabel.stringValue = @"";
        }
    }
    
    [self dismiss];
    [self _callBack];
}

- (IBAction)closeAction:(id)sender {
    [self dismiss];
    
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (IBAction)backupAction:(id)sender {
    [self dismiss];
    
    if (self.backupBlock) {
        self.backupBlock();
    }
}

- (IBAction)undoAction:(id)sender {
    [self dismiss];
    
    if (self.undoBlock) {
        self.undoBlock();
    }
}

- (IBAction)addWithRangeAction:(id)sender {
    NSButton *button = (NSButton *)sender;
    if (button.state == NSOnState) {
        NSRect rect = self.selectRectImageView.cropMarker.selectedRect;
        [self selectRect:rect];
    }
}

- (IBAction)documentWrappingAction:(id)sender {
    [self dismiss];
    
    if (self.documentWrappingBlcok) {
        self.documentWrappingBlcok();
    }
}

- (IBAction)compareAction:(id)sender {
    self.comparativeAdditionButton.state = NSOffState;
}

- (IBAction)compareToAddAction:(id)sender {
    self.compareButton.state = NSOffState;
    self.addWithRangeButton.state = NSOffState;
}


- (void)dismiss {
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewController:self];
    } else {
        //for the 'show' transition
        [self.view.window close];
    }
}

@end

