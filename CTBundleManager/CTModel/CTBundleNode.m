//
//  CTBundleNode.m
//  CTBundleManager
//
//  Created by ChuTing on 2018/1/31.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTBundleNode.h"

@implementation CTBundleNode
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.remoteCodePath forKey:@"remoteCodePath"];
    [aCoder encodeObject:self.sourceCodeLocalPath forKey:@"sourceCodeLocalPath"];
    [aCoder encodeObject:self.owner forKey:@"owner"];
    [aCoder encodeObject:self.dependency forKey:@"dependency"];
    [aCoder encodeBool:self.isLib forKey:@"isLib"];
    [aCoder encodeBool:self.disable forKey:@"disable"];
    [aCoder encodeBool:self.hasResouceBundle forKey:@"hasResouceBundle"];
    [aCoder encodeBool:self.isExtension forKey:@"isExtension"];
    [aCoder encodeObject:self.releaseBundleVersion forKey:@"releaseBundleVersion"];
    [aCoder encodeObject:self.debugBundleVersion forKey:@"debugBundleVersion"];
    [aCoder encodeObject:self.releaseCommitId forKey:@"releaseCommitId"];
    [aCoder encodeObject:self.debugCommitId forKey:@"debugCommitId"];

}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.hasResouceBundle = [aDecoder decodeBoolForKey:@"hasResouceBundle"];
        self.isLib = [aDecoder decodeBoolForKey:@"isLib"];
        self.disable = [aDecoder decodeBoolForKey:@"disable"];
        self.owner = [aDecoder decodeObjectForKey:@"owner"];
        self.remoteCodePath = [aDecoder decodeObjectForKey:@"remoteCodePath"];
        self.sourceCodeLocalPath = [aDecoder decodeObjectForKey:@"sourceCodeLocalPath"];
        self.dependency = [aDecoder decodeObjectForKey:@"dependency"];
        self.isExtension = [aDecoder decodeBoolForKey:@"isExtension"];
        self.releaseBundleVersion = [aDecoder decodeObjectForKey:@"releaseBundleVersion"];
        self.debugBundleVersion = [aDecoder decodeObjectForKey:@"debugBundleVersion"];
        self.releaseCommitId = [aDecoder decodeObjectForKey:@"releaseCommitId"];
        self.debugCommitId = [aDecoder decodeObjectForKey:@"debugCommitId"];
    }
    return self;
}
-(instancetype)initWithDictionary:(NSDictionary*)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
-(NSDictionary *)toDictionary
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                               @"hasResouceBundle":@(self.hasResouceBundle),
                                                                               @"isLib":@(self.isLib),
                                                                               @"disable":@(self.disable),
                                                                               @"remoteCodePath":self.remoteCodePath,
                                                                               @"owner":self.owner,
                                                                               @"sourceCodeLocalPath":self.sourceCodeLocalPath,
                                                                               @"dependency":self.dependency,
                                                                               }];
    if (self.isExtension) {
        [dic addEntriesFromDictionary:@{
                                        @"releaseCommitId":self.releaseCommitId,
                                        @"debugCommitId":self.debugCommitId,
                                        @"releaseBundleVersion":self.releaseBundleVersion,
                                        @"debugBundleVersion":self.debugBundleVersion,
                                        }];
    }
    
    return dic;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"%@ key = %@",NSStringFromSelector(_cmd) , key);
}


@end
