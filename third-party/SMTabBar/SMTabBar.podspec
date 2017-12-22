#
#  Be sure to run `pod spec lint SMTabBar.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "SMTabBar"
  s.version      = "0.0.1"
  s.summary      = "Tab bar like in the Xcode inspector."
  s.homepage     = "https://github.com/smic/InspectorTabBar"
  s.license      = { :type => "MIT" }
  s.author       = { "smic" => "stephan.michels@gmail.com" }
  s.source       = { :git => "git@github.com:smic/InspectorTabBar.git" }
  s.source_files = "InspectorTabBar/**/*.{h,m}"
  s.platform     = :osx, "10.10"
  # s.public_header_files = "Classes/**/*.h"
  # s.requires_arc = true
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
