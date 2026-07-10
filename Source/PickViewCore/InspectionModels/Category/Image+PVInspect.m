//
//  Image+PVInspect.m
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "Image+PVInspect.h"

#if TARGET_OS_IPHONE

@implementation UIImage (PVInspect)

- (NSData *)pv_inspect_data {
    return UIImagePNGRepresentation(self);
}

@end

#elif TARGET_OS_OSX

@implementation NSImage (PVInspect)

- (NSData *)pv_inspect_data {
    NSBitmapImageRep *bestBitmapRep = nil;
    for (NSImageRep *imageRep in self.representations) {
        if (![imageRep isKindOfClass:NSBitmapImageRep.class]) {
            continue;
        }
        NSBitmapImageRep *bitmapRep = (NSBitmapImageRep *)imageRep;
        if (!bestBitmapRep || bitmapRep.pixelsWide * bitmapRep.pixelsHigh > bestBitmapRep.pixelsWide * bestBitmapRep.pixelsHigh) {
            bestBitmapRep = bitmapRep;
        }
    }
    if (bestBitmapRep) {
        NSData *data = [bestBitmapRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        if (data.length) {
            return data;
        }
    }

    CGImageRef imageRef = [self CGImageForProposedRect:NULL context:nil hints:nil];
    if (!imageRef) {
        return nil;
    }
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    return [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
}

@end

#endif
