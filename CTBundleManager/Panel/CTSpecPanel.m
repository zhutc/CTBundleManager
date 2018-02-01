//
//  CTSpecPanel.m
//  CTBundleManager
//
//  Created by 朱天超 on 2018/2/1.
//  Copyright © 2018年 ctrip.com. All rights reserved.
//

#import "CTSpecPanel.h"

@interface CTSpecPanel()

@end

@implementation CTSpecPanel
@synthesize delegate;


+(CTSpecPanel *)specPanel
{
    NSMutableArray* array = nil;
    NSNib* nib = [[NSNib alloc] initWithNibNamed:@"CTSpecPanel" bundle:[NSBundle mainBundle]];
    [nib instantiateWithOwner:nil topLevelObjects:&array];
    for (id obj in array) {
        if ([obj isKindOfClass:[CTSpecPanel class]]) {
            return obj;
        }
    }
    return nil;
}


-(IBAction)chooseAction:(id)sender
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = YES;
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = @[@"spec"];
    __weak NSOpenPanel* weakpanel = openPanel;
    [openPanel beginWithCompletionHandler:^(NSModalResponse result) {
        if (NSModalResponseOK == result) {
            NSArray* urls = weakpanel.URLs;
            if ([self.delegate respondsToSelector:@selector(panel:didChooseFileURL:modalResponse:)]) {
                [self.delegate panel:self didChooseFileURL:urls modalResponse:result];
            }
            
            [self.sheetParent endSheet:self
                            returnCode:NSModalResponseOK];
        }
        
    }];
}
@end
