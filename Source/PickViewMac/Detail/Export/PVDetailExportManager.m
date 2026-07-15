//
//  PVDetailExportManager.m
//  PickViewMac
//
//  Created by kris cheng on 2026/7/9.
//

#import "PVDetailPrefix.h"
#import "PVDetailExportManager.h"
#import "PVHierarchyInfo.h"
#import "PVHierarchyFile.h"
#import "PVAppInfo.h"
#import "PVDisplayItem.h"
#import "PVDetailDocument.h"
#import "PVDetailHelper.h"
#import "PVDetailNavigationManager.h"
#import "PVDisplayItem+PVClient.h"

@implementation PVDetailExportManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PVDetailExportManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (NSData *)dataFromHierarchyInfo:(PVHierarchyInfo *)info imageCompression:(CGFloat)compression fileName:(NSString **)fileName {
    PVHierarchyFile *file = [PVHierarchyFile new];
    file.serverVersion = info.serverVersion;
    file.hierarchyInfo = info;
    
    NSMutableDictionary<NSString *, NSData *> *soloScreenshots = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, NSData *> *groupScreenshots = [NSMutableDictionary dictionary];
    
    NSArray<PVDisplayItem *> *allItems = [PVDisplayItem flatItemsFromHierarchicalItems:info.displayItems];
    BOOL preferViewOid = [PVDetailHelper appInfoLooksLikeMacTarget:info.appInfo];
    [allItems enumerateObjectsUsingBlock:^(PVDisplayItem * _Nonnull displayItem, NSUInteger idx, BOOL * _Nonnull stop) {
        displayItem.screenshotEncodeType = PVDisplayItemImageEncodeTypeNone;
        unsigned long oid = [displayItem bestObjectOidPreferView:preferViewOid];
        if (!oid) {
            return;
        }
        NSData *soloData = [self _compressedDataFromImage:displayItem.soloScreenshot compression:compression];
        NSData *groupData = [self _compressedDataFromImage:displayItem.groupScreenshot compression:compression];
        if (soloData) {
            soloScreenshots[@(oid)] = soloData;
        }
        if (groupData) {
            groupScreenshots[@(oid)] = groupData;
        }
    }];
    file.soloScreenshots = soloScreenshots.copy;
    file.groupScreenshots = groupScreenshots.copy;
    
    PVDetailDocument *document = [[PVDetailDocument alloc] init];
    document.hierarchyFile = file;
    NSError *error;
    NSData *exportedData = [document dataOfType:@"com.pickview.pickview" error:&error];
    if (error) {
        NSAssert(NO, @"");
    }
    
    if (fileName) {
        NSString *timeString = ({
            NSDate *date = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMddHHmm"];
            [formatter stringFromDate:date];
        });
        NSString *iOSVersion = ({
            NSString *str = info.appInfo.osDescription;
            NSUInteger dotIdx = [str rangeOfString:@"."].location;
            if (dotIdx != NSNotFound) {
                str = [str substringToIndex:dotIdx];
            }
            str;
        });
        *fileName = [NSString stringWithFormat:@"%@_ios%@_%@.pickview", info.appInfo.appName, iOSVersion, timeString];
        
    }
    
    return exportedData;
}

/// compression 范围从 0.01 ~ 1
- (NSData *)_compressedDataFromImage:(PVImage *)sourceImage compression:(CGFloat)compression {
    if (!sourceImage) {
        return nil;
    }
    
#if TARGET_OS_IPHONE
    return nil;
    
#elif TARGET_OS_MAC
    
    compression = MAX(MIN(compression, 1), 0.01);
    
    NSSize targetSize = NSMakeSize(sourceImage.size.width * compression, sourceImage.size.height * compression);
    NSRect targetFrame = NSMakeRect(0, 0, targetSize.width, targetSize.height);
    NSImageRep *sourceImageRep = [sourceImage bestRepresentationForRect:targetFrame context:nil hints:nil];
    
    NSImage *resizedImage = [[NSImage alloc] initWithSize:targetSize];
    [resizedImage lockFocus];
    [sourceImageRep drawInRect:targetFrame];
    [resizedImage unlockFocus];
    
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:[resizedImage TIFFRepresentation]];
    NSData *compressedData = [imageRep TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
    return compressedData;
#endif
}

+ (void)exportScreenshotWithDisplayItem:(PVDisplayItem *)displayItem {
    NSImage *image = displayItem.groupScreenshot;
    if (!image) {
        AlertError(PVInspectErr_Inner, CurrentKeyWindow);
        return;
    }
    
    NSData *imageData = [image TIFFRepresentationUsingCompression:NSTIFFCompressionLZW factor:1];
    if (!imageData) {
        AlertError(PVInspectErr_Inner, CurrentKeyWindow);
        return;
    }
    
    NSString *fileName = [displayItem title] ? : @"PVImage";

    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:fileName];
    [panel setAllowsOtherFileTypes:NO];
    [panel setAllowedFileTypes:@[@"tiff"]];
    [panel setExtensionHidden:YES];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:CurrentKeyWindow completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSString *path = [[panel URL] path];
            NSError *writeError;
            BOOL writeSucc = [imageData writeToFile:path options:0 error:&writeError];
            if (!writeSucc) {
                AlertError(writeError, CurrentKeyWindow);
                NSAssert(NO, @"");
            }
        }
    }];
}

@end
