Pod::Spec.new do |s|
  s.name             = 'ToosieSlide'
  s.version          = "1.0.0"
  s.summary          = 'A carousel layout provider for collection views'
  s.homepage         = 'https://theinkedengineer.com'
  s.license          = { :type => 'Apache License 2.0' }
  s.author           = { 'Firas Safa' => 'firas@theinkedengineer.com' }
  s.source           = { :git => 'https://github.com/TheInkedEngineer/ToosieSlide.git', :tag => s.version.to_s }

  s.swift_version    = '5.2'

  s.ios.deployment_target = '10.0'
  
  s.ios.source_files = [
    'Sources/**/*.swift'
  ]

end
