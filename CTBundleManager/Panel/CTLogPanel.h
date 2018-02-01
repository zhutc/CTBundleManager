//
//  CTLogPanel.h
//  CTBundleManager
//
//  Created by 朱天超 on 2018/2/1.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CTLogPanel : NSPanel
+(CTLogPanel *)logPanel;
-(void)start;
-(void)end;
-(void)upateCotent:(NSString *)text;
@end
