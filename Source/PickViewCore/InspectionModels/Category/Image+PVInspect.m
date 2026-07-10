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
    CGImageRef imageRef = [self CGImageForProposedRect:NULL context:nil hints:nil];
    if (!imageRef) {
        return nil;
    }
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    return [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
}

@end

#endif
