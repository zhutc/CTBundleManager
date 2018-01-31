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


@interface ViewController()<NSSearchFieldDelegate>
@property (weak) IBOutlet NSView *mainBackgroundView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSView *mainDrapBackgroundView;
@property (weak) IBOutlet CTDropOutlineView *excludeDropView;
@property (weak) IBOutlet CTDropOutlineView *bundleDropView;
@property (weak) IBOutlet CTDropOutlineView *sourceCodeDropView;

@property (nonatomic , strong) CTVCModelView* manager;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.ctripSpecPath = @"/Users/tczhu/work/CodeSource/NativeApp/IOS_2/ctrip.spec";
    //    self.rootPath = @"/Users/tczhu/work/CodeSource/NativeApp/IOS_2";
    
    NSString* specPath = @"/Users/chuting/tczhu_work/IOS_2/ctrip.spec";
    self.manager = [[CTVCModelView alloc] init];
    [self.manager readArguments:specPath];
}

-(void)viewWillAppear
{
    [super viewWillAppear];
    [self.excludeDropView updateDataArray:self.manager.excludeArray];
    [self.bundleDropView updateDataArray:self.manager.bundleArray];
    [self.sourceCodeDropView updateDataArray:self.manager.sourceArray];
}
#pragma mark - 解析文件


- (IBAction)installAction:(NSButton *)sender {
    [self.manager saveCtripJSONLockFile];
}

- (IBAction)updateAction:(id)sender {
}

- (IBAction)helpAction:(id)sender {
    
}

- (IBAction)addSpecAction:(id)sender
{
    /** 如果有权限问题，需要使用openPanel打开spec */
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = @[@"spec"];
    __weak NSOpenPanel* weakpanel = openPanel;
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (NSModalResponseOK == result) {
            if (weakpanel.URLs) {
                NSURL* specURL = weakpanel.URLs.firstObject;
                if (specURL) {
                    [self.manager readArguments:specURL.relativePath];
                    return ;
                }
            }
        }
        self.manager.status = CTBundleManagerStatusNoSpec;
    }];
}

@end







