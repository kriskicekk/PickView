# Flutter Inspection

This directory adapts `KKFlutterInspectorKit` snapshots to PickView's wire
models. VM Service connection management, Inspector requests, snapshot object
groups, tree building, property fetching, and Flutter screenshots belong to
`KKFlutterInspectorKit`.

## Runtime Flow

1. `PVHierarchyHandler` asks the provider to start Flutter preparation, then
   returns the normal UIKit snapshot without waiting for VM Service.
2. `PVFlutterHierarchyCoordinator` finds visible `FlutterViewController`
   instances already attached to the requested `UIWindow`; their host views
   appear in the initial tree as loading leaf nodes.
3. The coordinator warms `KKFlutterInspectorKit` and asks the Kit for one
   hierarchy snapshot per visible Flutter page.
4. The Kit owns reusable engine sessions and calls the Flutter Inspector
   service extensions needed for Widget metadata and RenderObject geometry.
5. The first asynchronous detail request waits for the pending snapshot,
   converts each `KKFIInspectorElement` into a virtual `PVDisplayItem`, and
   replaces the loading host's subitems on the Mac client.
6. A follow-up detail pass lazily asks the Kit for Flutter properties and
   screenshots through `KKFIElementReference`.

## Multiple Engines

`KKFlutterInspectorKit` owns engine and isolate identity. PickView stores only
the opaque snapshot and element references returned by the Kit, so it cannot
accidentally reuse an object ID after an isolate or object group changes.

## VM Service URI

The in-process integration does not parse system logs. The Kit resolves the
debug engine's `vmServiceUrl` and `isolateId`. Release engines do not expose VM
Service or Inspector extensions; in that case PickView still returns the
native UIKit hierarchy.

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

Screenshots are fetched on demand through `KKFlutterInspectorKit`. A group
screenshot is the complete Flutter subtree. For an expanded parent with a
supported native decoration, PickView draws the solo image from color, border,
radius, and shadow diagnostics so child pixels are not duplicated. Layout-only
nodes do not produce PNG data. A self-painting parent whose own pixels cannot
be reconstructed is treated as an atomic subtree: PickView shows the complete
subtree image and keeps its descendants available for hierarchy selection and
property inspection without layering their screenshots a second time.
