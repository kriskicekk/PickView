# Flutter Inspection

This directory implements Flutter inspection as an internal PickViewServer
source feature. It is not a separate Pod.

## Runtime Flow

1. `PVHierarchyHandler` calls the provider's optional asynchronous preparation
   method before taking the normal UIKit snapshot.
2. `PVFVMFlutterEngineLocator` walks the current `UIWindow` controller graph and
   discovers `FlutterViewController` instances with `NSClassFromString`.
3. `PVFVMInspectorKit` caches the exact
   `FlutterViewController -> FlutterEngine -> PVFVMEngineInspectorSession`
   relationship. Records are removed when their view controller deallocates.
4. The session reads `FlutterEngine.vmServiceUrl` and `isolateId`, connects with
   `NSURLSessionWebSocketTask`, calls `getVM`, and then calls Flutter Inspector
   service extensions.
5. `getRootWidgetTree` supplies Widget metadata. `getLayoutExplorerNode`
   supplies RenderObject geometry and parent-relative coordinates.
6. `PVFlutterHierarchyCoordinator` converts the result into virtual
   `PVDisplayItem` nodes and attaches them below the native Flutter root view.
7. Existing PickView detail tasks lazily call `getProperties` and
   `ext.flutter.inspector.screenshot` for Flutter nodes.

## Multiple Engines

Sessions are keyed by `FlutterEngine`, not by isolate name. A visible Flutter
view is resolved through its owning `FlutterViewController.engine`, so two
engines receive independent object groups, object IDs, VM URLs, and caches.
The same engine is prepared only once per window snapshot.

## VM Service URI

The in-process integration does not parse system logs. It waits for the debug
engine's `vmServiceUrl` and `isolateId` properties. Log parsing remains useful
for an external launcher, but an App reading its own unified system log is not
reliable. Release engines do not expose VM Service or Inspector extensions; in
that case PickView still returns the native UIKit hierarchy.

## PickView Model

The native Flutter root remains a normal PickView item. Its virtual children
use `PVDisplayItemContentKindFlutter` and carry `PVFlutterNodeReference` plus a
Flutter-specific detail model:

- visual rows: concrete RenderObjects with geometry; `SizedBox` remains a row
- children layouts: `Column`, `Row`, `Flex`, `Stack`, and similar layout groups
- layout modifiers: `Padding`, `SafeArea`, `Center`, `Align`, and constraints
- interactions: gesture, pointer, focus, action, and shortcut wrappers
- semantics: accessibility wrappers
- rendering: paint role, screenshot strategy, decoration, text preview, and
  raw diagnostics JSON

Unknown widgets with a concrete RenderObject remain visible instead of being
dropped. The Mac client switches to `PVDetailFlutterViewController` for these
nodes; native items continue using the existing dashboard model.

## Screenshots

Screenshots are fetched on demand. Group screenshots use
`ext.flutter.inspector.screenshot`. For an expanded parent with a supported
solid `BoxDecoration`, the solo image is drawn from color, border, radius, and
shadow diagnostics so child pixels are not duplicated. Layout-only nodes do
not produce PNG data.

In Debug builds every VM JSON-RPC call is also written below the inspected
App's Documents directory under `PickViewFlutterVMJSON/<session>/`.
