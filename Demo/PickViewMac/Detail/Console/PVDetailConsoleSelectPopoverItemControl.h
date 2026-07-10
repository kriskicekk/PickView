//
//  PVDetailConsoleSelectPopoverItemControl.h
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailBaseControl.h"

@class PVObject;

@interface PVDetailConsoleSelectPopoverItemControl : PVDetailBaseControl

@property(nonatomic, assign) BOOL isChecked;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

@property(nonatomic, strong) PVObject *representedObject;

@end
