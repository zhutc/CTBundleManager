//
//  NSString+JSON.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/31.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "NSString+JSON.h"

@implementation NSString (JSON)
-(id)toContainer:(NSError*)error{
    if(0 == self.length){
        return nil;
    }
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (!data || 0 == data.length) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
}
- (NSDictionary *)toDictionary:(NSError*)error{
    return [self toContainer:error];
}
- (NSArray *)toArray:(NSError*)error
{
    return [self toContainer:error];
}
@end
