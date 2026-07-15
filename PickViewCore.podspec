Pod::Spec.new do |s|
  s.name = 'PickViewCore'
  s.version = '0.1.0'
  s.summary = 'Shared connection contracts, wire models, and inspection DTOs for PickView.'
  s.homepage = 'https://github.com/kriskicekk/PickView'
  s.license = {
    :type => 'GPL-3.0',
    :file => 'Source/PickViewCore/InspectionModels/LICENSE.PickView-GPL-3.0.txt'
  }
  s.author = 'kris cheng'
  s.source = {
    :git => 'https://github.com/kriskicekk/PickView.git',
    :tag => s.version.to_s
  }

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '11.0'
  s.requires_arc = true
  s.module_name = 'PickViewCore'
  s.header_dir = 'PickViewCore'

  s.source_files = 'Source/PickViewCore/**/*.{h,m}'
  s.public_header_files = [
    'Source/PickViewCore/PickViewCore.h',
    'Source/PickViewCore/Connection/*.h',
    'Source/PickViewCore/Constant/*.h',
    'Source/PickViewCore/Discovery/*.h',
    'Source/PickViewCore/Endpoint/*.h',
    'Source/PickViewCore/Error/*.h',
    'Source/PickViewCore/Identity/*.h',
    'Source/PickViewCore/InspectionModels/**/*.h',
    'Source/PickViewCore/Utils/*.h',
    'Source/PickViewCore/Wire/Codec/*.h',
    'Source/PickViewCore/Wire/Frame/*.h',
    'Source/PickViewCore/Wire/Message/*.h'
  ]
  s.private_header_files = 'Source/PickViewCore/Wire/Legacy/*.h'

  s.ios.frameworks = 'Foundation', 'UIKit', 'QuartzCore'
  s.osx.frameworks = 'Foundation', 'AppKit', 'QuartzCore'
end
