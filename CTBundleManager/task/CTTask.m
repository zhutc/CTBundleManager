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
    NSLog(@"Create Task : ============\n  launchPath : %@ \n arguments = %@ \n workspace = %@\n============",launchPath ,arguments ,workspace );
    
    NSTask* task = [[NSTask alloc] init];
    task.launchPath = launchPath;
    task.arguments = arguments;
    task.currentDirectoryPath = workspace;
    task.environment = @{@"LANG":@"zh_CN.UTF-8"
                         @"PATH"@"/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/git/bin:/usr/local/"
                         };
    
    NSPipe* outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];

    NSPipe* inputPipe = [NSPipe pipe];
    [task setStandardInput:inputPipe];
    
    return task;
}
+(NSTask*)taskWithLaunchPath:(NSString *)launchPath
                   arguments:(NSArray *)arguments
            currentWorkSpace:(NSString *)workspace
               outputhandler:(void(^)(NSString* str))handler
{
    if (!handler) {
        return nil;
    }
    
    NSTask* task = [CTTask taskWithLaunchPath:launchPath
                                    arguments:arguments
                             currentWorkSpace:workspace];
    [task launch];
    [task waitUntilExit];
    
    NSPipe* outputPipe = task.standardOutput;
    NSData* data = [outputPipe.fileHandleForReading readDataToEndOfFile];
    NSString* text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    handler(text);
    return task;
}

+(void)shTaskWithArguments:(NSArray<NSString *> *)arguments
                   handler:(void(^)(NSString* str))handler
{

    [CTTask taskWithLaunchPath:@"/bin/sh"
                     arguments:arguments
              currentWorkSpace:[[NSBundle mainBundle] resourcePath]
                 outputhandler:handler];

}

//获取输出的task
+(void)catTaskWithArguments:(NSArray<NSString*> *)arugments handler:(void(^)(NSString* str))handler
{

    [CTTask taskWithLaunchPath:@"/bin/cat"
                     arguments:arugments
              currentWorkSpace:[[NSBundle mainBundle] resourcePath]
                 outputhandler:handler];

}

+(void)whichTaskWithArguments:(NSArray<NSString *> *)arguments
                      handler:(void(^)(NSString* str))handler
{
    [CTTask taskWithLaunchPath:@"/usr/bin/which"
                     arguments:arguments
              currentWorkSpace:[[NSBundle mainBundle] resourcePath]
                 outputhandler:handler];
}


+(void)installTaskWithLaunchPath:(NSString *)launchPath
                       arguments:(NSArray *)arguments
                currentWorkSpace:(NSString *)workspace
                      receiveLog:(void(^)(NSString* str))receiveLogHander
                         handler:(void(^)(NSString* str))handler
{
    if (!handler) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableString* logs = [NSMutableString string];
        NSTask* task = [CTTask taskWithLaunchPath:launchPath
                                        arguments:arguments
                                 currentWorkSpace:workspace];
        NSPipe* outputPipe = task.standardOutput;
        NSFileHandle* readHandler = outputPipe.fileHandleForReading;
        
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleReadCompletionNotification
                                                          object:readHandler
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          NSData* data = note.userInfo[NSFileHandleNotificationDataItem];
                                                          if (nil == data || 0 == data.length) {
                                                              return ;
                                                          }
                                                          NSString* log = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              NSMutableString* content = [[NSMutableString alloc] initWithString:log];
                                                              if (receiveLogHander) {
                                                                  receiveLogHander(content);
                                                              }
                                                          });
                                                          [logs appendString:log];
                                                          [readHandler readInBackgroundAndNotify];
                                                          
                                                      }];
        
        [task launch];
        [readHandler readInBackgroundAndNotify];
        
        [task waitUntilExit];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableString* content = [[NSMutableString alloc] initWithString:logs];
            handler(content);

        });
    });
}
@end
