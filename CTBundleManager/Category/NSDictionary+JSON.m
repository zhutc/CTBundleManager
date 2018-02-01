//
//  NSDictionary+JSON.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/2/1.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)
-(NSString *)toString:(NSError*)error
{
    if (nil == self) {
        return nil;
    }
    NSData* data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (!data || 0 == data.length || error) {
        return nil;
    }
    return [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
}
@end
