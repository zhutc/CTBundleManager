//
//  ViewController.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/29.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "ViewController.h"
#import "CTDropOutlineView.h"
#import "CTTask.h"
#import "NSString+JSON.h"
#import "CTVCModelView.h"
#import "CTLogPanel.h"
#import "CTSettingCache.h"
#import "CTSettingModel.h"
#import "CTSpecPanel.h"
#import "CTSettingPanel.h"


@interface ViewController()<NSSearchFieldDelegate , CTSpecPanelProtocol>
@property (weak) IBOutlet NSView *mainBackgroundView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSView *mainDrapBackgroundView;
@property (weak) IBOutlet CTDropOutlineView *excludeDropView;
@property (weak) IBOutlet CTDropOutlineView *bundleDropView;
@property (weak) IBOutlet CTDropOutlineView *sourceCodeDropView;

@property (nonatomic , strong) CTVCModelView* manager;//VM
@property (nonatomic , strong) CTSettingModel* settingModel;

@property (nonatomic , strong) CTLogPanel* tmpLogPanel;
@property (nonatomic , strong) CTSpecPanel* tmpSpecPanel;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear
{
    [super viewWillAppear];
    [self loadSetting];
    
    if ([self hasNoSpec]) {
        [self showSpecPanel];
    }else{
        [self loadData];
    }
}
#pragma mark - 解析文件


- (IBAction)installAction:(NSButton *)sender {
    [self buildTaskWithUpdate:NO];
}

- (IBAction)updateAction:(id)sender {
    [self buildTaskWithUpdate:YES];
}

- (IBAction)helpAction:(id)sender {
    
}

- (IBAction)addSpecAction:(id)sender
{
    CTSettingPanel* settingPanel = [CTSettingPanel settingPanel];
    
    settingPanel.ctripSpecTextField.stringValue = self.settingModel.ctripSpecPath;
    settingPanel.pythonTextField.stringValue = self.settingModel.python;
    
    [self.view.window beginSheet:settingPanel
               completionHandler:nil];
}


-(IBAction)clearAction:(id)sender
{
    [CTSettingCache removeObjectForKey:kCtripSpecKey];
    [CTSettingCache removeObjectForKey:kPython];
    self.settingModel.ctripSpecPath = nil;
    
    [self showSpecPanel];
}

#pragma mark - Private

/** 获取基本配置 */
-(void)loadSetting
{
    NSString* python = [CTSettingCache objectForKey:kPython];
    if (nil == python || 0 == python.length) {
        python = @"/usr/bin/python";
    }
    self.settingModel = [[CTSettingModel alloc] init];
    self.settingModel.python = python;
    self.settingModel.ctripSpecPath = [CTSettingCache objectForKey:kCtripSpecKey];
}

/** 不存在spec */
-(BOOL)hasNoSpec
{
    return nil == self.settingModel.ctripSpecPath && 0 == self.settingModel.ctripSpecPath.length;
}


-(void)loadData
{
    self.manager = [[CTVCModelView alloc] init];
    [self.manager readArguments:self.settingModel.ctripSpecPath];
    
    [self.excludeDropView updateDataArray:self.manager.excludeArray];
    [self.bundleDropView updateDataArray:self.manager.bundleArray];
    [self.sourceCodeDropView updateDataArray:self.manager.sourceArray];
}


/** run command */
-(void)buildTaskWithUpdate:(BOOL)update{
    
    if (NO == [self showLogPanel]) {
        return;
    }
    [self.manager saveCtripJSONLockFile];
    
    NSString* workspace = [self.manager.ctripJsonPath stringByDeletingLastPathComponent];
    
    NSMutableArray* arguments = @[].mutableCopy;
    /** 需要注意参数中不能多空格，要严格按照一个空格分割 */
    [arguments addObject:@"pbhelper.py"];
    [arguments addObject:@"-jp"];
    [arguments addObject:self.manager.ctripJsonLockPath];
    [arguments addObject:@"-pb"];
    [arguments addObject:self.manager.xcodeprojPath];
    
    if (NO == update) {
        [arguments addObject:@"-n"];
        [arguments addObject:@"t"];
    }
    [self.tmpLogPanel start];
    [CTTask installTaskWithLaunchPath:@"/usr/bin/python"
                            arguments:arguments
                     currentWorkSpace:workspace
                           receiveLog:^(NSString *str) {
                               [self.tmpLogPanel upateCotent:str];
                           }
                              handler:^(NSString *str) {
                                  [self.tmpLogPanel end];
                              }];
}

-(BOOL)showLogPanel
{
    self.tmpLogPanel = [CTLogPanel logPanel];
    if(nil == self.tmpLogPanel){
        return NO;
    }
    [self.view.window beginSheet:self.tmpLogPanel
       completionHandler:^(NSModalResponse returnCode) {
           if (NSModalResponseOK == returnCode) {
               NSLog(@"OK....");
           }
       }];
    return YES;
}

-(BOOL)showSpecPanel
{
    self.tmpSpecPanel = [CTSpecPanel specPanel];
    self.tmpSpecPanel.delegate = self;
    if(nil == self.tmpSpecPanel){
        return NO;
    }
    [self.view.window beginSheet:self.tmpSpecPanel
               completionHandler:^(NSModalResponse returnCode) {
                   if (NSModalResponseOK == returnCode) {
                       NSLog(@"OK....");
                       [self loadData];
                   }
               }];
    return YES;
}


#pragma mark - CTSpecPanelDelegate
-(void)panel:(CTSpecPanel*)panel didChooseFileURL:(NSArray*)urls modalResponse:(NSModalResponse)result
{
    if (NSModalResponseOK == result) {
        if (urls) {
            NSURL* specURL = urls.firstObject;
            if (specURL) {
                self.settingModel.ctripSpecPath = specURL.relativePath;
                [CTSettingCache setObject:self.settingModel.ctripSpecPath forKey:kCtripSpecKey];
                [self loadData];
                return ;
            }
        }
    }
}


@end







