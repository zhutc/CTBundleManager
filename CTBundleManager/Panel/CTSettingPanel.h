//
//  CTSettingPanel.h
//  CTBundleManager
//
//  Created by 朱天超 on 2018/2/1.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CTSettingPanel : NSPanel
@property (weak) IBOutlet NSTextField *ctripSpecTextField;
@property (weak) IBOutlet NSTextField *pythonTextField;
+(CTSettingPanel *)settingPanel;
@end
