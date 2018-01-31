//
//  NSString+JSON.h
//  CTBundleManager
//
//  Created by 朱天超 on 2018/1/31.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)
- (NSDictionary *)toDictionary:(NSError*)error;
- (NSArray *)toArray:(NSError*)error;
@end
