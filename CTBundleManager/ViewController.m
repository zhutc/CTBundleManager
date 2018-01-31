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
typedef NS_ENUM(NSUInteger, CTBundleManagerStatus) {
    CTBundleManagerStatusNormal = 0,
    CTBundleManagerStatusNoSpec,
    CTBundleManagerStatusRootError,
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
@property (nonatomic , copy) NSString* xcodeprojPath;
@property (nonatomic , copy) NSString* descriptionPath;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.status = CTBundleManagerStatusNormal;
    
}
#pragma mark - 解析文件

-(void)readArguments:(NSString *)rootPath
{
    NSError* error = nil;

    NSData* ctripSpecData = [self.specContent dataUsingEncoding:NSUTF8StringEncoding];
    if(error || !ctripSpecData || 0 == ctripSpecData.length){
        self.status = CTBundleManagerStatusRootError;
        return;
    }
    NSDictionary* ctripSpecDic = [NSJSONSerialization JSONObjectWithData:ctripSpecData
                                                        options:NSJSONReadingMutableLeaves
                                                          error:&error];
    
    if (error || nil == ctripSpecDic) {
        self.status = CTBundleManagerStatusRootError;
        return;
    }
    
    NSLog(@"ctripSpecDic = %@" , ctripSpecDic);
    
    self.ctripJsonPath = [self.rootPath stringByAppendingPathComponent:ctripSpecDic[@"CtripJSONPath"]];
    self.xcodeprojPath = [self.rootPath stringByAppendingPathComponent:ctripSpecDic[@"xcodeproj"]];
    self.descriptionPath = [self.rootPath stringByAppendingPathComponent:ctripSpecDic[@"DescriptionPath"]];
    
    [CTTask catTaskWithArguments:@[self.ctripJsonPath]
                         handler:^(NSString *str) {
                             NSLog(@"str = %@" , str);
                         }];

    
    NSLog(@"......");
}







- (IBAction)installAction:(NSButton *)sender {
}

- (IBAction)updateAction:(id)sender {
}

- (IBAction)helpAction:(id)sender {
    
}

- (IBAction)addSpecAction:(id)sender
{
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







