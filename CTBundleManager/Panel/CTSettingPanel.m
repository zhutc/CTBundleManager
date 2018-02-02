//
//  CTSettingPanel.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/2/1.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTSettingPanel.h"

@interface CTSettingPanel()

@end


@implementation CTSettingPanel
+(CTSettingPanel *)settingPanel
{
    NSMutableArray* array = nil;
    NSNib* nib = [[NSNib alloc] initWithNibNamed:@"CTSettingPanel" bundle:[NSBundle mainBundle]];
    [nib instantiateWithOwner:nil topLevelObjects:&array];
    for (id obj in array) {
        if ([obj isKindOfClass:[CTSettingPanel class]]) {
            return obj;
        }
    }
    return nil;
}
-(IBAction)okAction:(id)sender{
    if (nil == self.pythonTextField.stringValue || 0 == self.pythonTextField.stringValue.length) {
        return;
    }
    [self.sheetParent endSheet:self];
}

@end
