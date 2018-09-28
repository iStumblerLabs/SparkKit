#!pod

# SparkKit.podspec - Requires `sudo gem install cocoapods -v 1.6.0.beta.1`

Pod::Spec.new do |s|
  s.name             = 'SparkKit'
  s.module_name      = 'SparkKit'
  s.version          = '1.1'
  s.summary          = 'Small, Simple and Fast; Line, Pie, Dial and Bar Views for macOS, iOS and tvOS'
  s.description      = 'Small, Simple and Fast; Line, Pie, Dial and Bar Views for macOS, iOS and tvOS'
  s.homepage         = 'https://github.com/alfwatt/SparkKit'
  s.license          = { :type => 'MIT', :file => 'README.md' }
  s.authors          = { 'iStumbler Labs, Alf Watt' => 'alf@istumbler.net' }
  s.source           = { :git => 'https://github.com/alfwatt/SparkKit.git', :branch => 'master' }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'

  s.source_files = '**/SparkKit/*.{h,m,swift}'
  s.exclude_files = '**/Sparky/**'
  s.public_header_files = '**/*.h'
  s.requires_arc = true
  s.framework = 'KitBridge'

  s.dependency 'KitBridge'
end

