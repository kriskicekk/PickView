//
//  PVDetailFlutterViewController.h
//  PickViewMac
//

#import "PVDetailBaseViewController.h"

@class PVDisplayItem, PVFlutterNodeDetail;

extern const CGFloat PVFlutterInspectorPanelWidth;

@interface PVDetailFlutterViewController : PVDetailBaseViewController

@property(nonatomic, strong, nullable) PVFlutterNodeDetail *detail;
@property(nonatomic, strong, nullable) PVDisplayItem *displayItem;

@end
