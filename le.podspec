Pod::Spec.new do |s|
  s.name = 'le'
  s.version = '0.0.1'
  s.summary = 'Logentries logging for iOS'
  s.homepage = 'https://github.com/logentries/le_ios'
  s.author = { 'LogEntries Support' => 'support@logentries.com' }
  s.source = { :git => 'https://github.com/logentries/le_ios.git' }
  s.source_files = 'lelib/*.{h,m}'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true
  s.license = 'BSD'
end
