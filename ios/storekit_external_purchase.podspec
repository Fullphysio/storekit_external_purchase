Pod::Spec.new do |s|
  s.name             = 'storekit_external_purchase'
  s.version          = '0.1.0'
  s.summary          = 'StoreKit External Purchase Custom Link APIs for Flutter.'
  s.description      = <<-DESC
Flutter plugin exposing Apple's StoreKit External Purchase Custom Link APIs: eligibility, the system disclosure notice and reporting tokens.
                       DESC
  s.homepage         = 'https://github.com/Fullphysio/storekit_external_purchase'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Fullphysio' => 'hello@fullphysio.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'storekit_external_purchase/Sources/storekit_external_purchase/**/*.swift'
  s.resource_bundles = { 'storekit_external_purchase_privacy' => ['storekit_external_purchase/Sources/storekit_external_purchase/PrivacyInfo.xcprivacy'] }
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.frameworks = 'StoreKit'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
