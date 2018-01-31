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

typedef NS_ENUM(NSUInteger, CTBundleManagerStatus) {
    CTBundleManagerStatusNormal = 0,
    CTBundleManagerStatusNoSpec,
    CTBundleManagerStatusRootError,
    CTBundleManagerStatusCtripJSONError,
    CTBundleManagerStatusOK
};


@interface ViewController()<NSSearchFieldDelegate>
@property (weak) IBOutlet NSView *mainBackgroundView;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSView *mainDrapBackgroundView;
@property (weak) IBOutlet CTDropOutlineView *excludeDropView;
@property (weak) IBOutlet CTDropOutlineView *bundleDropView;
@property (weak) IBOutlet CTDropOutlineView *sourceCodeDropView;
@property (assign) CTBundleManagerStatus status;
@property (nonatomic , copy) NSString* specContent;



#pragma mark - 外部参数
@property (nonatomic , copy) NSString* rootPath;
@property (nonatomic , copy) NSString* ctripSpecPath;
@property (nonatomic , copy) NSString* ctripJsonPath;
@property (nonatomic , copy) NSString* ctripJsonLockPath;/** 生成一个json.lock */
@property (nonatomic , copy) NSString* xcodeprojPath;
@property (nonatomic , copy) NSString* descriptionPath;
@property (nonatomic , copy) NSString* appVersion;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.status = CTBundleManagerStatusNormal;
    
    
    self.ctripSpecPath = @"/Users/tczhu/work/CodeSource/NativeApp/IOS_2/ctrip.spec";
    self.rootPath = @"/Users/tczhu/work/CodeSource/NativeApp/IOS_2";
    self.specContent = [[NSString alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.ctripSpecPath]
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
    if (self.ctripSpecPath) {
        [self readArguments:self.rootPath];
    }
    
}
#pragma mark - 解析文件

-(void)readArguments:(NSString *)rootPath
{
    NSError* error = nil;
    NSDictionary* ctripSpecDic = [self.specContent toDictionary:error];
    if(error || nil == ctripSpecDic){
        self.status = CTBundleManagerStatusRootError;
        return;
    }

    NSLog(@"ctripSpecDic = %@" , ctripSpecDic);
    
    self.ctripJsonPath = [self.rootPath stringByAppendingPathComponent:ctripSpecDic[@"CtripJSONPath"]];
    self.xcodeprojPath = [self.rootPath stringByAppendingPathComponent:ctripSpecDic[@"xcodeproj"]];
    self.descriptionPath = [self.rootPath stringByAppendingPathComponent:ctripSpecDic[@"DescriptionPath"]];
    /* // 使用cat获取到ctripjson
    [CTTask catTaskWithArguments:@[self.ctripJsonPath]
                         handler:^(NSString *str) {
                             NSLog(@"str = %@" , str);
                         }];
     */

    NSString* ctripJsonContent = [[NSString alloc] initWithContentsOfFile:self.ctripJsonPath
                                                                 encoding:NSUTF8StringEncoding
                                                                    error:&error];
    
    if(error || 0 == ctripJsonContent.length){
        self.status = CTBundleManagerStatusCtripJSONError;
        return;
    }
    
    NSDictionary* ctripJsonDictionary = [ctripJsonContent toDictionary:error];
    if (error || nil == ctripJsonDictionary) {
        self.status = CTBundleManagerStatusCtripJSONError;
        return;
    }
    
    self.appVersion = ctripJsonDictionary[@"Version"];
    self.ctripJsonLockPath = [self.ctripJsonPath stringByAppendingString:@".lock"];
    
}







- (IBAction)installAction:(NSButton *)sender {
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
        NSError* error = nil;
        if (NSModalResponseOK == result) {
            if (weakpanel.URLs) {
                NSURL* specURL = weakpanel.URLs.firstObject;
                if (specURL) {
                    self.specContent = [[NSString alloc] initWithContentsOfURL:specURL
                                                                      encoding:NSUTF8StringEncoding
                                                                         error:&error];
                    if (!error && self.specContent.length) {
                        self.ctripSpecPath = specURL.relativePath;
                        self.rootPath = [specURL.relativePath stringByDeletingLastPathComponent];
                        [self readArguments:self.rootPath];
                        return ;
                    }
                }
            }
        }
        self.status = CTBundleManagerStatusNoSpec;
    }];
}

@end







