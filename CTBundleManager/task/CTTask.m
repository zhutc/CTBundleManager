//
//  CTTask.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/31.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTTask.h"
#
@implementation CTTask
+(NSTask*)taskWithLaunchPath:(NSString *)launchPath
                   arguments:(NSArray *)arguments
            currentWorkSpace:(NSString *)workspace
{
    NSTask* task = [[NSTask alloc] init];
    task.launchPath = launchPath;
    task.arguments = arguments;
    task.currentDirectoryPath = workspace;
    
    NSPipe* outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];

    NSPipe* inputPipe = [NSPipe pipe];
    [task setStandardInput:inputPipe];
    
    return task;
}
//获取输出的task
+(void)catTaskWithArguments:(NSArray<NSString*> *)arugments handler:(void(^)(NSString* str))handler
{
    if (!handler) {
        return;
    }
    NSTask* task = [CTTask taskWithLaunchPath:@"/bin/cat"
                                    arguments:arugments
                             currentWorkSpace:[[NSBundle mainBundle] resourcePath]];
    [task launch];
    [task waitUntilExit];
    
    NSPipe* outputPipe = task.standardOutput;
    NSData* data = [outputPipe.fileHandleForReading readDataToEndOfFile];
    NSString* text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    handler(text);
}

@end
