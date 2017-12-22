#
#  Be sure to run `pod spec lint SPMediaKeyTap.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "SPMediaKeyTap"
  s.version      = "0.0.1"
  s.summary      = "SPMediaKeyTap is a global event tap for the play/pause, prev and next keys on the keyboard."
  s.homepage     = "https://github.com/nevyn/SPMediaKeyTap"
  s.license      = { :type => "BSD 3-Clause"}
  s.author       = { "nevyn" => "nevyn.jpg@gmail.com" }
  s.platform     = :osx
  # s.osx.deployment_target = "10.7"
  s.source       = { :git => "git://github.com/sonoramac/SPMediaKeyTap.git" }
  s.source_files = 'SPMediaKeyTap.{h,m}', 'SPInvocationGrabbing/NSObject+SPInvocationGrabbing.{h,m}'
  # s.public_header_files = "Classes/**/*.h"
  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"
  # s.frameworks = "SomeFramework", "AnotherFramework"
  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"
  s.requires_arc = false
  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
