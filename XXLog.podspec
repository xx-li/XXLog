#
# Be sure to run `pod lib lint XXLog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XXLog'
  s.version          = '0.1.0'
  s.summary          = '基于Mars xlog组件封装的日志框架，可以方便的在OC和Swift中进行使用。'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  XXLog是一个基于Mars的xlog组件封装的日志框架，提供便捷的api，可以方便的在OC和Swift中进行使用。
                       DESC

  s.homepage         = 'https://github.com/xx-li/XXLog'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lixinxing' => 'x@devlxx.com' }
  s.source           = { :git => 'https://github.com/xx-li/XXLog.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.swift_versions = '5.0'

  s.source_files = 'XXLog/Classes/**/*'
  s.vendored_frameworks = "XXLog/Frameworks/mars.xcframework"
  s.frameworks = 'Foundation','CoreTelephony','SystemConfiguration'
  s.libraries = 'z','resolv.9'
  s.public_header_files = 'XXLog/Classes/*.h'

end
