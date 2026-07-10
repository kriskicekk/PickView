//
//  PVInspectionDefines.h
//  PickView
//
//  Created by kris cheng on 2026/7/9.
//

#import "TargetConditionals.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Appkit/Appkit.h>
#endif

#include <stdint.h>

#pragma mark - Version

/// current connection protocol version of PickViewServer
static const int PV_INSPECT_SERVER_VERSION = 7;

/// current release version of PickViewServer
static NSString * const PV_INSPECT_SERVER_READABLE_VERSION = @"1.2.8";

/// current connection protocol version of PickViewClient
static const int PV_INSPECT_CLIENT_VERSION = 7;

/// the minimum connection protocol version supported by current PickViewClient
static const int PV_INSPECT_SUPPORTED_SERVER_MIN = 7;
/// the maximum connection protocol version supported by current PickViewClient
static const int PV_INSPECT_SUPPORTED_SERVER_MAX = 7;

#pragma mark - Connection

/// PickViewServer 在真机上会依次尝试监听 47175 ~ 47179 这几个端口
static const int PVInspectUSBDeviceIPv4PortNumberStart = 47175;
static const int PVInspectUSBDeviceIPv4PortNumberEnd = 47179;

/// PickViewServer 在模拟器中会依次尝试监听 47164 ~ 47169 这几个端口
static const int PVInspectSimulatorIPv4PortNumberStart = 47164;
static const int PVInspectSimulatorIPv4PortNumberEnd = 47169;

enum {
    /// 确认两端是否可以响应通讯
    PVInspectRequestTypePing = 200,
    /// 请求 App 的截图、设备型号等信息
    PVInspectRequestTypeApp = 201,
    /// 请求 Hierarchy 信息
    PVInspectRequestTypeHierarchy = 202,
    /// 请求 screenshots 和 attrGroups 信息
    PVInspectRequestTypeHierarchyDetails = 203,
    /// 请求修改某个内置的 Attribute 的值
    PVInspectRequestTypeInbuiltAttrModification = 204,
    /// 修改某个 attr 后，请求一系列最新的 Screenshots、属性值等信息
    PVInspectRequestTypeAttrModificationPatch = 205,
    /// 执行某个方法
    PVInspectRequestTypeInvokeMethod = 206,
    /**
     @request: @{@"oid":}
     @response: PVObject *
     */
    PVInspectRequestTypeFetchObject = 207,
    
    PVInspectRequestTypeFetchImageViewImage = 208,
    
    PVInspectRequestTypeModifyRecognizerEnable = 209,
    
    /// 请求 attribute group list
    PVInspectRequestTypeAllAttrGroups = 210,
    
    /// 请求 iOS App 里某个 class 的所有 selector 名字列表（包括 superclass）
    PVInspectRequestTypeAllSelectorNames = 213,
    
    /// 请求修改某个自定义 Attribute 的值
    PVInspectRequestTypeCustomAttrModification = 214,
    
    /// 从 PickViewServer 1.2.7 & PickView 1.0.7 开始，该属性被废弃、不再使用
    PVInspectPush_BringForwardScreenshotTask = 303,
    
    // 用户在 PickView 客户端取消了之前 HierarchyDetails 的拉取
    PVInspectPush_CanceHierarchyDetails = 304,
};

static NSString * const PVInspectParam_ViewLayerTag = @"tag";

static NSString * const PVInspectParam_SelectorName = @"sn";
static NSString * const PVInspectParam_MethodType = @"mt";
static NSString * const PVInspectParam_SelectorClassName = @"scn";

static NSString * const PVInspectStringFlag_VoidReturn = @"PICKVIEW_TAG_RETURN_VALUE_VOID";

#pragma mark - Error

static NSString * const PVInspectErrorDomain = @"PVInspectError";

enum {
    PVInspectErrCode_Default = -400,
    /// PickView 内部业务逻辑错误
    PVInspectErrCode_Inner = -401,
    /// PeerTalk 内部错误
    PVInspectErrCode_PeerTalk = -402,
    /// 连接不存在或已断开
    PVInspectErrCode_NoConnect = -403,
    /// ping 失败了，原因是 ping 请求超时
    PVInspectErrCode_PingFailForTimeout = -404,
    /// 请求超时未返回
    PVInspectErrCode_Timeout = -405,
    /// 有相同 Type 的新请求被发出，因此旧请求被丢弃
    PVInspectErrCode_Discard = -406,
    /// ping 失败了，原因是 app 主动报告自身正处于后台模式
    PVInspectErrCode_PingFailForBackgroundState = -407,
    
    /// 没有找到对应的对象，可能已被释放
    PVInspectErrCode_ObjectNotFound = -500,
    /// 不支持修改当前类型的 PVCodingValueType
    PVInspectErrCode_ModifyValueTypeInvalid = -501,
    PVInspectErrCode_Exception = -502,
    
    // PickViewServer 版本过高，要升级 client
    PVInspectErrCode_ServerVersionTooHigh = -600,
    // PickViewServer 版本过低，要升级 server
    PVInspectErrCode_ServerVersionTooLow = -601,
    
    // 不支持的文件类型
    PVInspectErrCode_UnsupportedFileType = -700,
};

#define PVInspectErr_ObjNotFound [NSError errorWithDomain:PVInspectErrorDomain code:PVInspectErrCode_ObjectNotFound userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"Failed to get target object in iOS app", nil), NSLocalizedRecoverySuggestionErrorKey:NSLocalizedString(@"Perhaps the related object was deallocated. You can reload PickView to get newest data.", nil)}]

#define PVInspectErr_NoConnect [NSError errorWithDomain:PVInspectErrorDomain code:PVInspectErrCode_NoConnect userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"The operation failed due to disconnection with the iOS app.", nil)}]

#define PVInspectErr_Inner [NSError errorWithDomain:PVInspectErrorDomain code:PVInspectErrCode_Inner userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"The operation failed due to an inner error.", nil)}]

#define PVInspectErrorMake(errorTitle, errorDetail) [NSError errorWithDomain:PVInspectErrorDomain code:PVInspectErrCode_Default userInfo:@{NSLocalizedDescriptionKey:errorTitle, NSLocalizedRecoverySuggestionErrorKey:errorDetail}]

#define PVInspectErrorText_Timeout NSLocalizedString(@"Perhaps your iOS app is paused with breakpoint in Xcode, blocked by other tasks in main thread, or moved to background state.", nil)

#pragma mark - Colors

#if TARGET_OS_IPHONE
#define PVColor UIColor
#define PVInsets UIEdgeInsets
#define PVImage UIImage
#elif TARGET_OS_MAC
#define PVColor NSColor
#define PVInsets NSEdgeInsets
#define PVImage NSImage
#endif

#define PVColorRGBAMake(r, g, b, a) [PVColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define PVColorMake(r, g, b) [PVColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#pragma mark - Preview

/// SCNNode 所允许的图片的最大的长和宽，单位是 px，这个值是 Scenekit 自身指定的
/// Max pixel size of a SCNNode object. It is designated by SceneKit.
static const double PVNodeImageMaxLengthInPx = 16384;

typedef NS_OPTIONS(NSUInteger, PVPreviewBitMask) {
    PVPreviewBitMask_None = 0,
    
    PVPreviewBitMask_Selectable = 1 << 1,
    PVPreviewBitMask_Unselectable = 1 << 2,
    
    PVPreviewBitMask_HasLight = 1 << 3,
    PVPreviewBitMask_NoLight = 1 << 4
};

