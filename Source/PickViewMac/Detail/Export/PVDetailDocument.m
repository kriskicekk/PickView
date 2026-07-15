//
//  PVDetailDocument.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailDocument.h"
#import "PVHierarchyFile.h"
#import "PVDetailReadWindowController.h"
#import "PVDetailNavigationManager.h"

// 点击 menu 里的 “打开文件” 会走到这里的一系列方法
@implementation PVDetailDocument

- (void)makeWindowControllers {
    PVDetailReadWindowController *wc = [[PVDetailReadWindowController alloc] initWithFile:self.hierarchyFile];
    [self addWindowController:wc];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    if (!self.hierarchyFile) {
        NSAssert(NO, @"");
        if (outError) {
            *outError = PVInspectErr_Inner;
        }
        return nil;
    }
    
    if ([typeName isEqualToString:@"com.pickview.pickview"]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.hierarchyFile requiringSecureCoding:YES error:outError];
        return data;
    }
    
    if (outError) {
        *outError = PVInspectErr_Inner;
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {    
    NSError *unarchiveError = nil;
    PVHierarchyFile *hierarchyFile = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:data error:&unarchiveError];
    
    if (unarchiveError) {
        if (outError) {
            *outError = unarchiveError;
        }
        return NO;
    }
    
    NSError *verifyError = [PVHierarchyFile verifyHierarchyFile:hierarchyFile];
    if (verifyError) {
        if (outError) {
            *outError = verifyError;
        }
        return NO;
    }

    self.hierarchyFile = hierarchyFile;
    return YES;
}

@end
