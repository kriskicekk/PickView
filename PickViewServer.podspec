Pod::Spec.new do |s|
  s.name = 'PickViewServer'
  s.version = '0.1.0'
  s.summary = 'The embeddable iOS and macOS inspection server for PickView.'
  s.homepage = 'https://github.com/kris/PickView'
  s.license = {
    :type => 'GPL-3.0',
    :file => 'Source/PickViewCore/InspectionModels/LICENSE.PickView-GPL-3.0.txt'
  }
  s.author = 'kris cheng'
  s.source = {
    :git => 'https://github.com/kris/PickView.git',
    :tag => s.version.to_s
  }

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '11.0'
  s.requires_arc = true
  s.module_name = 'PickViewServer'
  s.header_dir = 'PickViewServer'

  s.source_files = [
    'Source/PickViewServerKit/Public/*.{h,m}',
    'Source/PickViewServerKit/Internal/*.{h,m}',
    'Source/PickViewServerKit/Internal/Inspection/Common/**/*.{h,m}',
    'Source/PickViewServerKit/Internal/RequestHandling/**/*.{h,m}',
    'Source/PickViewServerKit/Internal/Session/**/*.{h,m}',
    'Source/PickViewTransport/Common/*.{h,m}',
    'Source/PickViewTransport/LAN/PVLANConnection.{h,m}',
    'Source/PickViewTransport/LAN/PVLANConstants.h',
    'Source/PickViewTransport/LAN/PVLANEndpoint.{h,m}',
    'Source/PickViewTransport/LAN/Server/**/*.{h,m}',
    'Source/PickViewTransport/Loopback/PVLoopbackConnection.{h,m}',
    'Source/PickViewTransport/Loopback/PVLoopbackEndpoint.{h,m}',
    'Source/PickViewTransport/Loopback/Server/**/*.{h,m}'
  ]
  s.ios.source_files = 'Source/PickViewServerKit/Internal/Inspection/iOS/**/*.{h,m}'
  s.osx.source_files = 'Source/PickViewServerKit/Internal/Inspection/macOS/**/*.{h,m}'
  s.public_header_files = 'Source/PickViewServerKit/Public/*.h'
  s.private_header_files = [
    'Source/PickViewServerKit/Internal/Inspection/Common/**/*.h',
    'Source/PickViewServerKit/Internal/RequestHandling/**/*.h',
    'Source/PickViewServerKit/Internal/Session/**/*.h',
    'Source/PickViewTransport/Common/*.h',
    'Source/PickViewTransport/LAN/PVLANConnection.h',
    'Source/PickViewTransport/LAN/PVLANConstants.h',
    'Source/PickViewTransport/LAN/PVLANEndpoint.h',
    'Source/PickViewTransport/LAN/Server/*.h',
    'Source/PickViewTransport/Loopback/PVLoopbackConnection.h',
    'Source/PickViewTransport/Loopback/PVLoopbackEndpoint.h',
    'Source/PickViewTransport/Loopback/Server/*.h'
  ]
  s.ios.private_header_files = 'Source/PickViewServerKit/Internal/Inspection/iOS/**/*.h'
  s.osx.private_header_files = 'Source/PickViewServerKit/Internal/Inspection/macOS/**/*.h'

  s.frameworks = 'Foundation', 'QuartzCore', 'Network'
  s.ios.frameworks = 'UIKit'
  s.osx.frameworks = 'AppKit'
  s.dependency 'PickViewCore', s.version.to_s
  s.dependency 'PeerTalk', '0.1.0'
  s.ios.dependency 'KKFlutterInspectorKit', '0.1.0'

  # Auto-start relies on Objective-C +load, which must survive static linking.
  s.user_target_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -ObjC'
  }
end
