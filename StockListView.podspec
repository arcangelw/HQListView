#
# Be sure to run `pod lib lint HQListView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'StockListView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of HQListView.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/arcangelw/HQListView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'arcangelw' => 'wuzhezmc@gmail.com' }
  s.source           = { :git => 'https://github.com/arcangelw/HQListView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.requires_arc = true
  s.swift_version = '5.3'
  s.source_files = 'StockListView/Classes/**/*.swift'
  
  # s.resource_bundles = {
  #   'HQListView' => ['HQListView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit'
  s.dependency 'Then'
  s.static_framework = true
  s.user_target_xcconfig = {
      'OTHER_LDFLAGS' => '-ObjC',
      'VALID_ARCHS' => 'x86_64 armv7 arm64'
  }
end
