#
# Be sure to run `pod lib lint LiveSignSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LiveSignSDK"
  s.version          = "0.1.1"
  s.summary          = "Add signing abilities to your app"

  s.description      = <<-DESC
    Add signing abilities to your app. Written is Swift.
  DESC

  s.homepage         = "https://github.com/Erez-Panda/LiveBankSDK"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Erez Haim" => "erez@livemed.co" }
  s.source           = { :git => "https://github.com/Erez-Panda/LiveBankSDK.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'LiveSignSDK' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking'
  s.dependency 'FontAwesomeIconFactory'

end
