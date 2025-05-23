require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::UI.puts "[BDtren] Thank you for choosing react-native-external-keyboard-listener, it will be worth it 😎👌🔥"

Pod::Spec.new do |s|
  s.name         = "ExternalKeyboardListener"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/bdtren/react-native-external-keyboard-listener.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'USE_FRAMEWORKS' => 'YES', 'SWIFT_OPTIMIZATION_LEVEL' => '-Owholemodule' }
  s.swift_version = '5.0'

# Use install_modules_dependencies helper to install the dependencies if React Native version >=0.71.0.
# See https://github.com/facebook/react-native/blob/febf6b7f33fdb4904669f99d795eba4c0f95d7bf/scripts/cocoapods/new_architecture.rb#L79.
if respond_to?(:install_modules_dependencies, true)
  install_modules_dependencies(s)
else
  s.dependency "React-Core"
end
end
