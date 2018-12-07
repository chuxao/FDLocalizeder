//
//  ViewController.m
//  FDLocalizederDemo
//
//  Created by chuxiao on 2018/12/7.
//  Copyright © 2018年 chuxiao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label1;

@property (weak, nonatomic) IBOutlet UILabel *label2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *label1Text = [self getPreferredLanguage];
    
    self.label1.text = label1Text;
    self.label2.text = NSLocalizedStringFromTable(@"FDLocalizeder_Excel模板", @"LocalizaFile1", @"");
    self.label1.layer.borderWidth = 0.5;
    self.label1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.label1.layer.cornerRadius = 5;
    self.label1.clipsToBounds = YES;
    self.label2.layer.borderWidth = 0.5;
    self.label2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.label2.layer.cornerRadius = 5;
    self.label2.clipsToBounds = YES;
}

- (NSString*)getPreferredLanguage
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    NSLog(@"当前语言:%@", preferredLang);
    
    return preferredLang;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
