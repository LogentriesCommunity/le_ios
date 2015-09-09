Pod::Spec.new do |s|
  s.name = 'le'
  s.version = '1.1'
  s.summary = 'Logentries logging for iOS'
  s.homepage = 'https://github.com/logentries/le_ios'
  s.author = { 'Logentries' => 'support@logentries.com' }
  s.source = { :git => 'https://github.com/logentries/le_ios.git', :tag => "#{s.version}" }
  s.source_files = 'lelib/*.{h,m}'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true
  s.license = 'MIT'
end
