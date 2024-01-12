#
# Be sure to run `pod lib lint Impose.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Impose'
  s.version          = '3.5.0'
  s.summary          = 'Simple dependency injection library for Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Impose is a simple dependency injection library for Swift
                       DESC

  s.homepage         = 'https://github.com/hainayanda/Impose'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nayanda' => 'hainayanda@outlook.com' }
  s.source           = { :git => 'https://github.com/hainayanda/Impose.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '4.0'

  s.source_files = 'Impose/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Impose' => ['Impose/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Chary', '~> 1.0.7'
  s.swift_version = '5.1'
end
