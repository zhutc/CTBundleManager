//
//  CTVCModelView.m
//  CTBundleManager
//
//  Created by ChuTing on 2018/1/31.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTVCModelView.h"
#import "NSString+JSON.h"
#import "CTBundleNode.h"
#import "NSDictionary+JSON.h"

@implementation CTVCModelView
-(instancetype)init
{
    self = [super init];
    if (self) {
        self.status = CTBundleManagerStatusNormal;
    }
    return self;
}

/** 初始化基本信息 */
-(void)readArguments:(NSString *)specPath
{
    self.ctripSpecPath = specPath;
    self.rootPath = [[specPath stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    
    NSError* error = nil;

    self.specContent = [[NSString alloc] initWithContentsOfURL:[NSURL fileURLWithPath:specPath]
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if(error || 0 == self.specContent.length){
        self.status = CTBundleManagerStatusRootError;
        return;
    }
    
    NSDictionary* ctripSpecDic = [self.specContent toDictionary:error];
    if(error || nil == ctripSpecDic){
        self.status = CTBundleManagerStatusRootError;
        return;
    }
    
    NSLog(@"ctripSpecDic = %@" , ctripSpecDic);
    
    self.ctripJsonPath = [self.rootPath stringByAppendingPathComponent:ctripSpecDic[@"CtripJSONPath"]];
    self.xcodeprojPath = [self.rootPath stringByAppendingPathComponent:ctripSpecDic[@"xcodeproj"]];
    
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
    
    [self updateLockConfig];
    
}
/** 更新本地lock */
-(void)updateLockConfig{
    if(NO == [self hasCtripJSONLockFile] || NO == [self diffCtripJSONFileAndLockFile]) {
        [self createCtripJSONLockFile];
    }
    /** 组织数据 */
    [self configNode];
}

-(NSDictionary *)descriptionContentByCtripJSONLockDic:(NSDictionary *)ctripJSONLockDic
{
    NSMutableDictionary* descriptionDic = [NSMutableDictionary dictionary];
    
    for (NSString* key in ctripJSONLockDic.allKeys) {
        NSDictionary* value = ctripJSONLockDic[key];
        if (![value isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        if ([key isEqualToString:@"Extension"]) {
            NSDictionary* extension = value;
            NSDictionary* baseBundles = extension[@"BaseBundle"];
            for (NSString* key in baseBundles.allKeys ) {
                NSDictionary* value = baseBundles[key];
                if (![value isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSString* ownerKey = value[@"owner"];
                NSMutableArray* array = descriptionDic[ownerKey];
                if(!array){
                    descriptionDic[ownerKey] = [NSMutableArray array];
                    array = descriptionDic[ownerKey];
                }
                NSString* buName = key;
                if (![array containsObject:buName]) {
                    [array addObject:buName];
                }
            }
            continue;
        }
        
        NSString* ownerKey = value[@"owner"];
        NSMutableArray* array = descriptionDic[ownerKey];
        if(!array){
            descriptionDic[ownerKey] = [NSMutableArray array];
            array = descriptionDic[ownerKey];
        }
        NSString* buName = key;
        if (![array containsObject:buName]) {
            [array addObject:buName];
        }
    }
    
    return descriptionDic;
}

-(void)configNode{
    NSString* ctripJSONLockContent = [[NSString alloc] initWithContentsOfFile:self.ctripJsonLockPath
                                                                     encoding:NSUTF8StringEncoding
                                                                        error:nil];
    NSDictionary* ctripJSONLockDic = [ctripJSONLockContent toDictionary:nil]; /** json */
    NSDictionary* ctripDescriptionDic = [self descriptionContentByCtripJSONLockDic:ctripJSONLockDic];/** 用来UI分组 */
    
    NSMutableArray* allNodes = [NSMutableArray array];
    
    NSMutableArray* excludeAllArray = [NSMutableArray array];
    NSMutableArray* bundleAllArray = [NSMutableArray array];
    NSMutableArray* sourceAllArray = [NSMutableArray array];

    /** 生成所有的node */
    for (NSString* key in ctripJSONLockDic.allKeys) {
        NSDictionary* dic = ctripJSONLockDic[key];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            if ([key.lowercaseString isEqualToString:@"extension"]) {
                /** 存起来其他扩展字段 */
                for (NSString* key in dic.allKeys) {
                    if (![key isEqualToString:@"AllBaseIsSource"] &&
                        ![key isEqualToString:@"BaseBundle"] &&
                        ![key isEqualToString:@"Debug"]
                        ) {
                        [self.extensionOtherFields setObject:dic[key] forKey:key];
                    }
                }
                self.allBaseIsSource = [dic[@"AllBaseIsSource"] boolValue]; //该字段暂时不配置
                self.debug = YES; /** 工具配死debug */ //[dic[@"Debug"] boolValue];
                NSDictionary* BaseBundle = dic[@"BaseBundle"];
            
                for (NSString* k in BaseBundle.allKeys) { /**  */
                    NSDictionary* d = BaseBundle[k];
                    if ([d isKindOfClass:[NSDictionary class]]) {
                        CTBundleNode* node = [[CTBundleNode alloc] initWithDictionary:d];
                        node.isExtension = YES;
                        node.name = k;
                        [allNodes addObject:node];
                        if (node.disable) {
                            [excludeAllArray addObject:node];
                        }else if (self.allBaseIsSource || node.isLib == NO){ /** 全部源码 */
                            [sourceAllArray addObject:node];
                        }else{
                            [bundleAllArray addObject:node];
                        }
                    }
                }
                continue;
                
            }
            CTBundleNode* node = [[CTBundleNode alloc] initWithDictionary:dic];
            node.name = key;
            [allNodes addObject:node];
            if (node.disable) {
                [excludeAllArray addObject:node];
            }else if (node.isLib){
                [bundleAllArray addObject:node];
            }else{
                [sourceAllArray addObject:node];
            }
        }
    }
    
    [self.excludeArray removeAllObjects];
    [self.bundleArray removeAllObjects];
    [self.sourceArray removeAllObjects];

    [self.excludeArray addObjectsFromArray:[self dealArray:excludeAllArray ctripDescriptionDic:ctripDescriptionDic]];
    [self.bundleArray addObjectsFromArray:[self dealArray:bundleAllArray ctripDescriptionDic:ctripDescriptionDic]];
    [self.sourceArray addObjectsFromArray:[self dealArray:sourceAllArray ctripDescriptionDic:ctripDescriptionDic]];

}
/** 将三组Array，处理成Group类型 */
-(NSMutableArray *)dealArray:(NSMutableArray*)array ctripDescriptionDic:(NSDictionary *)ctripDescriptionDic
{
    NSMutableArray* groupArray = [NSMutableArray array];
    if (array.count) {
        for (CTBundleNode* node in array) {
            for (NSString* key  in ctripDescriptionDic.allKeys) {
                NSArray* names = ctripDescriptionDic[key];
                if ([names containsObject:node.name]) {
                    CTBundleNode* rootNode = nil;
                    for (CTBundleNode* rn in groupArray) {
                        if ([rn.name isEqualToString:key]) {
                            rootNode = rn;
                            break;
                        }
                    }
                    if (nil == rootNode) {
                        rootNode = [[CTBundleNode alloc] initWithDictionary:@{
                                                                              @"name":key,
                                                                              @"SourceCodeLocalPath":@"",
                                                                              @"RemoteCodePath":@"",
                                                                              @"isLib":@(0),
                                                                              @"disable":@(0),
                                                                              @"dependency":@[]
                                                                              }];
                        [groupArray addObject:rootNode];
                    }
                    [rootNode addNode:node];
                    break;
                }
            }
        }
    }
    return groupArray;
}


/**
 将Node更新到lock中
 */
-(void)saveCtripJSONLockFile
{
    NSMutableDictionary* contentDictionary = [NSMutableDictionary dictionary];;
    NSMutableDictionary* extension = [NSMutableDictionary dictionary];
    [extension addEntriesFromDictionary:self.extensionOtherFields];
    [extension setObject:[NSNumber numberWithBool:self.allBaseIsSource] forKey:@"AllBaseIsSource"];
    [extension setObject:[NSNumber numberWithBool:self.debug] forKey:@"Debug"];
    NSMutableDictionary* baseBundles = [NSMutableDictionary dictionary];
    [extension setObject:baseBundles forKey:@"BaseBundle"];
    [contentDictionary setObject:extension forKey:@"Extension"];

    [contentDictionary setObject:self.appVersion forKey:@"Version"];
    [@[self.excludeArray , self.bundleArray , self.sourceArray] enumerateObjectsUsingBlock:^(NSArray*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(CTBundleNode*  _Nonnull root, NSUInteger rootIndex, BOOL * _Nonnull stop) {
            [root.childrens enumerateObjectsUsingBlock:^(CTBundleNode*  _Nonnull node, NSUInteger childrenIndex , BOOL * _Nonnull stop) {
                node.disable = (idx == 0);
                node.isLib = (idx == 1);
                NSDictionary* nodeDic = [node toDictionary];
                if (node.isExtension) {
                    if (self.allBaseIsSource) { /** 强制源码 */
                        node.isLib = NO;
                    }
                    [baseBundles setObject:nodeDic forKey:node.name];
                }else{
                    [contentDictionary setObject:nodeDic forKey:node.name];
                }
                
            }];
        }];
    }];
    
//    NSLog(@"contentDictionary = %@",contentDictionary);
    NSError* error = nil;
    NSString* contentDictionaryString = [contentDictionary toString:error];
    BOOL result = [contentDictionaryString writeToFile:self.ctripJsonLockPath
                              atomically:YES
                                encoding:NSUTF8StringEncoding
                                   error:&error];
    NSLog(@"result = %d",result);
}

#pragma mark - Private
-(BOOL)hasCtripJSONLockFile{
    return [[NSFileManager defaultManager] fileExistsAtPath:self.ctripJsonLockPath];
}

/** 不存在创建lock file */
-(BOOL)createCtripJSONLockFile{
    NSError* error = nil;

    if([self hasCtripJSONLockFile]){
        [[NSFileManager defaultManager] removeItemAtPath:self.ctripJsonLockPath
                                                   error:&error];
    }
    
    BOOL result = [[NSFileManager defaultManager] copyItemAtPath:self.ctripJsonPath
                                                          toPath:self.ctripJsonLockPath
                                                           error:&error];
    if (NO == result || error) {
        NSLog(@"error = %@" , error);
    }
    return result;
}
/** 配置不对返回NO ， 相同返回YES，返回NO需要delete lock */
-(BOOL)diffCtripJSONFileAndLockFile{
    NSError* error = nil;
    NSString* ctripJSONContent = [[NSString alloc] initWithContentsOfFile:self.ctripJsonPath
                                                                 encoding:NSUTF8StringEncoding
                                                                    error:&error];
    NSString* ctripJSONLockContent = [[NSString alloc] initWithContentsOfFile:self.ctripJsonLockPath
                                                                     encoding:NSUTF8StringEncoding
                                                                        error:&error];
    NSDictionary* ctripJSONDic =[ctripJSONContent toDictionary:error];
    NSDictionary* ctripJSONLockDic =[ctripJSONLockContent toDictionary:error];
    
    NSArray* ctripJSONAllKeys = [ctripJSONDic allKeys];
    NSArray* ctripJSONLockAllKeys = [ctripJSONLockDic allKeys];
    
    /** 先简单的diff */
    for (NSString* key in ctripJSONAllKeys) {
        if (![ctripJSONLockAllKeys containsObject:key]) {
            return NO;
        }
    }
    for (NSString* key in ctripJSONLockAllKeys) {
        if (![ctripJSONAllKeys containsObject:key]) {
            return NO;
        }
    }
    return YES;
    
}
#pragma mark - Getter

#define Getter(name) -(NSMutableArray *)name \
{ \
    if (!_##name) { \
        _##name = [NSMutableArray array]; \
    } \
    return _##name;\
}
Getter(excludeArray)
Getter(bundleArray)
Getter(sourceArray)

-(NSMutableDictionary *)extensionOtherFields
{
    if (!_extensionOtherFields) {
        _extensionOtherFields = [NSMutableDictionary dictionary];
    }
    return _extensionOtherFields;
}


- (BOOL)acceptDrag:(CTBundleNode*)node
{
    CTBundleNode* n = node;
    if (node.childrens.count) {
        n = node.childrens.firstObject;
    }
    if (n && [n respondsToSelector:@selector(isExtension)] && n.isExtension && self.allBaseIsSource) {
        return NO;
    }
    return YES;
}

@end
