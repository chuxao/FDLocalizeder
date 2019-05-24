//
//  CXSelectLanguagePathView.m
//  FDLocalizeder
//
//  Created by chuxiao on 2019/5/22.
//  Copyright © 2019 mob.com. All rights reserved.
//

#import "CXSelectLanguagePathView.h"
#import "CXSelectLanguagePathCellView.h"

@interface CXSelectLanguagePathView ()<NSTableViewDataSource, NSTableViewDelegate>


@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, assign) NSInteger currentRow;

@property (weak) IBOutlet NSButton *confirmButton;


@end


@implementation CXSelectLanguageManager

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    static CXSelectLanguageManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [CXSelectLanguageManager new];
    });
    
    return manager;
}

@end


@implementation CXSelectLanguagePathView


/**
 重写drawRect，解决nsview的着色问题
 */
- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect: dirtyRect];  //父类，

    [[NSColor whiteColor] set];  //设置颜色
    NSRectFill(dirtyRect);        //填充rect区域
}

//- (NSView *)hitTest:(NSPoint)point
//{
//    return ;
//}

/**
 重写mouseDown，解决nsview的穿透问题
 */
- (void)mouseDown:(NSEvent *)event
{
    
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder]) {
//        [self _configUI];
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _configUI];
    }
    return self;
}

- (instancetype)initWithLanguagesPaths:(NSArray *)languagesPaths
{
    self = [super init];
    if (self) {
        self.languagesPaths = languagesPaths;
    }
    return self;
}

- (void)_configUI
{
    /**
    // 1.0.创建卷轴视图
    NSScrollView *scrollView    = [[NSScrollView alloc] init];
    // 1.1.有(显示)垂直滚动条
    scrollView.hasVerticalScroller  = YES;
    // 1.2.设置frame并自动布局
    scrollView.frame            = self.bounds;
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    // 1.3.添加到self.view
    [self addSubview:scrollView];

    
    NSTableView *tableView      = [[NSTableView alloc] init];
    self.tableView = tableView;
    tableView.frame             = self.bounds;
    // 2.1.设置代理和数据源
    tableView.delegate          = self;
    tableView.dataSource        = self;
    // 2.2.设置为ScrollView的documentView
    scrollView.contentView.documentView = tableView;
    
    // 3.0.创建表列
    NSTableColumn *columen1     = [[NSTableColumn alloc] initWithIdentifier:@"columen1"];
    // 3.1.设置最小的宽度
    columen1.minWidth          = 150.0;
    // 3.2.允许用户调整宽度
    columen1.resizingMask      = NSTableColumnUserResizingMask;
    // 3.3.添加到表视图
    [tableView addTableColumn:columen1];
    
    // 4.0.同理，表列都是这么创建的
    NSTableColumn *columen2     = [[NSTableColumn alloc] initWithIdentifier:@"columen2"];
    columen2.minWidth          = 150.0;
    columen2.resizingMask      = NSTableColumnAutoresizingMask | NSTableColumnUserResizingMask;
    /*
     NSTableColumnNoResizing        不能改变宽度
     NSTableColumnAutoresizingMask  拉大拉小窗口时会自动布局
     NSTableColumnUserResizingMask  允许用户调整宽度
     */
//    [tableView addTableColumn:columen2];
    

    self.languagesPaths = [CXSelectLanguageManager manager].languagesPaths;
}

//- (void)setLanguagesPaths:(NSArray *)languagesPaths
//{
//    _languagesPaths = languagesPaths;
//    NSLog(@"//// %@",self.tableView);
//    [self.tableView reloadData];
//    
//}

- (void)settingLanguagesPaths:(NSArray *)languagesPaths
{
    self.languagesPaths = languagesPaths;
    [self.tableView reloadData];
}

//------------------------protocol----------------------------------

//返回表格的行数
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [self.languagesPaths count];
}

//用了下面那个函数来显示数据就用不上这个，但是协议必须要实现，所以这里返回nil
//- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    return nil;
//}


//显示数据
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTextFieldCell *textCell = cell;
    [textCell setTitle:@"aaa"];
}


- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *strIdt = [tableColumn identifier];
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:strIdt owner:self];
    
//    if (!cellView) {
//        cellView = [[NSTableCellView alloc]initWithFrame:CGRectMake(0, 0, tableColumn.width, 60)];
//
//    }
    
//    cellView.textField.lineBreakMode = NSLineBreakByTruncatingHead;
    cellView.textField.maximumNumberOfLines = 3;
    cellView.textField.stringValue = self.languagesPaths[row];
    
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 60;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    self.currentRow = row;
    self.confirmButton.hidden = NO;
    return YES;
}


- (IBAction)_confirmAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectLanguagePathNotification" object:nil userInfo:@{@"path":self.languagesPaths[self.currentRow]}];
}


@end
