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
@property (weak) IBOutlet NSTextField* workspaceTextField;
@property (weak) IBOutlet NSTextField* branchTextField;

@property (nonatomic , strong) CTVCModelView* manager;//VM
@property (nonatomic , strong) CTSettingModel* settingModel;

@property (nonatomic , strong) CTLogPanel* tmpLogPanel;
@property (nonatomic , strong) CTSpecPanel* tmpSpecPanel;
@property (nonatomic , assign) BOOL isRC;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear
{
    [super viewWillAppear];
    [self reload];
    [self branchTask];
    
}
-(void)reload{
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
    [self showHelpAlert];
}

- (IBAction)installRCAction:(id)sender {
    self.isRC = YES;
    [self buildTaskWithUpdate:YES];
    self.isRC = NO;
}

- (IBAction)addSpecAction:(id)sender
{
    CTSettingPanel* settingPanel = [CTSettingPanel settingPanel];
    
    settingPanel.pythonTextField.stringValue = self.settingModel.python;
    if (self.settingModel.python.length != 0 || nil != self.settingModel.python) {
        [settingPanel.pythonTextField setEditable:NO];
    }
    [self.view.window beginSheet:settingPanel
               completionHandler:nil];
}


-(IBAction)clearAction:(id)sender
{
    [CTSettingCache removeObjectForKey:kCtripSpecKey];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.manager.ctripJsonLockPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.manager.ctripJsonLockPath error:nil];
    }
    [self reload];
}

#pragma mark - Private

-(NSString *)checkPython{
    __block NSString* python = nil;
    [CTTask whichTaskWithArguments:@[@"python"]
                           handler:^(NSString *str) {
                               NSLog(@"str = %@",str);
                               python = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                               [CTTask taskWithLaunchPath:python
                                                arguments:@[@"--version"]
                                         currentWorkSpace:[[NSBundle mainBundle] resourcePath]
                                            outputhandler:^(NSString *str) {
                                                if ([str rangeOfString:@"2.7"].location == NSNotFound) {
                                                    //TODO:如果不存在python 2.7,需要用户手动配置
                                                    python = nil;
                                                    return ;
                                                }
                                                [CTSettingCache setObject:python forKey:kPython];
                                            }];
                           }];
    return python;
}


/** 将App放入到主工程根目录的Script/buildshell中 */
-(void)fetchSpecFromScript
{
    NSString* bundlePath = [[NSBundle mainBundle] resourcePath];
    if ([self hasNoSpec]) {
        NSString* specPath = [bundlePath stringByAppendingPathComponent:@"../../../ctrip.spec"];
        NSString* absolutPath = specPath.stringByStandardizingPath;
        if (absolutPath && [[NSFileManager defaultManager] fileExistsAtPath:absolutPath]) {
//可能存在多App,取消cache
//            [CTSettingCache setObject:absolutPath forKey:kCtripSpecKey];
            self.settingModel.ctripSpecPath = absolutPath;
        }
    }
}

/** 获取基本配置 */
-(void)loadSetting
{
    NSString* python = [CTSettingCache objectForKey:kPython];
    if (nil == python || 0 == python.length) {
        python = [self checkPython];
    }
    
    dispatch_block_t block = ^{
        self.settingModel = [[CTSettingModel alloc] init];
        self.settingModel.python = python;
        self.settingModel.ctripSpecPath = [CTSettingCache objectForKey:kCtripSpecKey];
        if ([self hasNoSpec] || ![[NSFileManager defaultManager] fileExistsAtPath:self.settingModel.ctripSpecPath]) {
            self.settingModel.ctripSpecPath = nil;
        }
        [self fetchSpecFromScript];

    };
    
    if (nil == python || 0 == python.length) {
        CTSettingPanel* settingPanel = [CTSettingPanel settingPanel];
        settingPanel.pythonTextField.editable = YES;
        [settingPanel.pythonTextField resignFirstResponder];

        [self.view.window beginSheet:settingPanel
                   completionHandler:^(NSModalResponse result){
                       [CTSettingCache setObject:settingPanel.pythonTextField.stringValue   forKey:kPython];
                       block();
                   }];
        return;
    }
    block();
    
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
    [self.workspaceTextField setStringValue:[NSString stringWithFormat:@"工作目录 : %@",self.manager.rootPath]];
    
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
    if (self.isRC) {
        [arguments addObject:@"-u"];
        [arguments addObject:@"rc"];
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

-(void)branchTask{
    [CTTask taskWithLaunchPath:@"/usr/bin/git"
                     arguments:@[@"branch"]
              currentWorkSpace:self.manager.rootPath
                 outputhandler:^(NSString *str) {
                     NSLog(@"str = %@ ",str);
                     NSString* sub = [[str componentsSeparatedByString:@"*"]lastObject];
                     NSString* branch = [[sub componentsSeparatedByString:@"\n"] firstObject];
                     NSMutableAttributedString* attribute = [[NSMutableAttributedString alloc] initWithString:@"当前分支 : "];
                     [attribute appendAttributedString:[[NSAttributedString alloc] initWithString:branch attributes:@{NSForegroundColorAttributeName:[NSColor redColor]}]];
                     self.branchTextField.attributedStringValue = attribute;
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

-(void)showHelpAlert
{
    [[CTTask taskWithLaunchPath:@"/usr/bin/open"
                      arguments:@[@"http://conf.ctripcorp.com/pages/viewpage.action?pageId=150165982"]
               currentWorkSpace:[[NSBundle mainBundle] resourcePath]] launch] ;
    
    /*
    NSAlert* alert = [[NSAlert alloc] init];
    alert.messageText = @"Ctrip包管理工具说明";
    alert.informativeText = @"Bundle编译是静态库编译， 源码是源码编译\n \
    切换方式：可以拖动一组或者单个Bundle来切换源码还是Bundle编译；\n \
    查看配置按钮： 查看ctrip.spec路径和pythonp配置 \n \
    清除配置按钮：会清空本地生成的ctrip.json.lock和ctrip.spec配置\n \
    更新工程配置按钮：根据Bundle和源码的选中方式更新主工程配置 \n\
    更新工程配置和Bundle按钮：根据Bundle和源码的选中方式更新主工程配置,并且获取MCD生成的新的Bundle\n \
    注意：如果碰到问题，可先尝试清除配置，然后强制退出该App，重新打开即可";
    alert.alertStyle = NSAlertStyleInformational;
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.view.window
                  completionHandler:nil];
     */
    
    
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







