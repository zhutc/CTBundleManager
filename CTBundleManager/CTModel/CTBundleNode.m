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
    [aCoder encodeObject:self.RemoteCodePath forKey:@"RemoteCodePath"];
    [aCoder encodeObject:self.SourceCodeLocalPath forKey:@"SourceCodeLocalPath"];
    [aCoder encodeObject:self.dependency forKey:@"dependency"];
    [aCoder encodeBool:self.isLib forKey:@"isLib"];
    [aCoder encodeBool:self.disable forKey:@"disable"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isLib = [aDecoder decodeBoolForKey:@"isLib"];
        self.disable = [aDecoder decodeBoolForKey:@"disable"];
        self.RemoteCodePath = [aDecoder decodeObjectForKey:@"RemoteCodePath"];
        self.SourceCodeLocalPath = [aDecoder decodeObjectForKey:@"SourceCodeLocalPath"];
        self.dependency = [aDecoder decodeObjectForKey:@"dependency"];
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
    return @{
             @"isLib":@(self.isLib),
             @"disable":@(self.disable),
             @"RemoteCodePath":self.RemoteCodePath,
             @"SourceCodeLocalPath":self.SourceCodeLocalPath,
             @"dependency":self.dependency,
             };
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"%@ key = %@",NSStringFromSelector(_cmd) , key);
}


@end
