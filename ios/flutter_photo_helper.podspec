#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_photo_helper'
  s.version          = '0.1.0'
  s.summary          = 'Flutter Photo Helper.'
  s.description      = <<-DESC
  Flutter Photo Helper.
                       DESC
  s.homepage         = 'http://www.blackharry.com/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'dragonetail@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '9.0'
  s.swift_version = '4.2'
end

