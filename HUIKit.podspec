#
# Be sure to run `pod lib lint HUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HUIKit'
  s.version          = '0.1.2'
  s.summary          = 'HUIKit For Mac App'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A Swift UI Components For Mac App Develop
                       DESC

  s.homepage         = 'https://github.com/hanxiaoqing19910916/HUIKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '190658047@qq.com' => 'xiaoqing@han.com' }
  s.source           = { :git => 'https://github.com/hanxiaoqing19910916/HUIKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.osx.deployment_target = "10.10"

  s.source_files = 'HUIKit/Classes/**/*'

 s.subspec 'SwiftExtention' do |ss|
    ss.source_files = 'HUIKit/Classes/SwiftExtention/*'
 end


#s.osx.vendored_frameworks = 'Example/Build/Products/Release/HUIKit.framework'
  # s.resource_bundles = {
  #   'HUIKit' => ['HUIKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
