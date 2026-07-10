//
//  PVWindowInfo.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#ifndef PVWindowInfo_h
#define PVWindowInfo_h

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVWindowInfo : NSObject <NSSecureCoding, NSCopying>

@property (nonatomic, copy) NSString *windowID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign, getter=isKeyWindow) BOOL keyWindow;
@property (nonatomic, assign, getter=isMainWindow) BOOL mainWindow;
@property (nonatomic, assign, getter=isVisible) BOOL visible;
@property (nonatomic, assign) NSInteger level;

@end

NS_ASSUME_NONNULL_END

#endif /* PVWindowInfo_h */
