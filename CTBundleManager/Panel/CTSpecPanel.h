//
//  CTSpecPanel.h
//  CTBundleManager
//
//  Created by 朱天超 on 2018/2/1.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CTSpecPanel;

@protocol CTSpecPanelProtocol <NSObject>
-(void)panel:(CTSpecPanel*)panel didChooseFileURL:(NSArray*)url modalResponse:(NSModalResponse)result;
@end

@interface CTSpecPanel : NSPanel
@property (nonatomic , weak) id<CTSpecPanelProtocol> delegate;
+(CTSpecPanel *)specPanel;
@end


